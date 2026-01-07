import 'dart:convert';

class CareLog {
  String id;
  String plantId;
  DateTime when;
  String action; // e.g., "watered"
  String? notes;

  CareLog({
    required this.id,
    required this.plantId,
    required this.when,
    this.action = 'watered',
    this.notes,
  });

  factory CareLog.fromJson(Map<String, dynamic> json) => CareLog(
        id: json['id'] as String,
        plantId: json['plantId'] as String,
        when: DateTime.parse(json['when'] as String),
        action: json['action'] as String? ?? 'watered',
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'plantId': plantId,
        'when': when.toIso8601String(),
        'action': action,
        'notes': notes,
      };

  @override
  String toString() => jsonEncode(toJson());
}
