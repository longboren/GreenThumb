import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Storage {
  final String fileName;

  Storage(this.fileName);

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<List<dynamic>> readList() async {
    try {
      final file = await _localFile();
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final decoded = jsonDecode(contents) as List<dynamic>;
      return decoded;
    } catch (e) {
      return [];
    }
  }

  Future<void> writeList(List<dynamic> data) async {
    final file = await _localFile();
    await file.writeAsString(jsonEncode(data));
  }
}
