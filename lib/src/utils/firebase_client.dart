import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/src/models/expense_response_model.dart';
import 'package:expense_tracker/src/models/expenses_pagination_model.dart';
import 'package:expense_tracker/src/models/summary_response_model.dart';
import 'package:expense_tracker/src/models/user_response_model.dart';
import 'package:expense_tracker/src/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseClient {
  FirebaseServices firebaseServices = FirebaseServices();

  Future<UserCredential?> signInWithGoogle() {
    return firebaseServices.signInWithGoogle();
  }

  Future<UserResponseModel?> addUserDataToFirebase({required String userId}) {
    return firebaseServices.addUserDataToFirebase(userId: userId);
  }

  Future<double> fetchCurrentBudget({required String category}) {
    return firebaseServices.fetchCurrentBudget(category: category);
  }

  Future<String> uploadImage(
      {required File imageFile, required String folderName}) {
    return firebaseServices.uploadImageToSupabase(
        imageFile: imageFile, folderName: folderName);
  }

  Future<bool> updateCurrentBudget(
      {required String category, required double updatedBudget}) {
    return firebaseServices.updateCurrentBudget(
        category: category, updatedBudget: updatedBudget);
  }

  Future<ExpenseResponseModel?> addExpense({
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) {
    return firebaseServices.addExpense(
        category: category,
        amount: amount,
        date: date,
        imageUrl: imageUrl,
        notes: notes);
  }

  Future<ExpenseResponseModel?> editExpense({
    required String docId,
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) {
    return firebaseServices.editExpense(
        docId: docId,
        category: category,
        amount: amount,
        date: date,
        imageUrl: imageUrl,
        notes: notes);
  }

  Future<bool> deleteExpense({
    required String docId,
  }) {
    return firebaseServices.deleteExpense(docId: docId);
    ;
  }

  Future<ExpensesPaginationModel?> getExpenses({
    String? category,
    DocumentSnapshot? lastDocument,
  }) async {
    return firebaseServices.getExpenses(
        lastDocument: lastDocument, category: category);
  }

  Future<SummaryResponseModel?> getExpenseSummary({
    required String category,
  }) async {
    return firebaseServices.getExpenseSummary(category: category);
  }
}
