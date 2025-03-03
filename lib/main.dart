import 'package:expense_tracker/firebase_options.dart';
import 'package:expense_tracker/src/app.dart';
import 'package:expense_tracker/src/models/expense_model.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:device_preview/device_preview.dart';

import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///
  await Hive.initFlutter();

  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Expense>('expenses');

  ///
  Box box;
  var dir = await pathProvider.getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  box = await Hive.openBox(
    Constants.BOX_NAME,
  );
  try{
  await Supabase.initialize(
    url: "https://bnbsxstdgnypjnvsxack.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJuYnN4c3RkZ255cGpudnN4YWNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwMDIwODYsImV4cCI6MjA1NjU3ODA4Nn0.udbBhcn4rsD6_4Uza3QIPXy9O1uIexSvzLTyJm4TFYc",
  );} catch (e) {
    print('Error initializing Supabase: $e');
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(DevicePreview(
    enabled: false,
    builder: (context) {
      return MyApp();
    },
  ));
}
