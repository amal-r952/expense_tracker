import 'package:expense_tracker/src/screens/add_expense_screen.dart';
import 'package:expense_tracker/src/screens/view_expenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/src/theme/app_theme/app_theme_data.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.bottomNavigationBg,
      ),
    );
    return MaterialApp(
      title: 'Car Rental',
      darkTheme: AppThemeData.darkTheme,
      debugShowCheckedModeBanner: false,
      theme: AppThemeData.lightTheme,
      themeMode: ThemeMode.system,
      home: ViewExpensesScreen(),
    );
  }
}
