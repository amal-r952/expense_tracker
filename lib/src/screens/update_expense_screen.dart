import 'dart:io';

import 'package:expense_tracker/src/models/expense_model.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/app_toast.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/build_custom_appbar_widget.dart';
import 'package:expense_tracker/src/widgets/build_custom_dropdown_widget.dart';
import 'package:expense_tracker/src/widgets/build_elevated_button.dart';
import 'package:expense_tracker/src/widgets/build_single_day_picker.dart';
import 'package:expense_tracker/src/widgets/build_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class EditExpenseScreen extends StatefulWidget {
  final int index;
  final Expense expense;

  const EditExpenseScreen({
    Key? key,
    required this.index,
    required this.expense,
  }) : super(key: key);

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController categoryController;
  late TextEditingController amountController;
  late TextEditingController notesController;
  late TextEditingController dateController;
  late DateTime selectedDate;
  late Box<Expense> expenseBox;
  File? _pickedImage;
  List<String> dropDownItems = Constants.categories;

  @override
  void initState() {
    super.initState();
    expenseBox = Hive.box<Expense>('expenses');
    selectedDate = widget.expense.date;

    categoryController = TextEditingController(text: widget.expense.category);
    amountController =
        TextEditingController(text: widget.expense.amount.toString());
    notesController = TextEditingController(text: widget.expense.notes);
    dateController = TextEditingController(
        text: selectedDate.toIso8601String().split('T')[0]);

    if (widget.expense.imageUrl != null &&
        widget.expense.imageUrl!.isNotEmpty) {
      _pickedImage = File(widget.expense.imageUrl!);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
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
        dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _updateExpense() {
    if (amountController.text.isEmpty || categoryController.text.isEmpty) {
      AppToasts.showErrorToastTop(
          context, "Please fill in all the necessary fields!");
      return;
    }

    final updatedExpense = Expense(
      category: categoryController.text,
      amount: double.tryParse(amountController.text) ?? 0.0,
      date: selectedDate,
      notes: notesController.text,
      imageUrl: _pickedImage?.path ?? widget.expense.imageUrl,
    );

    expenseBox.putAt(widget.index, updatedExpense);
    AppToasts.showSuccessToastTop(context, "Expense updated successfully!");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BuildCustomAppBarWidget(
        title: "Edit Expense",
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  initialItem: categoryController.text,
                  onChanged: (value) {
                    setState(() {
                      categoryController.text = value;
                    });
                  },
                ),
                const SizedBox(height: 15),
                Text(
                  ' Amount',
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
                  hintText: 'Enter the amount',
                  keyboardType: TextInputType.number,
                  showBorder: true,
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
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: Container(
                    width: screenWidth(context),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      dateController.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).dividerColor,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: screenWidth(context),
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                          color: Theme.of(context).dividerColor, width: 0.5),
                      image: _pickedImage != null
                          ? DecorationImage(
                              image: FileImage(_pickedImage!),
                              fit: BoxFit.cover,
                            )
                          : (widget.expense.imageUrl!.isNotEmpty
                              ? DecorationImage(
                                  image:
                                      FileImage(File(widget.expense.imageUrl!)),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    child:
                        _pickedImage == null && widget.expense.imageUrl!.isEmpty
                            ? Center(
                                child: Icon(Icons.add,
                                    size: 40,
                                    color: Theme.of(context).dividerColor),
                              )
                            : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BuildElevatedButton(
          width: screenWidth(
            context,
          ),
          height: screenHeight(context, dividedBy: 18),
          child: null,
          txt: "UPDATE",
          backgroundColor: AppColors.primaryColorGreen,
          onTap: _updateExpense,
        ),
      ),
    );
  }
}
