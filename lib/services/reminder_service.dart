import '../models/plant.dart';

class ReminderItem {
  final Plant plant;
  final DateTime dueDate;
  final int daysUntil;

  ReminderItem({required this.plant, required this.dueDate, required this.daysUntil});
}

/// Computes reminder items for plants.
/// A plant's next due date is lastWatered + wateringIntervalDays, or now if never watered.
class ReminderService {
  /// Returns plants that are due within [withinDays]. If withinDays is 0, returns only today/overdue.
  List<ReminderItem> dueSoon(List<Plant> plants, {int withinDays = 3}) {
    final now = DateTime.now();
    final results = <ReminderItem>[];

    for (final p in plants) {
      final last = p.lastWatered;
      final due = (last == null) ? now : last.add(Duration(days: p.wateringIntervalDays));
      final daysUntil = due.difference(now).inDays;
      if (daysUntil <= withinDays) {
        results.add(ReminderItem(plant: p, dueDate: due, daysUntil: daysUntil));
      }
    }

    results.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return results;
  }
}
