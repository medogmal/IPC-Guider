import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/storage/hive_boxes.dart';
import 'features/calculator/data/calculator_repository.dart';
import 'features/outbreak/data/repositories/history_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBoxes.init(); // open basic Hive boxes
  await CalculatorRepository().initialize(); // initialize calculator storage
  await HistoryRepository().initialize(); // initialize history storage
  runApp(const ProviderScope(child: IpcApp()));
}
