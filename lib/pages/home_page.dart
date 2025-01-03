import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trabalho_pratico_flutter/pages/recent_page.dart';
import 'add_contact_page.dart';
import 'edit_contact_page.dart';
import 'map_page.dart';
import '/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contactsJson = prefs.getString('contacts');
    if (contactsJson != null) {
      final List<dynamic> decoded = jsonDecode(contactsJson);
      setState(() {
        contacts = decoded.map((item) => Contact.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(contacts.map((c) => c.toJson()).toList());
    await prefs.setString('contacts', encoded);
  }

  void _addContact(Contact contact) {
    setState(() {
      contacts.add(contact);
      _updateRecentContacts(contact);
    });
    _saveContacts();
  }

  Future<void> _updateRecentContacts(Contact contact) async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentJson = prefs.getString('recent_contacts');
    List<Contact> recentContacts = [];

    if (recentJson != null) {
      final List<dynamic> decoded = jsonDecode(recentJson);
      recentContacts = decoded.map((item) => Contact.fromJson(item)).toList();
    }

    // Adiciona o novo contato e limita a lista a 10 itens
    recentContacts.insert(0, contact);
    if (recentContacts.length > 10) {
      recentContacts = recentContacts.sublist(0, 10);
    }

    // Salva os contatos recentes
    final String updatedJson = jsonEncode(recentContacts.map((c) => c.toJson()).toList());
    await prefs.setString('recentSI_contacts', updatedJson);
  }

  void _editContact(int index, Contact updatedContact) {
    setState(() {
      contacts[index] = updatedContact;
    });
    _saveContacts();
  }

  void _deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
    });
    _saveContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contactos'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'Últimos Contatos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecentPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddContactPage(
                    onSave: _addContact,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditContactPage(
                      onSave: (updatedContact) => _editContact(index, updatedContact),
                      contact: contact,
                      onDelete: () => _deleteContact(index),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.2,
                      margin: EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: contact.imagePath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(contact.imagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                          : Center(
                        child: Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(contact.email, style: TextStyle(fontSize: 14, color: Colors.grey)),
                          SizedBox(height: 8),
                          Text(contact.phone, style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.map, color: Colors.blue),
                      onPressed: contact.location != null
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(location: contact.location!),
                          ),
                        );
                      }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
