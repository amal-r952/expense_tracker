import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/src/models/state.dart';
import 'package:expense_tracker/src/resources/api_providers/currency_api_provider.dart';
import 'package:expense_tracker/src/resources/firebase_provider/expense_firebase_provider.dart';
import 'package:expense_tracker/src/resources/firebase_provider/user_firebase_provider.dart';

class Repository {
  UserFirebaseProvider userFirebaseProvider = UserFirebaseProvider();
  CurrencyApiProvider currencyApiProvider = CurrencyApiProvider();
  ExpenseFirebaseProvider expenseFirebaseProvider = ExpenseFirebaseProvider();

  Future<State?> signInWithGoogle() => userFirebaseProvider.signInWithGoogle();
  Future<State?> addUserDataToFirebase({required String userId}) =>
      userFirebaseProvider.addUserDataToFirebase(userId: userId);
  Future<State> getCurrencyRates({required String currencyCode}) =>
      currencyApiProvider.getCurrencyRates(currencyCode: currencyCode);

  Future<State?> fetchCurrentBudget({required String category}) =>
      expenseFirebaseProvider.fetchCurrentBudget(category: category);

  Future<State?> updateCurrentBudget(
          {required String category, required double updatedBudget}) =>
      expenseFirebaseProvider.updateCurrentBudget(
          category: category, updatedBudget: updatedBudget);

  Future<State?> addExpense({
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) =>
      expenseFirebaseProvider.addExpense(
        category: category,
        amount: amount,
        date: date,
        imageUrl: imageUrl,
        notes: notes,
      );

  Future<State?> editExpense({
    required String docId,
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) =>
      expenseFirebaseProvider.editExpense(
        docId: docId,
        category: category,
        amount: amount,
        date: date,
        imageUrl: imageUrl,
        notes: notes,
      );

  Future<State?> deleteExpense({
    required String docId,
  }) =>
      expenseFirebaseProvider.deleteExpense(docId: docId);

  Future<State?> getExpenses({
    String? category,
    DocumentSnapshot? lastDocument,
  }) =>
      expenseFirebaseProvider.getExpenses(
          lastDocument: lastDocument, category: category);

  Future<State?> getExpenseSummary({
    required String category,
  }) =>
      expenseFirebaseProvider.getExpenseSummary(category: category);

  Future<State?> uploadImage(
          {required String folderName, required File imageFile}) =>
      userFirebaseProvider.uploadImage(
          folderName: folderName, imageFile: imageFile);
}
