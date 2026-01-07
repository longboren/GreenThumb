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
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _searchCtrl.addListener(() {
      setState(() {
        _search = _searchCtrl.text.toLowerCase();
      });
    });
  }

  Future<void> _loadPlants() async {
    final raw = await _plantStorage.readList();
    setState(() {
      _plants = raw
          .map((e) => Plant.fromJson(e as Map<String, dynamic>))
          .toList();
    });
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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_florist, size: 22),
            const SizedBox(width: 8),
            const Text('GreenThumb'),
          ],
        ),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search plants',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final filtered = _search.isEmpty
                      ? _plants
                      : _plants
                            .where(
                              (p) => p.name.toLowerCase().contains(_search),
                            )
                            .toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 48),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_florist,
                                size: 72,
                                color: Colors.green[300],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _plants.isEmpty
                                    ? 'No plants yet — add one with +'
                                    : 'No plants match "${_searchCtrl.text}"',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      final u = calculateUrgency(
                        lastWatered: p.lastWatered,
                        intervalDays: p.wateringIntervalDays,
                      );
                      final iconColor = u == Urgency.high
                          ? Colors.red
                          : (u == Urgency.medium
                                ? Colors.orange
                                : Colors.green);
                      final nextDue = (p.lastWatered == null)
                          ? DateTime.now()
                          : p.lastWatered!.add(
                              Duration(days: p.wateringIntervalDays),
                            );
                      final daysUntil = nextDue
                          .difference(DateTime.now())
                          .inDays;
                      final nextText = daysUntil <= 0
                          ? 'Due today'
                          : 'Due in $daysUntil day${daysUntil == 1 ? '' : 's'}';
                      final subtitleText =
                '${p.species ?? '—'}${p.tags != null && p.tags!.isNotEmpty ? ' • ${p.tags!.join(", ")}' : ''} • Interval: ${p.wateringIntervalDays}d • $nextText';

                      final tileColor = u == Urgency.high
                          ? Colors.red.withAlpha((0.06 * 255).round())
                          : (u == Urgency.medium
                                ? Colors.orange.withAlpha((0.06 * 255).round())
                                : Colors.green.withAlpha((0.06 * 255).round()));

                      return Card(
                        color: tileColor,
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () async {
                            // open edit/view in future — for now navigate to add as placeholder
                            await Navigator.pushNamed(context, '/add');
                            await _loadPlants();
                          },
                          child: ListTile(
                            title: Text(
                              p.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.black87),
                            ),
                            subtitle: Text(
                              subtitleText,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.black54),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: iconColor.withAlpha(
                                (0.12 * 255).round(),
                              ),
                              child: Icon(
                                Icons.local_florist,
                                color: iconColor,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.water_drop,
                                    color: iconColor,
                                  ),
                                  onPressed: () => _waterPlant(p),
                                  tooltip: 'Water Plant',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => _deletePlant(p),
                                  tooltip: 'Delete Plant',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          await _loadPlants();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
