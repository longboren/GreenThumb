import 'package:flutter/material.dart';

import 'screens/dashboard.dart';
import 'screens/add_plant.dart';
import 'screens/history.dart';
import 'screens/reminders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenThumb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/add': (context) => const AddPlantScreen(),
        '/history': (context) => const HistoryScreen(),
        '/reminders': (context) => const RemindersScreen(),
      },
    );
  }
}
