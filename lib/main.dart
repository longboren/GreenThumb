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
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.green);

    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);

    return MaterialApp(
      title: 'GreenThumb',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: base.textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textTheme: base.textTheme.copyWith(
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16),
        ),
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
