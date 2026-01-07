import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../services/storage.dart';
import '../services/urgency.dart';
import '../services/log_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Storage _plantStorage = Storage('plants.json');
  final LogService _logService = LogService();
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

  Widget _urgencyChip(Plant p) {
    final u = calculateUrgency(
      lastWatered: p.lastWatered,
      intervalDays: p.wateringIntervalDays,
    );
    final color = u == Urgency.high
        ? Colors.red
        : (u == Urgency.medium ? Colors.orange : Colors.green);
    final text = u == Urgency.high
        ? 'High'
        : (u == Urgency.medium ? 'Medium' : 'Low');
    return Chip(
      label: Text(text, style: TextStyle(color: color)),
      backgroundColor: color.withAlpha((0.12 * 255).round()),
      side: BorderSide(color: color.withAlpha((0.25 * 255).round())),
    );
  }

  Future<void> _waterPlant(Plant p) async {
    await _logService.createCareLog(plant: p);
    await _loadPlants();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Plant watered')));
  }

  Future<void> _deletePlant(Plant p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete plant'),
        content: Text(
          'Delete "${p.name}" and its care logs? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    // remove plant
    final plantsRaw = await _plantStorage.readList();
    final plants = plantsRaw
        .map((e) => Plant.fromJson(e as Map<String, dynamic>))
        .where((pl) => pl.id != p.id)
        .toList();
    await _plantStorage.writeList(plants.map((pl) => pl.toJson()).toList());

    // remove associated logs
    final logStorage = Storage('logs.json');
    final logsRaw = await logStorage.readList();
    final filtered = logsRaw.where((e) {
      try {
        final m = e as Map<String, dynamic>;
        return m['plantId'] != p.id;
      } catch (_) {
        return true;
      }
    }).toList();
    await logStorage.writeList(filtered);

    await _loadPlants();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${p.name} deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenThumb'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/reminders'),
            tooltip: 'Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
            tooltip: 'View History',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlants,
        child: _plants.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'No plants yet — add one with +',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: _plants.length,
                itemBuilder: (context, i) {
                  final p = _plants[i];
                  final u = calculateUrgency(
                    lastWatered: p.lastWatered,
                    intervalDays: p.wateringIntervalDays,
                  );
                  final iconColor = u == Urgency.high
                      ? Colors.red
                      : (u == Urgency.medium ? Colors.orange : Colors.green);
                  final nextDue = (p.lastWatered == null)
                      ? DateTime.now()
                      : p.lastWatered!.add(
                          Duration(days: p.wateringIntervalDays),
                        );
                  final daysUntil = nextDue.difference(DateTime.now()).inDays;
                  final nextText = daysUntil <= 0
                      ? 'Due today'
                      : 'Due in $daysUntil day${daysUntil == 1 ? '' : 's'}';
                  final subtitleText =
                      '${p.species ?? '—'} • Interval: ${p.wateringIntervalDays}d • $nextText';

                  final tileColor = u == Urgency.high
                      ? Colors.red.withAlpha((0.06 * 255).round())
                      : (u == Urgency.medium
                            ? Colors.orange.withAlpha((0.06 * 255).round())
                            : Colors.green.withAlpha((0.06 * 255).round()));

                  return Card(
                    color: tileColor,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(
                        p.name,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      subtitle: Text(
                        subtitleText,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      leading: _urgencyChip(p),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.water_drop, color: iconColor),
                            onPressed: () => _waterPlant(p),
                            tooltip: 'Water Plant',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => _deletePlant(p),
                            tooltip: 'Delete Plant',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          await _loadPlants();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
