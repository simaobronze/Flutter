import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ContactsApp());
}

class Contact {
  final String name;
  final String email;
  final String phone;
  final String? imagePath;
  final String? location;
  final DateTime? birthDate; // Novo campo opcional

  Contact({
    required this.name,
    required this.email,
    required this.phone,
    this.imagePath,
    this.location,
    this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imagePath': imagePath,
      'location': location,
      'birthDate': birthDate?.toIso8601String(), // Salva a data como string ISO
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      imagePath: json['imagePath'],
      location: json['location'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate']) // Converte a string ISO de volta para DateTime
          : null,
    );
  }
}

Future<void> updateRecentContacts(Contact contact) async {
  final prefs = await SharedPreferences.getInstance();
  final String? recentJson = prefs.getString('recent_contacts');
  List<Contact> updatedRecentContacts = [];

  if (recentJson != null) {
    final List<dynamic> decoded = jsonDecode(recentJson);
    updatedRecentContacts = decoded.map((item) => Contact.fromJson(item)).toList();
  }

  updatedRecentContacts.removeWhere((c) => c.name == contact.name);
  updatedRecentContacts.insert(0, contact);

  if (updatedRecentContacts.length > 10) {
    updatedRecentContacts = updatedRecentContacts.sublist(0, 10);
  }

  final String updatedJson = jsonEncode(updatedRecentContacts.map((c) => c.toJson()).toList());
  await prefs.setString('recent_contacts', updatedJson);
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contactos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}