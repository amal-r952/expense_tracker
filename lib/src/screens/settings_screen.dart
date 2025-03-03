import 'package:expense_tracker/src/screens/choose_currency_screen.dart';
import 'package:expense_tracker/src/screens/login_screen.dart';
import 'package:expense_tracker/src/screens/set_budget_screen.dart';
import 'package:expense_tracker/src/screens/show_summary_screen.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/build_cached_network_image_widget.dart';
import 'package:expense_tracker/src/widgets/build_custom_appbar_widget.dart';
import 'package:expense_tracker/src/widgets/build_elevated_button.dart';
import 'package:expense_tracker/src/widgets/build_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BuildCustomAppBarWidget(
        title: "Settings",
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: BuildCachedNetworkImageWidget(
                imageUrl: ObjectFactory().appHive.getUserProfileImage()!,
                boxShape: BoxShape.circle,
                boxFit: BoxFit.contain,
                height: 100,
                width: 100,
                placeHolder: const SizedBox(
                    height: 50, width: 50, child: BuildLoadingWidget()),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              ObjectFactory().appHive.getUserProfileName()!,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              ObjectFactory().appHive.getUserProfileEmail()!,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              "User since ${formatTime(ObjectFactory().appHive.getAccountCreatedTime()!)}",
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w400, fontSize: 14),
            ),
            const Spacer(),
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: BuildElevatedButton(
                      backgroundColor: AppColors.primaryColorOrange,
                      width: screenWidth(context),
                      height: screenHeight(context, dividedBy: 18),
                      child: null,
                      txt: "SET BUDGET",
                      onTap: () {
                        push(context, const SetBudgetScreen());
                      }),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: BuildElevatedButton(
                      backgroundColor:
                          AppColors.primaryColorOrange.withOpacity(0.5),
                      width: screenWidth(context),
                      height: screenHeight(context, dividedBy: 18),
                      child: null,
                      txt: "ACCOUNT SUMMARY",
                      onTap: () {
                        push(context, const ShowSummaryScreen());
                      }),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: BuildElevatedButton(
                      backgroundColor: AppColors.accentColorDark,
                      width: screenWidth(context),
                      height: screenHeight(context, dividedBy: 18),
                      child: null,
                      txt: "CHOOSE CURRENCY",
                      onTap: () {
                        push(context, const ChooseCurrencyScreen());
                      }),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: BuildElevatedButton(
                      backgroundColor: AppColors.primaryColorRed,
                      width: screenWidth(context),
                      height: screenHeight(context, dividedBy: 18),
                      child: null,
                      txt: "LOG OUT",
                      onTap: () async {
                        await ObjectFactory().auth.signOut();
                        await GoogleSignIn().signOut();
                        ObjectFactory().appHive.clearHive();
                        pushAndRemoveUntil(context, LoginScreen(), false);
                      }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
