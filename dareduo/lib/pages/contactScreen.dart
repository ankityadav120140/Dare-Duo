import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dareduo/pages/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> _contacts = [];
  List<String> _appUsers = [];

  @override
  void initState() {
    super.initState();
    _getAppUsers();
    _getContacts();
  }

  Future<void> _getAppUsers() async {
    List<String> appUsers = [];
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    querySnapshot.docs.forEach((doc) {
      appUsers.add(doc.data()['phone'].toString());
    });
    setState(() {
      _appUsers = appUsers;
    });
  }

  Future<void> _getContacts() async {
    Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    List<Contact> phoneContacts = contacts
        .where((contact) =>
            contact.phones!.isNotEmpty &&
            contact.displayName != null &&
            contact.displayName!.isNotEmpty)
        .toList();
    List<Contact> appContacts = phoneContacts
        .where((contact) => _appUsers.contains(contact.phones!.first.value))
        .toList();
    setState(() {
      _contacts = appContacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getAppUsers();
    _getContacts();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Contacts",
            ),
            IconButton(
                onPressed: () {
                  _getAppUsers();
                  _getContacts();
                },
                icon: Icon(Icons.replay_outlined))
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  Contact contact = _contacts[index];
                  return InkWell(
                    onTap: () {
                      Get.to(chatScreen(
                        phone2: contact.phones!.first.value!,
                        name2: contact.displayName!,
                      ));
                    },
                    child: ListTile(
                      title: Text(contact.displayName!),
                      subtitle: Text(contact.phones!.first.value!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
