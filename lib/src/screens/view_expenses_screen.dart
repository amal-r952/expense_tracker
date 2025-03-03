import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/src/bloc/expense_bloc.dart';
import 'package:expense_tracker/src/models/expense_response_model.dart';
import 'package:expense_tracker/src/screens/add_expense_screen.dart';
import 'package:expense_tracker/src/screens/settings_screen.dart';
import 'package:expense_tracker/src/screens/update_expense_screen.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/app_toast.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/build_custom_appbar_widget.dart';
import 'package:expense_tracker/src/widgets/build_custom_dropdown_widget.dart';
import 'package:expense_tracker/src/widgets/build_elevated_button.dart';
import 'package:expense_tracker/src/widgets/build_expense_item_tile_widget.dart';
import 'package:expense_tracker/src/widgets/build_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

class ViewExpensesScreen extends StatefulWidget {
  static List<ExpenseResponseModel> expenses = [];
  const ViewExpensesScreen({Key? key}) : super(key: key);

  @override
  _ViewExpensesScreenState createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen>
    with WidgetsBindingObserver {
  ExpenseBloc expenseBloc = ExpenseBloc();
  final LocalAuthentication auth = LocalAuthentication();
  Timer? _lockTimer;
  String selectedOption = "1";
  bool isLoading = false;
  bool isLoadingAdditionalData = false;
  String selectedCategory = Constants.categories[0];

  DocumentSnapshot? lastDocument;
  ScrollController scrollController = ScrollController();
  getAdditionalData() async {
    if (isLoadingAdditionalData || lastDocument == null)
      return; // Prevent duplicate calls

    setState(() {
      isLoadingAdditionalData = true;
    });

    final prevLength = ViewExpensesScreen.expenses.length;

    await expenseBloc.getExpenses(
      category: selectedOption == "1" ? "" : selectedCategory,
      lastDocument: lastDocument,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      isLoadingAdditionalData = false;
      if (ViewExpensesScreen.expenses.length == prevLength) {
        lastDocument = null;
      }
    });
  }

  onScroll() {
    print("IS FETCHING ADDITIONAL DATA 1");
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
        !isLoadingAdditionalData &&
        lastDocument != null) {
      print("IS FETCHING ADDITIONAL DATA");
      getAdditionalData();
    }
  }

  getData() {
    setState(() {
      isLoading = true;
    });
    lastDocument = null;
    ViewExpensesScreen.expenses.clear();
    expenseBloc.getExpenses(
        category: selectedOption == "1" ? "" : selectedCategory,
        lastDocument: lastDocument);
  }

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
    return ObjectFactory().appHive.getIsAuthenticated();
  }

  void putIsAuthenticated(bool value) {
    ObjectFactory().appHive.putIsAuthenticated(isAuthenticated: value);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
    WidgetsBinding.instance.addObserver(this);
    _authenticateUser();

    expenseBloc.getExpensesResponse.listen((event) {
      lastDocument = event.lastDocument;
      setState(() {
        ViewExpensesScreen.expenses.addAll(event.expenses);
        isLoading = false;
      });
    }).onError((Error) {
      setState(() {
        isLoading = false;
        isLoadingAdditionalData = false;
      });
    });
    getData();
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
                push(context, const SettingsScreen()).then((_) {
                  getData();
                });
              },
              trailingIconSize: 25,
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: '1',
                          activeColor: AppColors.primaryColorOrange,
                          focusColor: Theme.of(context).dividerColor,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                              isLoading = true;
                              isLoadingAdditionalData = false;
                              selectedCategory = Constants.categories[0];
                            });
                            getData();
                          },
                        ),
                        Text(
                          'View All',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                        ),
                        const Spacer(),
                        Radio<String>(
                          value: '2',
                          activeColor: AppColors.primaryColorOrange,
                          focusColor: Theme.of(context).dividerColor,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;

                              isLoading = true;
                              isLoadingAdditionalData = false;
                            });
                            getData();
                          },
                        ),
                        Text(
                          'Categorized',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  selectedOption == '1'
                      ? buildAllExpensesList()
                      : buildCategorizedExpensesList(),
                  isLoadingAdditionalData
                      ? const BuildLoadingWidget()
                      : const SizedBox.shrink()
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                push(context, AddExpenseScreen()).then((_) {
                  getData();
                });
              },
              backgroundColor: AppColors.primaryColorOrange,
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: BuildElevatedButton(
                  backgroundColor: AppColors.primaryColorOrange,
                  width: screenWidth(
                    context,
                  ),
                  height: screenHeight(context, dividedBy: 18),
                  txt: "Authenticate to view expenses!",
                  onTap: _authenticateUser,
                  child: null,
                ),
              ),
            ),
          );
  }

  Widget buildAllExpensesList() {
    return isLoading
        ? const Center(child: BuildLoadingWidget())
        : ViewExpensesScreen.expenses.isEmpty
            ? Expanded(
                child: Center(
                  child: Text(
                    "You haven't added any expenses!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                ),
              )
            : Expanded(
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: ViewExpensesScreen.expenses.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          push(
                                  context,
                                  UpdateExpenseScreen(
                                      expense:
                                          ViewExpensesScreen.expenses[index]))
                              .then((_) {
                            getData();
                          });
                        },
                        child: BuildExpenseItemTileWidget(
                            expense: ViewExpensesScreen.expenses[index]),
                      );
                    }),
              );
  }

  Widget buildCategorizedExpensesList() {
    return Expanded(
      child: Column(
        children: [
          BuildCustomDropdownWidget(
              dropDownItems: Constants.categories,
              initialItem: Constants.categories[0],
              onChanged: (event) {
                print("Selected category: $event");
                setState(() {
                  selectedCategory = event;
                });
                getData();
              }),
          const SizedBox(height: 10),
          isLoading
              ? const Center(child: BuildLoadingWidget())
              : ViewExpensesScreen.expenses.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Text(
                          "You haven't added any expenses in $selectedCategory!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                          controller: scrollController,
                          itemCount: ViewExpensesScreen.expenses.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                push(
                                        context,
                                        UpdateExpenseScreen(
                                            expense: ViewExpensesScreen
                                                .expenses[index]))
                                    .then((_) {
                                  getData();
                                });
                              },
                              child: BuildExpenseItemTileWidget(
                                  expense: ViewExpensesScreen.expenses[index]),
                            );
                          }),
                    )
        ],
      ),
    );
  }
}
