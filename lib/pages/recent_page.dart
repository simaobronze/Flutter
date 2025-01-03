import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '/main.dart';

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});

  @override
  RecentPageState createState() => RecentPageState();
}

class RecentPageState extends State<RecentPage> {
  List<Contact> recentContacts = [];

  @override
  void initState() {
    super.initState();
    _loadRecentContacts();
  }

  Future<void> _loadRecentContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentJson = prefs.getString('recent_contacts');
    if (recentJson != null) {
      final List<dynamic> decoded = jsonDecode(recentJson);
      setState(() {
        recentContacts = decoded.map((item) => Contact.fromJson(item)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Últimos Contatos'),
      ),
      body: ListView.builder(
        itemCount: recentContacts.length,
        itemBuilder: (context, index) {
          final contact = recentContacts[index];
          return ListTile(
            leading: contact.imagePath != null
                ? CircleAvatar(
              backgroundImage: FileImage(File(contact.imagePath!)),
            )
                : CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(contact.name),
            subtitle: Text(contact.email),
          );
        },
      ),
    );
  }
}
