import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/src/models/expense_response_model.dart';

class ExpensesPaginationModel {
  final List<ExpenseResponseModel> expenses;
  final DocumentSnapshot? lastDocument;
  ExpensesPaginationModel({
    required this.expenses,
    required this.lastDocument,
  });
}
