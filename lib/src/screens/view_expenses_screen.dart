import 'dart:async';
import 'dart:io';

import 'package:expense_tracker/src/models/expense_model.dart';
import 'package:expense_tracker/src/screens/add_expense_screen.dart';
import 'package:expense_tracker/src/screens/settings_screen.dart';
import 'package:expense_tracker/src/screens/update_expense_screen.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/app_toast.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/build_custom_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

class ViewExpensesScreen extends StatefulWidget {
  const ViewExpensesScreen({Key? key}) : super(key: key);

  @override
  _ViewExpensesScreenState createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen>
    with WidgetsBindingObserver {
  late Box<Expense> expenseBox;
  final LocalAuthentication auth = LocalAuthentication();
  Timer? _lockTimer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print("App resumed. Authenticating...");
      _lockTimer?.cancel();
      _authenticateUser();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      print("App minimized. Locking app in 10 seconds...");

      _lockTimer = Timer(const Duration(seconds: 10), () {
        putIsAuthenticated(false);
        print("App locked after 10 seconds.");
      });
    }
  }

  Future<void> _authenticateUser() async {
    if (getIsAuthenticated()) return;

    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (canCheckBiometrics && isDeviceSupported) {
      try {
        bool didAuthenticate = await auth.authenticate(
          localizedReason: "Authenticate to view your expenses",
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          putIsAuthenticated(true);
        }
      } catch (e) {
        print("Authentication error: $e");
      }
    } else {
      print("Biometric authentication not available.");
    }
  }

  bool getIsAuthenticated() {
    return ObjectFactory().appHive.getIsAuthenticated() ?? false;
  }

  void putIsAuthenticated(bool value) {
    ObjectFactory().appHive.putIsAuthenticated(isAuthenticated: value);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    expenseBox = Hive.box<Expense>('expenses');
    _authenticateUser();
  }

  void _deleteExpense(int index) {
    expenseBox.deleteAt(index);
    AppToasts.showSuccessToastTop(context, "Expense deleted successfully");
  }

  @override
  Widget build(BuildContext context) {
    return getIsAuthenticated()
        ? Scaffold(
            appBar: BuildCustomAppBarWidget(
              title: "My expenses",
              showBackButton: false,
              showTrailingIcon: true,
              trailingIcon: const Icon(Icons.settings),
              onTrailingIconPressed: () {
                push(context, const SettingsScreen());
              },
              trailingIconSize: 25,
            ),
            body: ValueListenableBuilder(
              valueListenable: expenseBox.listenable(),
              builder: (context, Box<Expense> box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Text(
                      "No expenses added yet.",
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final expense = box.getAt(index);
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColorGreen.withOpacity(0.6),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Image Container
                          expense?.imageUrl?.isNotEmpty == true
                              ? Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                        width: 0.5),
                                    image: DecorationImage(
                                      image:
                                          FileImage(File(expense!.imageUrl!)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                        width: 0.5),
                                  ),
                                  child: const Center(
                                      child:
                                          Icon(Icons.receipt_long, size: 60))),

                          const SizedBox(width: 12), // Spacing

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense!.category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "₹${expense.amount.toStringAsFixed(2)}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatDate(expense.date.toLocal()),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (expense.notes != null &&
                                    expense.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    expense.notes!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: Theme.of(context).hintColor,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Delete Button
                          Column(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExpense(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => push(
                                  context,
                                  EditExpenseScreen(
                                    expense: expense,
                                    index: index,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                push(context, AddExpenseScreen());
              },
              backgroundColor: AppColors.primaryColorGreen,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
            ),
          )
        : Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: _authenticateUser,
                child: const Text("Authenticate to View Expenses"),
              ),
            ),
          );
  }
}
