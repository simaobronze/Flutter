import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/main.dart';
import 'map_page.dart';
import 'package:intl/intl.dart';

class EditContactPage extends StatefulWidget {
  final Function(Contact) onSave;
  final Contact contact;
  final VoidCallback onDelete;

  const EditContactPage({super.key, required this.onSave, required this.contact, required this.onDelete});

  @override
  EditContactPageState createState() => EditContactPageState();
}

class EditContactPageState extends State<EditContactPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String email;
  late String phone;
  String? imagePath;
  String? location;
  DateTime? birthDate;

  @override
  void initState() {
    super.initState();
    name = widget.contact.name;
    email = widget.contact.email;
    phone = widget.contact.phone;
    imagePath = widget.contact.imagePath;
    location = widget.contact.location;
    birthDate = widget.contact.birthDate;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _getLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(location: location),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        location = result;
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        birthDate = pickedDate;
      });
    }
  }

  Future<void> _updateRecentContacts(Contact contact) async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentJson = prefs.getString('recent_contacts');
    List<Contact> updatedRecentContacts = [];

    if (recentJson != null) {
      final List<dynamic> decoded = jsonDecode(recentJson);
      updatedRecentContacts = decoded.map((item) => Contact.fromJson(item)).toList();
    }

    // Remove duplicatas baseadas no nome
    updatedRecentContacts.removeWhere((c) => c.name == contact.name);

    // Adiciona o contato ao topo da lista
    updatedRecentContacts.insert(0, contact);

    // Limita a lista a 10 contatos
    if (updatedRecentContacts.length > 10) {
      updatedRecentContacts = updatedRecentContacts.sublist(0, 10);
    }

    // Salva a lista atualizada
    final String updatedJson = jsonEncode(updatedRecentContacts.map((c) => c.toJson()).toList());
    await prefs.setString('recent_contacts', updatedJson);

    setState(() {
      // Se necessário, atualize o estado local (opcional se a lista já está sendo gerida no RecentPage)
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Contato'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.3,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: imagePath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        child: Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                          : Center(
                        child: Icon(Icons.person, size: screenWidth * 0.2, color: Colors.grey),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: name,
                            decoration: InputDecoration(labelText: 'Nome'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o nome';
                              }
                              return null;
                            },
                            onSaved: (value) => name = value!,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          TextFormField(
                            initialValue: email,
                            decoration: InputDecoration(labelText: 'E-mail'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o e-mail';
                              }
                              return null;
                            },
                            onSaved: (value) => email = value!,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          TextFormField(
                            initialValue: phone,
                            decoration: InputDecoration(labelText: 'Telefone'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o telefone';
                              }
                              return null;
                            },
                            onSaved: (value) => phone = value!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: Text('Câmera'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: Text('Galeria'),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _getLocation,
                  child: Text(location != null ? 'Localização Selecionada' : 'Obter Localização'),
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _selectBirthDate,
                  child: Text(birthDate != null
                      ? 'Data de Nascimento: ${DateFormat.yMd().format(birthDate!)}'
                      : 'Selecionar Data de Nascimento'),
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final updatedContact = Contact(
                        name: name,
                        email: email,
                        phone: phone,
                        imagePath: imagePath,
                        location: location,
                        birthDate: birthDate,
                      );

                      widget.onSave(updatedContact);

                      // Atualiza os contatos recentes
                      _updateRecentContacts(updatedContact);

                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
                      );
                    }
                  },
                  child: Text('Salvar'),
                ),

                ElevatedButton(
                  onPressed: () {
                    widget.onDelete();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                  child: Text('Remover'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
