import 'package:denomination/screens/history_screen.dart';
import 'package:denomination/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

import 'calculation_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CalculationModelAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      title: 'Denomination Calculator',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MainScreen()),
        GetPage(name: '/history', page: () => HistoryScreen()),
      ],
    );
  }
}
