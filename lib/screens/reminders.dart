import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../services/storage.dart';
import '../services/reminder_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final Storage _plantStorage = Storage('plants.json');
  final ReminderService _reminderService = ReminderService();
  List<Plant> _plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final raw = await _plantStorage.readList();
    setState(() {
      _plants = raw
          .map((e) => Plant.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final due = _reminderService.dueSoon(_plants, withinDays: 3);
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: RefreshIndicator(
        onRefresh: _loadPlants,
        child: due.isEmpty
            ? ListView(
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No reminders'),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                itemCount: due.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = due[i];
                  final days = r.daysUntil;
                  final whenText = days <= 0
                      ? 'Due today'
                      : 'Due in $days day${days == 1 ? '' : 's'}';
                  return ListTile(
                    title: Text(r.plant.name),
                    subtitle: Text(whenText),
                    trailing: Text('${r.dueDate.toLocal()}'.split(' ')[0]),
                  );
                },
              ),
      ),
    );
  }
}
