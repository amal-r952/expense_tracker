import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/src/bloc/base_bloc.dart';
import 'package:expense_tracker/src/models/expense_response_model.dart';
import 'package:expense_tracker/src/models/expenses_pagination_model.dart';
import 'package:expense_tracker/src/models/state.dart';
import 'package:expense_tracker/src/models/summary_response_model.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/validators.dart';

class ExpenseBloc extends Object with Validators implements BaseBloc {
  final StreamController<bool> _loading = StreamController<bool>.broadcast();

  final StreamController<double> _fetchCurrentBudget =
      StreamController<double>.broadcast();

  final StreamController<bool> _updateCurrentBudget =
      StreamController<bool>.broadcast();

  final StreamController<ExpenseResponseModel> _addExpense =
      StreamController<ExpenseResponseModel>.broadcast();

  final StreamController<ExpenseResponseModel> _editExpense =
      StreamController<ExpenseResponseModel>.broadcast();

  final StreamController<bool> _deleteExpense =
      StreamController<bool>.broadcast();
  final StreamController<ExpensesPaginationModel> _getExpenses =
      StreamController<ExpensesPaginationModel>.broadcast();
  final StreamController<SummaryResponseModel> _getExpenseSummary =
      StreamController<SummaryResponseModel>.broadcast();

  /// stream for progress bar
  Stream<bool> get loadingListener => _loading.stream;
  Stream<double> get fetchCurrentBudgetResponse => _fetchCurrentBudget.stream;
  Stream<bool> get updateCurrentBudgetResponse => _updateCurrentBudget.stream;
  Stream<ExpenseResponseModel> get addExpenseResponse => _addExpense.stream;
  Stream<ExpenseResponseModel> get editExpenseResponse => _editExpense.stream;
  Stream<bool> get deleteExpenseResponse => _deleteExpense.stream;
  Stream<ExpensesPaginationModel> get getExpensesResponse =>
      _getExpenses.stream;
  Stream<SummaryResponseModel> get getExpenseSummaryResponse =>
      _getExpenseSummary.stream;

  /// stream sink

  StreamSink<bool> get loadingSink => _loading.sink;
  StreamSink<double> get fetchCurrentBudgetSink => _fetchCurrentBudget.sink;
  StreamSink<bool> get updateCurrentBudgetSink => _updateCurrentBudget.sink;
  StreamSink<ExpenseResponseModel> get addExpenseSink => _addExpense.sink;
  StreamSink<ExpenseResponseModel> get editExpenseSink => _editExpense.sink;
  StreamSink<bool> get deleteExpenseSink => _deleteExpense.sink;
  StreamSink<ExpensesPaginationModel> get getExpensesSink => _getExpenses.sink;
  StreamSink<SummaryResponseModel> get getExpenseSummarySink =>
      _getExpenseSummary.sink;

  /// fetching current budget

  fetchCurrentBudget({required String category}) async {
    State? state =
        await ObjectFactory().repository.fetchCurrentBudget(category: category);
    if (state is SuccessState) {
      fetchCurrentBudgetSink.add(state.value);
    } else if (state is ErrorState) {
      fetchCurrentBudgetSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  updateCurrentBudget({
    required String category,
    required double updatedBudget,
  }) async {
    State? state = await ObjectFactory().repository.updateCurrentBudget(
          category: category,
          updatedBudget: updatedBudget,
        );
    if (state is SuccessState) {
      updateCurrentBudgetSink.add(state.value);
    } else if (state is ErrorState) {
      updateCurrentBudgetSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  addExpense({
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) async {
    State? state = await ObjectFactory().repository.addExpense(
          category: category,
          amount: amount,
          date: date,
          imageUrl: imageUrl,
          notes: notes,
        );
    if (state is SuccessState) {
      addExpenseSink.add(state.value);
    } else if (state is ErrorState) {
      addExpenseSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  editExpense({
    required String docId,
    required String category,
    required double amount,
    String? notes,
    String? imageUrl,
    required DateTime date,
  }) async {
    State? state = await ObjectFactory().repository.editExpense(
          docId: docId,
          category: category,
          amount: amount,
          date: date,
          imageUrl: imageUrl,
          notes: notes,
        );
    if (state is SuccessState) {
      editExpenseSink.add(state.value);
    } else if (state is ErrorState) {
      editExpenseSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  deleteExpense({
    required String docId,
  }) async {
    State? state = await ObjectFactory().repository.deleteExpense(docId: docId);
    if (state is SuccessState) {
      deleteExpenseSink.add(state.value);
    } else if (state is ErrorState) {
      deleteExpenseSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  getExpenses({
    String? category,
    DocumentSnapshot? lastDocument,
  }) async {
    State? state = await ObjectFactory()
        .repository
        .getExpenses(lastDocument: lastDocument, category: category);
    if (state is SuccessState) {
      getExpensesSink.add(state.value);
    } else if (state is ErrorState) {
      getExpensesSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  getExpenseSummary({
   required  String category,
  }) async {
    State? state = await ObjectFactory()
        .repository
        .getExpenseSummary(category: category);
    if (state is SuccessState) {
      getExpenseSummarySink.add(state.value);
    } else if (state is ErrorState) {
      getExpenseSummarySink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  ///disposing the stream if it is not using
  @override
  void dispose() {
    _loading.close();
    _fetchCurrentBudget.close();
    _updateCurrentBudget.close();
    _addExpense.close();
    _editExpense.close();
    _deleteExpense.close();
    _getExpenses.close();
    _getExpenseSummary.close();
  }
}
