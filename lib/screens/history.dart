import 'package:flutter/material.dart';

import '../models/care_log.dart';
import '../services/storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Storage _logStorage = Storage('logs.json');
  List<CareLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final raw = await _logStorage.readList();
    setState(() {
      _logs = raw
          .map((e) => CareLog.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Care History')),
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        child: _logs.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No logs yet', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.separated(
                itemCount: _logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final l = _logs[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          l.action.isNotEmpty ? l.action[0].toUpperCase() : '?',
                        ),
                      ),
                      title: Text('${l.action} — ${l.plantId}'),
                      subtitle: Text(l.notes ?? ''),
                      trailing: Text(
                        '${l.when.toLocal()}'.split('.')[0],
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
