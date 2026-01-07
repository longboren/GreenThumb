import '../models/plant.dart';
import '../models/care_log.dart';
import 'storage.dart';

class LogService {
  final Storage plantStorage = Storage('plants.json');
  final Storage logStorage = Storage('logs.json');

  Future<void> createCareLog({
    required Plant plant,
    String action = 'watered',
    String? notes,
  }) async {
    final logsRaw = await logStorage.readList();
    final logs = logsRaw
        .map((e) => CareLog.fromJson(e as Map<String, dynamic>))
        .toList();

    final newLog = CareLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plantId: plant.id,
      when: DateTime.now(),
      action: action,
      notes: notes,
    );

    logs.insert(0, newLog);
    await logStorage.writeList(logs.map((e) => e.toJson()).toList());

    // update plant lastWatered
    final plantsRaw = await plantStorage.readList();
    final plants = plantsRaw
        .map((e) => Plant.fromJson(e as Map<String, dynamic>))
        .toList();
    final idx = plants.indexWhere((p) => p.id == plant.id);
    if (idx != -1) {
      plants[idx].lastWatered = DateTime.now();
      await plantStorage.writeList(plants.map((p) => p.toJson()).toList());
    }
  }
}
