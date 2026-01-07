import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../services/storage.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController();
  final _intervalCtrl = TextEditingController(text: '7');
  final Storage _plantStorage = Storage('plants.json');

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final plant = Plant(
      id: id,
      name: _nameCtrl.text.trim(),
      species: _speciesCtrl.text.trim().isEmpty
          ? null
          : _speciesCtrl.text.trim(),
      wateringIntervalDays: int.tryParse(_intervalCtrl.text) ?? 7,
    );

    final raw = await _plantStorage.readList();
    final plants = raw
        .map((e) => Plant.fromJson(e as Map<String, dynamic>))
        .toList();
    plants.add(plant);
    await _plantStorage.writeList(plants.map((p) => p.toJson()).toList());
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Plant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _speciesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Species (optional)',
                ),
              ),
              TextFormField(
                controller: _intervalCtrl,
                decoration: const InputDecoration(
                  labelText: 'Watering interval (days)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
