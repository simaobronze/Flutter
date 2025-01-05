import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class FileStorage {
  static Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/contacts.json";
  }

  static Future<void> saveContacts(List<Contact> contacts) async {
    final filePath = await _getFilePath();
    final file = File(filePath);
    final contactsJson = contacts.map((contact) => contact.toJson()).toList();
    await file.writeAsString(jsonEncode(contactsJson));
  }

  static Future<List<Contact>> loadContacts() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        return jsonList.map((item) => Contact.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Erro ao carregar contatos: $e");
      return [];
    }
  }
}
