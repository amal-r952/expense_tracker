import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/src/models/expense_response_model.dart';
import 'package:expense_tracker/src/models/expenses_pagination_model.dart';
import 'package:expense_tracker/src/models/state.dart';
import 'package:expense_tracker/src/models/summary_response_model.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';

class ExpenseFirebaseProvider {
  Future<State?> fetchCurrentBudget({required String category}) async {
    final double budgetAmount = await ObjectFactory()
        .firebaseClient
        .fetchCurrentBudget(category: category);
    if (budgetAmount != null) {
      return State.success(budgetAmount);
    } else {
      return null;
    }
  }

  Future<State?> updateCurrentBudget(
      {required String category, required double updatedBudget}) async {
    final bool status = await ObjectFactory()
        .firebaseClient
        .updateCurrentBudget(category: category, updatedBudget: updatedBudget);
    if (status == true || status == false) {
      return State.success(status);
    } else {
      return null;
    }
  }

  Future<State?> addExpense({
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) async {
    final ExpenseResponseModel? expenseResponseModel = await ObjectFactory()
        .firebaseClient
        .addExpense(
            category: category,
            amount: amount,
            date: date,
            imageUrl: imageUrl,
            notes: notes);
    if (expenseResponseModel != null) {
      return State.success(expenseResponseModel);
    } else {
      return null;
    }
  }

  Future<State?> editExpense({
    required String docId,
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) async {
    final ExpenseResponseModel? expenseResponseModel = await ObjectFactory()
        .firebaseClient
        .editExpense(
            docId: docId,
            category: category,
            amount: amount,
            date: date,
            imageUrl: imageUrl,
            notes: notes);
    if (expenseResponseModel != null) {
      return State.success(expenseResponseModel);
    } else {
      return null;
    }
  }

  Future<State?> deleteExpense({
    required String docId,
  }) async {
    final bool isDeleted =
        await ObjectFactory().firebaseClient.deleteExpense(docId: docId);
    if (isDeleted == true || isDeleted == false) {
      return State.success(isDeleted);
    } else {
      return null;
    }
  }

  Future<State?> getExpenses({
    String? category,
    DocumentSnapshot? lastDocument,
  }) async {
    final ExpensesPaginationModel? data = await ObjectFactory()
        .firebaseClient
        .getExpenses(lastDocument: lastDocument, category: category);
    if (data != []) {
      return State.success(data);
    } else {
      return null;
    }
  }

  Future<State?> getExpenseSummary({
    required String category,
  }) async {
    final SummaryResponseModel? data = await ObjectFactory()
        .firebaseClient
        .getExpenseSummary(category: category);
    if (data != null) {
      return State.success(data);
    } else {
      return null;
    }
  }
}
