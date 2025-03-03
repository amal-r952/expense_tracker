import 'package:expense_tracker/src/bloc/user_auth_bloc.dart';
import 'package:expense_tracker/src/bloc/user_bloc.dart';
import 'package:expense_tracker/src/screens/view_expenses_screen.dart';
import 'package:expense_tracker/src/utils/app_assets.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';
import 'package:expense_tracker/src/utils/font_family.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:expense_tracker/src/widgets/build_elevated_button.dart';
import 'package:expense_tracker/src/widgets/build_loading_widget.dart';
import 'package:expense_tracker/src/widgets/build_svg_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserAuthBloc userAuthBloc = UserAuthBloc();
  UserBloc userBloc = UserBloc();
  bool isLoggingIn = false;
  bool isSavingUserDataToFirebase = false;

  saveUserDataToHive(UserCredential event) async {
    print("SAVING USER DATA TO HIVE");
    await ObjectFactory().appHive.putIsLoggedIn(isLoggedIn: true);
    await ObjectFactory().appHive.putUserId(userId: event.user!.uid);
    await ObjectFactory()
        .appHive
        .putUserProfileEmail(userEmail: event.user!.email!);
    await ObjectFactory()
        .appHive
        .putUserProfileName(userProfileName: event.user!.displayName!);
    await ObjectFactory()
        .appHive
        .putUserProfileImage(imageUrl: event.user!.photoURL!);

    await ObjectFactory()
        .appHive
        .putCurrentCurrency(currentCurrency: "INR");
           await ObjectFactory()
        .appHive
        .putCurrentCurrencyValue(currentCurrencyValue: 1);
  }

  saveUserDataToFirebase(UserCredential event) async {
    print("SAVING USER DATA TO FIREBASE");
    userBloc.addUserDataToFirebase(userId: event.user!.uid);
    setState(() {
      isSavingUserDataToFirebase = true;
    });
  }

  @override
  void initState() {
    userAuthBloc.signInWithGoogleResponse.listen((event) {
      print("UID: ${event.user!.uid}");
      print("USERNAME: ${event.user!.displayName}");
      print("EMAIL: ${event.user!.email}");
      print("PHOTO URL: ${event.user!.photoURL}");

      saveUserDataToHive(event);
      saveUserDataToFirebase(event);

      setState(() {
        isLoggingIn = false;
      });
    }).onError((error, stackTrace) {
      print("ERROR: $error");
      print("STACKTRACE: $stackTrace");
      setState(() {
        isLoggingIn = false;
      });
    });
    userBloc.addUserDataToFirebaseResponse.listen((event) {
      print("USER DATA SAVED TO FIREBASE: $event");
      ObjectFactory()
          .appHive
          .putAccountCreatedTime(accountCreatedTime: event.accountCreatedTime!);
      setState(() {
        isSavingUserDataToFirebase = false;
      });

      pushAndReplacement(context, ViewExpensesScreen());
    }).onError((error, stackTrace) {
      print("ERROR: $error");
      print("STACKTRACE: $stackTrace");
      setState(() {
        isSavingUserDataToFirebase = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BuildSvgIcon(
          assetImagePath: AppAssets.appLogo,
          iconWidth: screenWidth(context, dividedBy: 1.5),
          iconHeight: screenWidth(context, dividedBy: 1.5),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        child: BuildElevatedButton(
            borderRadiusBottomLeft: 45,
            borderRadiusBottomRight: 45,
            borderRadiusTopLeft: 45,
            borderRadiusTopRight: 45,
            backgroundColor: AppColors.primaryColorOrange,
            width: screenWidth(
              context,
            ),
            height: screenHeight(context, dividedBy: 18),
            txt: " ",
            onTap: () {
              userAuthBloc.signInWithGoogle();
              setState(() {
                isLoggingIn = true;
              });
            },
            child: isLoggingIn || isSavingUserDataToFirebase
                ? const BuildLoadingWidget(
                    color: Colors.white,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const BuildSvgIcon(
                        assetImagePath: AppAssets.googleIcon,
                        iconWidth: 30,
                        iconHeight: 30,
                      ),
                      const SizedBox(width: 30),
                      Text(
                        "SIGN IN WITH GOOGLE",
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.gothamBook,
                                  color: AppColors.primaryColorLight,
                                ),
                      ),
                    ],
                  )),
      ),
    );
  }
}
