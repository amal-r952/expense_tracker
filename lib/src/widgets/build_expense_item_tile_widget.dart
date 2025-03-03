import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/build_cached_network_image_widget.dart';
import 'package:expense_tracker/src/widgets/build_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/src/models/expense_response_model.dart';

class BuildExpenseItemTileWidget extends StatelessWidget {
  final ExpenseResponseModel expense;

  const BuildExpenseItemTileWidget({
    super.key,
    required this.expense,
  });

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (expense.imageUrl != null && expense.imageUrl!.isNotEmpty)
            BuildCachedNetworkImageWidget(
              imageUrl: expense.imageUrl!,
              boxFit: BoxFit.cover,
              boxShape: BoxShape.rectangle,
              height: screenWidth(context, dividedBy: 4.5),
              width: screenWidth(context, dividedBy: 4.5),
              borderRadius: BorderRadius.circular(12),
              placeHolder: const Center(
                child: SizedBox(
                    height: 30, width: 30, child: BuildLoadingWidget()),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category ?? "Unknown Category",
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const SizedBox(height: 4),
                if (expense.imageUrl != null && expense.imageUrl!.isNotEmpty)
                  Text(
                    expense.notes!,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (expense.imageUrl != null && expense.imageUrl!.isNotEmpty)
                  const SizedBox(height: 6),
                Text(
                  "${ObjectFactory().appHive.getCurrentCurrency()} ${convertFromINR(expense.amount!, ObjectFactory().appHive.getCurrentCurrencyValue()!).toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.accentColorDark),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            expense.createdAt != null
                ? DateFormat('dd MMM, yyyy').format(expense.createdAt!)
                : "Unknown Date",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Theme.of(context).dividerColor),
          ),
        ],
      ),
    );
  }
}
