import 'package:expense_tracker/src/bloc/expense_bloc.dart';
import 'package:expense_tracker/src/models/summary_response_model.dart';
import 'package:expense_tracker/src/widgets/build_custom_appbar_widget.dart';
import 'package:expense_tracker/src/widgets/build_loading_widget.dart';
import 'package:expense_tracker/src/widgets/build_summary_list_item_widget.dart';
import 'package:flutter/material.dart';

class ShowSummaryScreen extends StatefulWidget {
  const ShowSummaryScreen({super.key});

  @override
  State<ShowSummaryScreen> createState() => _ShowSummaryScreenState();
}

class _ShowSummaryScreenState extends State<ShowSummaryScreen> {
  final ExpenseBloc expenseBlocForFood = ExpenseBloc();
  final ExpenseBloc expenseBlocForTravel = ExpenseBloc();
  final ExpenseBloc expenseBlocForShopping = ExpenseBloc();
  final ExpenseBloc expenseBlocForHealth = ExpenseBloc();
  final ExpenseBloc expenseBlocForEntertainment = ExpenseBloc();
  final ExpenseBloc expenseBlocForOthers = ExpenseBloc();

  bool isLoading = true;
  SummaryResponseModel? summaryResponseModelOfFood;
  SummaryResponseModel? summaryResponseModelOfTravel;
  SummaryResponseModel? summaryResponseModelOfShopping;
  SummaryResponseModel? summaryResponseModelOfHealth;
  SummaryResponseModel? summaryResponseModelOfEntertainment;
  SummaryResponseModel? summaryResponseModelOfOthers;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    _fetchSummary(expenseBlocForFood, "Food", (data) {
      summaryResponseModelOfFood = data;
    });
    _fetchSummary(expenseBlocForTravel, "Travel", (data) {
      summaryResponseModelOfTravel = data;
    });
    _fetchSummary(expenseBlocForShopping, "Shopping", (data) {
      summaryResponseModelOfShopping = data;
    });
    _fetchSummary(expenseBlocForHealth, "Health", (data) {
      summaryResponseModelOfHealth = data;
    });
    _fetchSummary(expenseBlocForEntertainment, "Entertainment", (data) {
      summaryResponseModelOfEntertainment = data;
    });
    _fetchSummary(expenseBlocForOthers, "Others", (data) {
      summaryResponseModelOfOthers = data;
    });
  }

  void _fetchSummary(ExpenseBloc bloc, String category,
      Function(SummaryResponseModel) onData) {
    bloc.getExpenseSummary(category: category);
    bloc.getExpenseSummaryResponse.listen((event) {
      print("RESPONSE FOR $category SUMMARY: $event");
      setState(() {
        onData(event);
        _checkLoadingState();
      });
    }).onError((error) {
      setState(() {
        _checkLoadingState();
      });
    });
  }

  void _checkLoadingState() {
    if (summaryResponseModelOfFood != null &&
        summaryResponseModelOfTravel != null &&
        summaryResponseModelOfShopping != null &&
        summaryResponseModelOfHealth != null &&
        summaryResponseModelOfEntertainment != null &&
        summaryResponseModelOfOthers != null) {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BuildCustomAppBarWidget(
        title: "Spends",
        showBackButton: true,
      ),
      body: isLoading
          ? const Center(child: BuildLoadingWidget())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (summaryResponseModelOfFood != null)
                    BuildSummaryListItemWidget(
                        summary: summaryResponseModelOfFood!),
                  if (summaryResponseModelOfTravel != null)
                    BuildSummaryListItemWidget(
                        summary: summaryResponseModelOfTravel!),
                  if (summaryResponseModelOfShopping != null)
                    BuildSummaryListItemWidget(
                        summary: summaryResponseModelOfShopping!),
                  if (summaryResponseModelOfHealth != null)
                    BuildSummaryListItemWidget(
                        summary: summaryResponseModelOfHealth!),
                  if (summaryResponseModelOfEntertainment != null)
                    BuildSummaryListItemWidget(
                        summary: summaryResponseModelOfEntertainment!),
                  if (summaryResponseModelOfOthers != null)
                    BuildSummaryListItemWidget(
                        summary: summaryResponseModelOfOthers!),
                ],
              ),
            ),
    );
  }
}
