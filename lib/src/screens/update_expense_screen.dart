import 'dart:io';

import 'package:expense_tracker/src/bloc/expense_bloc.dart';
import 'package:expense_tracker/src/models/expense_response_model.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/app_toast.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/add_or_edit_image_widget.dart';
import 'package:expense_tracker/src/widgets/build_custom_appbar_widget.dart';
import 'package:expense_tracker/src/widgets/build_custom_dropdown_widget.dart';
import 'package:expense_tracker/src/widgets/build_elevated_button.dart';
import 'package:expense_tracker/src/widgets/build_loading_widget.dart';
import 'package:expense_tracker/src/widgets/build_single_day_picker.dart';
import 'package:expense_tracker/src/widgets/build_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class UpdateExpenseScreen extends StatefulWidget {
  final ExpenseResponseModel expense;

  const UpdateExpenseScreen({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  _UpdateExpenseScreenState createState() => _UpdateExpenseScreenState();
}

class _UpdateExpenseScreenState extends State<UpdateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController categoryController;
  late TextEditingController amountController;
  late TextEditingController notesController;
  late TextEditingController dateController;
  DateTime selectedDate = DateTime.now();
  bool isDeletingExpense = false;
  bool isEditingExpense = false;
  String imageUrl = "";
  File? _pickedImage;
  List<String> dropDownItems = Constants.categories;
  ExpenseBloc expenseBloc = ExpenseBloc();

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedDate = widget.expense.createdAt!;

      categoryController = TextEditingController(text: widget.expense.category);
      amountController = TextEditingController(
        text: convertFromINR(
          widget.expense.amount!,
          ObjectFactory().appHive.getCurrentCurrencyValue()!,
        ).toStringAsFixed(2), // Ensure only two decimal places
      );

      notesController = TextEditingController(text: widget.expense.notes);
      dateController = TextEditingController(
          text: selectedDate.toIso8601String().split('T')[0]);
      imageUrl = widget.expense.imageUrl!;
    });
    expenseBloc.deleteExpenseResponse.listen((event) {
      print("DELETE EXPENSE RESPONSE: $event");
      setState(() {
        isDeletingExpense = false;
      });
      AppToasts.showSuccessToastTop(context, "Expense deleted successfully");
      pop(context);
    }).onError((error) {
      setState(() {
        isDeletingExpense = false;
      });
      AppToasts.showErrorToastTop(
          context, "Expense deletion failed, Please try again!");
    });
    expenseBloc.editExpenseResponse.listen((event) {
      print("EDIT EXPENSE RESPONSE: $event");
      setState(() {
        isEditingExpense = false;
      });
      AppToasts.showSuccessToastTop(context, "Expense edited successfully!");
      pop(context);
    }).onError((error) {
      setState(() {
        isEditingExpense = false;
      });
      AppToasts.showErrorToastTop(
          context, "Expense updation failed, Please try again!");
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BuildCustomAppBarWidget(
        title: "Update expense",
        showBackButton: true,
        showTrailingIcon: true,
        trailingIcon: const Icon(
          Icons.delete,
          color: AppColors.primaryColorRed,
        ),
        onTrailingIconPressed: () {
          setState(() {
            isDeletingExpense = true;
          });
          expenseBloc.deleteExpense(docId: widget.expense.documentId!);
        },
        trailingIconSize: 25,
      ),
      body: isDeletingExpense
          ? const Center(child: BuildLoadingWidget())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ' Category',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                      ),
                      const SizedBox(height: 10),
                      BuildCustomDropdownWidget(
                        dropDownItems: dropDownItems,
                        initialItem: categoryController.text,
                        onChanged: (value) {
                          setState(() {
                            categoryController.text = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      Text(
                        ' Amount ${ObjectFactory().appHive.getCurrentCurrency()}',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                      ),
                      const SizedBox(height: 10),
                      BuildTextField(
                        fillColor: Theme.of(context).cardColor,
                        textColor: Theme.of(context).dividerColor,
                        textEditingController: amountController,
                        hintText: 'Enter the amount',
                        keyboardType: TextInputType.number,
                        showBorder: true,
                        showAlwaysErrorBorder: false,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        ' Notes',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                      ),
                      const SizedBox(height: 10),
                      BuildTextField(
                        textEditingController: notesController,
                        maxLines: 3,
                        hintText: 'Additional details',
                        fillColor: Theme.of(context).cardColor,
                        textColor: Theme.of(context).dividerColor,
                        showBorder: true,
                        showAlwaysErrorBorder: false,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        ' Date',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
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
                            print("IMAGE URL IN EDIT EXPENSE PAGE: $event");
                          })
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: isDeletingExpense
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: BuildElevatedButton(
                width: screenWidth(
                  context,
                ),
                height: screenHeight(context, dividedBy: 18),
                child: null,
                txt: "UPDATE",
                backgroundColor: AppColors.primaryColorOrange,
                onTap: () {
                  // print("CATEGORY: $categoryController.text");
                  // print(
                  //     "AMOUNT: ${convertToINR(double.tryParse(amountController.text)!, ObjectFactory().appHive.getCurrentCurrencyValue()!)}");
                  // print("NOTES: ${notesController.text}");
                  // print("DATE: ${dateController.text}");
                  // print("IMAGE URL: $imageUrl");
                  expenseBloc.editExpense(
                    docId: widget.expense.documentId!,
                    category: categoryController.text,
                    amount: convertToINR(
                        double.tryParse(amountController.text)!,
                        ObjectFactory().appHive.getCurrentCurrencyValue()!),
                    date: selectedDate,
                    imageUrl: imageUrl,
                    notes: notesController.text,
                  );
                },
              ),
            ),
    );
  }
}
