import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/build_elevated_button.dart';

class BuildSingleDayPicker extends StatefulWidget {
  @override
  _BuildSingleDayPickerState createState() => _BuildSingleDayPickerState();
}

class _BuildSingleDayPickerState extends State<BuildSingleDayPicker> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Choose a date',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Expanded(
          child: DatePicker(
            initialDate: DateTime.now(),
            minDate: DateTime(2025, 1, 1),
            maxDate: DateTime(2030, 10, 30),
            currentDate: DateTime.now(),
            selectedDate: selectedDate,
            selectedCellTextStyle: Theme.of(context).textTheme.bodyLarge,
            currentDateDecoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColorGreen.withOpacity(0.3),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            selectedCellDecoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.primaryColorGreen),
            currentDateTextStyle: Theme.of(context).textTheme.bodyLarge,
            daysOfTheWeekTextStyle:
                Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600, // Slightly emphasized
                    ),
            disabledCellsTextStyle: Theme.of(context).textTheme.bodySmall,
            enabledCellsTextStyle: Theme.of(context).textTheme.bodyMedium,
            leadingDateTextStyle: Theme.of(context).textTheme.headlineMedium,
            initialPickerType: PickerType.days,
            slidersColor: AppColors.primaryColorGreen,
            highlightColor: AppColors.primaryColorGreen.withOpacity(0.1),
            slidersSize: 20,
            splashColor: AppColors.primaryColorGreen.withOpacity(0.2),
            centerLeadingDate: true,
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
        ),
        if (selectedDate != null)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: BuildElevatedButton(
              backgroundColor: AppColors.primaryColorGreen,
              height: screenHeight(context, dividedBy: 22),
              child: null,
              txt: "Save",
              onTap: () {
                Navigator.pop(context, selectedDate);
              },
            ),
          ),
        if (selectedDate == null)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: screenHeight(context, dividedBy: 22),
            ),
          ),
      ],
    );
  }
}
