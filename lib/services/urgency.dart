enum Urgency { low, medium, high }

Urgency calculateUrgency({
  required DateTime? lastWatered,
  required int intervalDays,
}) {
  if (lastWatered == null) return Urgency.high;
  final daysSince = DateTime.now().difference(lastWatered).inDays;
  if (daysSince >= intervalDays * 2) return Urgency.high;
  if (daysSince >= intervalDays) return Urgency.medium;
  return Urgency.low;
}
