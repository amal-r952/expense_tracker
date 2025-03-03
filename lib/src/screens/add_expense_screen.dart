import 'dart:io';

import 'package:expense_tracker/src/bloc/expense_bloc.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/app_toast.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/add_or_edit_image_widget.dart';
import 'package:expense_tracker/src/widgets/build_custom_appbar_widget.dart';
import 'package:expense_tracker/src/widgets/build_custom_dropdown_widget.dart';
import 'package:expense_tracker/src/widgets/build_elevated_button.dart';
import 'package:expense_tracker/src/widgets/build_single_day_picker.dart';
import 'package:expense_tracker/src/widgets/build_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String imageUrl = "";
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isAddingExpense = false;
  ExpenseBloc expenseBloc = ExpenseBloc();

  List<String> dropDownItems = Constants.categories;

  File? _pickedImage;

  void _pickDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 400,
          child: BuildSingleDayPicker(),
        ),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    categoryController.text = dropDownItems[0];
    dateController.text = selectedDate.toIso8601String().split('T')[0];
    expenseBloc.addExpenseResponse.listen((event) {
      print("ADD EXPENSE RESPONSE: $event");
      setState(() {
        isAddingExpense = false;
      });
      AppToasts.showSuccessToastTop(context, "Expense added successfully!");
      pop(context);
    }).onError((error, stackTrace) {
      setState(() {
        isAddingExpense = false;
      });
      AppToasts.showErrorToastTop(context, "Error adding expense!");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BuildCustomAppBarWidget(
        title: "Add Expense",
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  ' Category',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 10),

                BuildCustomDropdownWidget(
                    dropDownItems: dropDownItems,
                    onChanged: (value) {
                      setState(() {
                        categoryController.text = value;
                      });
                    }),

                const SizedBox(height: 15),

                Text(
                  ' Amount ${ObjectFactory().appHive.getCurrentCurrency()}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 10),
                BuildTextField(
                  fillColor: Theme.of(context).cardColor,
                  textColor: Theme.of(context).dividerColor,
                  textEditingController: amountController,
                  enable: true,
                  hintText: 'Enter the amount',
                  showBorder: true,
                  keyboardType: TextInputType.number,
                  showAlwaysErrorBorder: false,
                ),
                const SizedBox(height: 15),

                Text(
                  ' Notes',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 10),
                BuildTextField(
                  fillColor: Theme.of(context).cardColor,
                  textColor: Theme.of(context).dividerColor,
                  textEditingController: notesController,
                  enable: true,
                  maxLines: 3,
                  hintText: 'Additional details',
                  showBorder: true,
                  showAlwaysErrorBorder: false,
                ),
                const SizedBox(height: 15),
                Text(
                  ' Date',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 10),
                // Pick Date Button
                GestureDetector(
                  onTap: () => _pickDate(context, dateController),
                  child: Container(
                    width: screenWidth(context),
                    height: screenHeight(context, dividedBy: 18),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dateController.text.isEmpty
                            ? "Select the day"
                            : dateController.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: dateController.text.isEmpty
                                  ? AppColors.textFieldHintColor
                                  : Theme.of(context).dividerColor,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  ' Invoice',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 10),
                ProfilePictureEditWidget(
                    imageUrl: imageUrl,
                    image: (event) {
                      setState(() {
                        imageUrl = event!;
                      });
                      print("IMAGE URL IN ADD EXPENSE PAGE: $event");
                    })
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BuildElevatedButton(
            backgroundColor: AppColors.primaryColorOrange,
            width: screenWidth(
              context,
            ),
            height: screenHeight(context, dividedBy: 18),
            child: null,
            txt: "ADD EXPENSE",
            onTap: () {
              if (amountController.text.isEmpty ||
                  categoryController.text.isEmpty) {
                AppToasts.showErrorToastTop(
                    context, "Please add all the necessary fields!");
                return;
              } else if (isAddingExpense) {
                return;
              }

              setState(() {
                isAddingExpense = true;
              });

              expenseBloc.addExpense(
                category: categoryController.text,
                amount: convertToINR(double.tryParse(amountController.text)!,
                    ObjectFactory().appHive.getCurrentCurrencyValue()!),
                date: selectedDate,
                imageUrl: imageUrl,
                notes: notesController.text,
              );
            }),
      ),
    );
  }
}
