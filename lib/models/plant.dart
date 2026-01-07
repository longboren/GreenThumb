import 'dart:convert';

class Plant {
  String id;
  String name;
  String? species;
  List<String>? tags;
  int wateringIntervalDays; // recommended interval
  DateTime? lastWatered;

  Plant({
    required this.id,
    required this.name,
    this.species,
    this.tags,
    this.wateringIntervalDays = 7,
    this.lastWatered,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    id: json['id'] as String,
    name: json['name'] as String,
    species: json['species'] as String?,
    wateringIntervalDays: json['wateringIntervalDays'] as int? ?? 7,
    lastWatered: json['lastWatered'] == null
        ? null
        : DateTime.parse(json['lastWatered'] as String),
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'wateringIntervalDays': wateringIntervalDays,
    'lastWatered': lastWatered?.toIso8601String(),
    'tags': tags,
  };

  @override
  String toString() => jsonEncode(toJson());
}
