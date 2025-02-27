import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String notes;

  @HiveField(4)
  final String? imageUrl; // Nullable

  Expense({
    required this.category,
    required this.amount,
    required this.date,
    required this.notes,
    this.imageUrl,
  });
}
