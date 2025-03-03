import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/src/models/expense_response_model.dart';
import 'package:expense_tracker/src/models/expenses_pagination_model.dart';
import 'package:expense_tracker/src/models/summary_response_model.dart';
import 'package:expense_tracker/src/models/user_response_model.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirebaseServices {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger log = Logger();

  /// Sign in with Google

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await ObjectFactory().auth.signInWithCredential(credential);
      } else {
        print("Google sign-in canceled by user");
        return null;
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  /// Add user data to Firestore
  Future<UserResponseModel?> addUserDataToFirebase(
      {required String userId}) async {
    try {
      final DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      final DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        return UserResponseModel.fromJson({
          "userId": data["userId"],
          "accountCreatedTime": (data["accountCreatedTime"] as Timestamp)
              .toDate()
              .toIso8601String(),
        });
      } else {
        final newUserData = UserResponseModel(
          userId: userId,
          accountCreatedTime: DateTime.now(),
        );

        // Create user document
        await userRef.set({
          "userId": newUserData.userId,
          "accountCreatedTime":
              Timestamp.fromDate(newUserData.accountCreatedTime!),
        });

        // Add budgets subcollection
        final CollectionReference budgetsRef = userRef.collection('budgets');
        List<String> categories = Constants.categories;

        for (String category in categories) {
          await budgetsRef.doc(category).set({
            "category": category,
            "monthlyBudget": 5000.0,
          });
        }

        return newUserData;
      }
    } catch (e) {
      print("Error adding/updating user data in Firestore: $e");
      return null;
    }
  }

  Future<double> fetchCurrentBudget({required String category}) async {
    try {
      final DocumentReference budgetRef = FirebaseFirestore.instance
          .collection('users')
          .doc(ObjectFactory().appHive.getUserId())
          .collection('budgets')
          .doc(category);

      final DocumentSnapshot budgetSnapshot = await budgetRef.get();

      if (budgetSnapshot.exists) {
        return (budgetSnapshot.data() as Map<String, dynamic>)["monthlyBudget"]
            as double;
      } else {
        print(
            "Category '$category' does not exist for current user. Returning 0.0.");
        return 0.0;
      }
    } catch (e) {
      print("Error fetching current budget for category '$category': $e");
      return 0.0;
    }
  }

  //upload image to firebase storage
  Future<String> uploadImage({
    required File imageFile,
    required String folderName,
  }) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference =
          FirebaseStorage.instance.ref().child('$folderName/$fileName.jpg');
      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading image: $e');
      return "";
    }
  }

  /// upload image to supabase storage

  Future<String> uploadImageToSupabase({
    required File imageFile,
    required String folderName,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      String filePath =
          "uploads/${ObjectFactory().appHive.getUserProfileEmail()}/$fileName";

      await supabase.storage.from('images').upload(filePath, imageFile);

      String publicUrl = supabase.storage.from('images').getPublicUrl(filePath);

      return publicUrl;
      // return fileName;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      return "";
    }
  }

  Future<bool> updateCurrentBudget(
      {required String category, required double updatedBudget}) async {
    try {
      final DocumentReference budgetRef = FirebaseFirestore.instance
          .collection('users')
          .doc(ObjectFactory().appHive.getUserId())
          .collection('budgets')
          .doc(category);

      final DocumentSnapshot budgetSnapshot = await budgetRef.get();

      if (budgetSnapshot.exists) {
        await budgetRef.update({
          "monthlyBudget": updatedBudget,
        });
        return true; // Success
      } else {
        print("Category '$category' does not exist for current user.");
        return false; // Failure
      }
    } catch (e) {
      print("Error updating current budget for category '$category': $e");
      return false; // Failure
    }
  }

  Future<ExpenseResponseModel> addExpense({
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) async {
    try {
      String userId = ObjectFactory().appHive.getUserId()!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference expensesRef =
          firestore.collection('users').doc(userId).collection('expenses');
      DocumentReference newDocRef = expensesRef.doc();
      String documentId = newDocRef.id;
      ExpenseResponseModel expense = ExpenseResponseModel(
        documentId: documentId,
        category: category,
        amount: amount,
        notes: notes,
        createdAt: date,
        imageUrl: imageUrl,
      );
      await newDocRef.set(expense.toJson());

      return expense;
    } catch (e) {
      print('Error adding expense: $e');
      throw Exception('Failed to add expense');
    }
  }

  Future<ExpenseResponseModel> editExpense({
    required String docId,
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) async {
    try {
      String userId = ObjectFactory().appHive.getUserId()!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference expensesRef =
          firestore.collection('users').doc(userId).collection('expenses');
      DocumentReference expenseDocRef = expensesRef.doc(docId);

      // Create a map with the fields to update
      Map<String, dynamic> updatedFields = {
        'category': category,
        'amount': amount,
        'notes': notes,
        'imageUrl': imageUrl,
        'createdAt': date.toIso8601String(),
      };
      updatedFields.removeWhere((key, value) => value == null);
      await expenseDocRef.update(updatedFields);

      return ExpenseResponseModel(
        documentId: docId,
        category: category,
        amount: amount,
        notes: notes,
        createdAt: date,
        imageUrl: imageUrl,
      );
    } catch (e) {
      print('Error editing expense: $e');
      throw Exception('Failed to edit expense');
    }
  }

  Future<bool> deleteExpense({
    required String docId,
  }) async {
    try {
      String userId = ObjectFactory().appHive.getUserId()!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference expensesRef =
          firestore.collection('users').doc(userId).collection('expenses');
      DocumentReference expenseDocRef = expensesRef.doc(docId);

      await expenseDocRef.delete();

      return true;
    } catch (e) {
      print('Error deleting expense: $e');
      throw Exception('Failed to delete expense');
    }
  }

  Future<ExpensesPaginationModel?> getExpenses({
    String? category,
    DocumentSnapshot? lastDocument,
  }) async {
    List<ExpenseResponseModel> expenses = [];

    try {
      Query query = ObjectFactory()
          .firestore
          .collection("users")
          .doc(ObjectFactory().appHive.getUserId()!)
          .collection("expenses")
          .orderBy("createdAt", descending: true);

      if (category != null && category.isNotEmpty) {
        query = query.where("category", isEqualTo: category);
      }

      query = query.limit(12);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        expenses = querySnapshot.docs
            .map((doc) => ExpenseResponseModel.fromJson(
                doc.data() as Map<String, dynamic>))
            .toList();

        return ExpensesPaginationModel(
          lastDocument: querySnapshot.docs.last,
          expenses: expenses,
        );
      } else {
        return ExpensesPaginationModel(expenses: [], lastDocument: null);
      }
    } catch (e) {
      log.e('Error fetching data', error: e);
      return null;
    }
  }

  Future<SummaryResponseModel> getExpenseSummary(
      {required String category}) async {
    try {
      String userId = ObjectFactory().appHive.getUserId()!;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot budgetDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(category)
          .get();

      double budget = budgetDoc.exists
          ? ((budgetDoc.data() as Map<String, dynamic>)['monthlyBudget'] ?? 0)
          : 0;
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      QuerySnapshot expenseSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .get();

      double currentStatus = 0.0;
      for (var doc in expenseSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('createdAt') && data['createdAt'] is String) {
          DateTime expenseDate = DateTime.parse(data['createdAt']);

          if (expenseDate.isAfter(startOfMonth) &&
              expenseDate.isBefore(endOfMonth) &&
              data.containsKey('category') &&
              data['category'] == category) {
            currentStatus += (data['amount'] as num? ?? 0).toDouble();
          }
        }
      }

      print("CATEGORY: $category");
      print("BUDGET: $budget");
      print("CURRENT STATUS:$currentStatus");

      return SummaryResponseModel(
        category: category,
        budget: budget,
        currentStatus: currentStatus,
      );
    } catch (e) {
      print("Error fetching budget data: $e");
      throw Exception("Failed to fetch budget data");
    }
  }

  Future<bool> updateUserBudget({
    required String userId,
    required String category,
    required double newBudget,
  }) async {
    try {
      final DocumentReference budgetRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(category);

      final DocumentSnapshot budgetSnapshot = await budgetRef.get();

      if (budgetSnapshot.exists) {
        await budgetRef.update({
          "monthlyBudget": newBudget,
        });
        return true; // Success
      } else {
        print("Category '$category' does not exist for user $userId.");
        return false;
      }
    } catch (e) {
      print("Error updating budget for category '$category': $e");
      return false;
    }
  }

  Future<double> getUserBudget({
    required String userId,
    required String category,
  }) async {
    try {
      final DocumentReference budgetRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(category);

      final DocumentSnapshot budgetSnapshot = await budgetRef.get();

      if (budgetSnapshot.exists) {
        return (budgetSnapshot.data() as Map<String, dynamic>)["monthlyBudget"]
            as double;
      } else {
        print(
            "Category '$category' does not exist for user $userId. Returning 0.0.");
        return 0.0;
      }
    } catch (e) {
      print("Error fetching budget for category '$category': $e");
      return 0.0;
    }
  }
}
