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
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.notifications_active,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text('No reminders', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.separated(
                itemCount: due.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final r = due[i];
                  final days = r.daysUntil;
                  final whenText = days <= 0
                      ? 'Due today'
                      : 'Due in $days day${days == 1 ? '' : 's'}';
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.local_florist, size: 20),
                      ),
                      title: Text(r.plant.name),
                      subtitle: Text(whenText),
                      trailing: Text(
                        '${r.dueDate.toLocal()}'.split(' ')[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
