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
  final _tagsCtrl = TextEditingController();
  final Storage _plantStorage = Storage('plants.json');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _intervalCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

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
      tags: _tagsCtrl.text.trim().isEmpty
          ? null
          : _tagsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Plant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.local_florist),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _speciesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Species (optional)',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tagsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)',
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _intervalCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Watering interval (days)',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) {
                        return 'Enter a valid number of days';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
