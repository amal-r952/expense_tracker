import 'package:flutter/material.dart';
import 'package:expense_tracker/src/theme/widget_theme/app_bar_theme.dart';
import 'package:expense_tracker/src/theme/widget_theme/text_theme.dart';
import 'package:expense_tracker/src/utils/app_colors.dart';

final ThemeData lightThemeData = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryColorLight,
    secondary: AppColors.accentColorLight,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.primaryColorLight,
  textTheme: lightTextTheme,
  cardColor: AppColors.lightGrey,
  shadowColor: AppColors.primaryColorGreen,
  dividerColor: AppColors.darkGrey,
  appBarTheme: lightAppBarTheme,
);
