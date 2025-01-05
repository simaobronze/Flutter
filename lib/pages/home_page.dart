import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trabalho_pratico_flutter/pages/recent_page.dart';
import '../file_storage.dart';
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
  Map<int, bool> expandedState = {}; // Armazena o estado expandido de cada contato

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // Função para alternar o estado expandido
  void _toggleExpanded(int index) {
    setState(() {
      expandedState[index] = !(expandedState[index] ?? false);
    });
  }

  Future<void> _loadContacts() async {
    contacts = await FileStorage.loadContacts();
    setState(() {});
  }

  Future<void> _saveContacts() async {
    await FileStorage.saveContacts(contacts);
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
          final isExpanded = expandedState[index] ?? false;
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  onTap: () => _toggleExpanded(index), // Alterna a expansão ao clicar
                  leading: contact.imagePath != null
                      ? CircleAvatar(
                    backgroundImage: FileImage(File(contact.imagePath!)),
                  )
                      : CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(contact.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(contact.email),
                  trailing: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more, // Ícone de expansão
                  ),
                ),
                if (isExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Telefone: ${contact.phone}", style: TextStyle(fontSize: 14)),
                        if (contact.location != null)
                          Text("Localização: ${contact.location}", style: TextStyle(fontSize: 14)),
                        if (contact.birthDate != null)
                          Text(
                            "Data de Nascimento: ${DateFormat.yMd().format(contact.birthDate!)}",
                            style: TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
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
                        child: Text('EDITAR'),
                      ),
                      TextButton(
                        onPressed: () => _deleteContact(index),
                        child: Text('REMOVER'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
