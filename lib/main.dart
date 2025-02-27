import 'package:expense_tracker/src/app.dart';
import 'package:expense_tracker/src/models/expense_model.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:device_preview/device_preview.dart';

import 'package:path_provider/path_provider.dart' as pathProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Expense>('expenses');
   Box box;
  var dir = await pathProvider.getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  box = await Hive.openBox(
    Constants.BOX_NAME,
  );

  runApp(DevicePreview(
    enabled: false,
    builder: (context) {
      return MyApp();
    },
  ));
}
