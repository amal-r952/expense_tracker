import 'package:expense_tracker/src/models/summary_response_model.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class BuildSummaryListItemWidget extends StatefulWidget {
  final SummaryResponseModel summary;
  const BuildSummaryListItemWidget({
    super.key,
    required this.summary,
  });

  @override
  State<BuildSummaryListItemWidget> createState() =>
      _BuildSummaryListItemWidgetState();
}

class _BuildSummaryListItemWidgetState
    extends State<BuildSummaryListItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 1,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.summary.category,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  "CURRENT:  ${ObjectFactory().appHive.getCurrentCurrency()} ${convertFromINR(widget.summary.currentStatus, ObjectFactory().appHive.getCurrentCurrencyValue()!).toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  "BUDGET: ${ObjectFactory().appHive.getCurrentCurrency()} ${convertFromINR(widget.summary.budget, ObjectFactory().appHive.getCurrentCurrencyValue()!).toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 6.0,
            percent: (widget.summary.currentStatus / widget.summary.budget)
                .clamp(0.0, 1.0),
            center: Text(
              "${((widget.summary.currentStatus / widget.summary.budget) * 100).clamp(0, 100).toStringAsFixed(1)}%",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
            ),
            // progressColor: AppColors.accentColorDark,
            linearGradient: const LinearGradient(
              colors: [
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.red,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            animation: true,
          ),
        ],
      ),
    );
  }
}
