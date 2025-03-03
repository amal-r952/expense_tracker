import 'package:expense_tracker/src/bloc/expense_bloc.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/app_toast.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/font_family.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/build_custom_appbar_widget.dart';
import 'package:expense_tracker/src/widgets/build_custom_dropdown_widget.dart';
import 'package:expense_tracker/src/widgets/build_elevated_button.dart';
import 'package:expense_tracker/src/widgets/build_loading_widget.dart';
import 'package:expense_tracker/src/widgets/build_textfield_widget.dart';
import 'package:flutter/material.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  bool isUpdatingBudget = false;
  bool isFetchingCurrentBudget = true;
  String selectedCategory = Constants.categories[0];
  ExpenseBloc expenseBloc = ExpenseBloc();
  TextEditingController budgetController = TextEditingController();

  @override
  void initState() {
    expenseBloc.fetchCurrentBudget(category: selectedCategory);
    expenseBloc.fetchCurrentBudgetResponse.listen((event) {
      print("CURRENT BUDGET: $event");
      if (event != null) {
        budgetController.text = convertFromINR(
                event, ObjectFactory().appHive.getCurrentCurrencyValue()!)
            .toString();
        setState(() {
          isFetchingCurrentBudget = false;
        });
      }
    }).onError((error, stackTrace) {
      print("ERROR: $error");
      setState(() {
        isFetchingCurrentBudget = false;
      });
      AppToasts.showErrorToastTop(context, "Error fetching current budget!");
    });
    expenseBloc.updateCurrentBudgetResponse.listen((event) {
      print("UPDATE BUDGET RESPONSE: $event");
      setState(() {
        isUpdatingBudget = false;
      });
      AppToasts.showSuccessToastTop(context, "Budget updated successfully!");
    }).onError((error, stackTrace) {
      print("ERROR: $error");
      setState(() {
        isUpdatingBudget = false;
      });
      AppToasts.showErrorToastTop(context, "Error updating budget!");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BuildCustomAppBarWidget(
        title: "Set Budget",
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isFetchingCurrentBudget
            ? const Center(
                child: BuildLoadingWidget(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose a category to modify the budget!",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  BuildCustomDropdownWidget(
                      dropDownItems: Constants.categories,
                      initialItem: selectedCategory,
                      onChanged: (category) {
                        print("SELECTED CATEGORY: $category");
                        setState(() {
                          selectedCategory = category;
                          isFetchingCurrentBudget = true;
                        });
                        expenseBloc.fetchCurrentBudget(
                            category: selectedCategory);
                      }),
                  const SizedBox(height: 30),
                  Text(
                    "Current currency: ${ObjectFactory().appHive.getCurrentCurrency()}",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  BuildTextField(
                    fillColor: Theme.of(context).cardColor,
                    textColor: Theme.of(context).dividerColor,
                    textEditingController: budgetController,
                    enable: true,
                    maxLines: 1,
                    hintText: 'Budget amount for $selectedCategory',
                    keyboardType: TextInputType.number,
                    showBorder: true,
                    showAlwaysErrorBorder: false,
                  ),
                ],
              ),
      ),
      bottomNavigationBar: isFetchingCurrentBudget
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: BuildElevatedButton(
                  backgroundColor: AppColors.primaryColorOrange,
                  width: screenWidth(context),
                  height: screenHeight(context, dividedBy: 18),
                  txt: "APPLY",
                  onTap: () {
                    if (!isUpdatingBudget) {
                      setState(() {
                        isUpdatingBudget = true;
                      });
                      expenseBloc.updateCurrentBudget(
                          category: selectedCategory,
                          updatedBudget: convertToINR(
                              double.parse(budgetController.text),
                              ObjectFactory()
                                  .appHive
                                  .getCurrentCurrencyValue()!));
                    }
                  },
                  child: isUpdatingBudget
                      ? const BuildLoadingWidget(
                          color: Colors.white,
                        )
                      : Text(
                          "UPDATE",
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: FontFamily.gothamBook,
                                color: AppColors.primaryColorLight,
                              ),
                        )),
            ),
    );
  }
}
