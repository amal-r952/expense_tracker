import 'package:expense_tracker/src/bloc/currency_bloc.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/app_toast.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/font_family.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/build_custom_appbar_widget.dart';
import 'package:expense_tracker/src/widgets/build_custom_dropdown_widget.dart';
import 'package:expense_tracker/src/widgets/build_elevated_button.dart';
import 'package:expense_tracker/src/widgets/build_loading_widget.dart';
import 'package:expense_tracker/src/widgets/build_svg_icon.dart';
import 'package:flutter/material.dart';

class ChooseCurrencyScreen extends StatefulWidget {
  const ChooseCurrencyScreen({super.key});

  @override
  State<ChooseCurrencyScreen> createState() => _ChooseCurrencyScreenState();
}

class _ChooseCurrencyScreenState extends State<ChooseCurrencyScreen> {
  bool isFetchingCurrencyStatus = false;
  String selectedCurrencyCode = "INR";
  CurrencyBloc currencyBloc = CurrencyBloc();

  @override
  void initState() {
    currencyBloc.fetchCurrencyRatesResponse.listen((event) async {
      print("FETCHING CURRENCY RATES RESPONSE: $event");
      if (event != null) {
        await ObjectFactory()
            .appHive
            .putCurrentCurrency(currentCurrency: selectedCurrencyCode);
        await ObjectFactory().appHive.putCurrentCurrencyValue(
            currentCurrencyValue: event.rates[selectedCurrencyCode]!);
        AppToasts.showSuccessToastTop(
            context, "Currency rates updated successfully!");
        setState(() {
          isFetchingCurrencyStatus = false;
        });
      }
    }).onError((error) {
      print("ERROR: $error");
      setState(() {
        isFetchingCurrencyStatus = false;
      });
      AppToasts.showErrorToastTop(
          context, "Failed to fetch currency rates!, Please try again later.");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BuildCustomAppBarWidget(
        title: "Choose currency",
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current currency: ${ObjectFactory().appHive.getCurrentCurrency()}",
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(height: 30),
              Text(
                "1 INR = ${ObjectFactory().appHive.getCurrentCurrencyValue()} ${ObjectFactory().appHive.getCurrentCurrency()}",
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w300, fontSize: 15),
              ),
              const SizedBox(height: 20),
              BuildCustomDropdownWidget(
                  dropDownItems: Constants.currencies,
                  onChanged: (currency) {
                    print("SELECTED CURRENCY: $currency");
                    setState(() {
                      selectedCurrencyCode =
                          currency.substring(0, 3).toUpperCase();
                    });
                    print("SELECTED CURRENCY CODE: $selectedCurrencyCode");
                  }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: BuildElevatedButton(
            backgroundColor: AppColors.primaryColorOrange,
            width: screenWidth(context),
            height: screenHeight(context, dividedBy: 18),
            txt: "APPLY",
            onTap: () {
              if (!isFetchingCurrencyStatus) {
                setState(() {
                  isFetchingCurrencyStatus = true;
                });
                currencyBloc.fetchCurrencyRates(
                    currencyCode: selectedCurrencyCode);
              }
            },
            child: isFetchingCurrencyStatus
                ? const BuildLoadingWidget(
                    color: Colors.white,
                  )
                : Text(
                    "APPLY",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontFamily.gothamBook,
                          color: AppColors.primaryColorLight,
                        ),
                  )),
      ),
    );
  }
}
