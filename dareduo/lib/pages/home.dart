// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dareduo/pages/signIn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../utilities/contact.dart';
import '../utilities/global.dart';
import 'contactScreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Future<void> requestContactPermission() async {
  //   PermissionStatus permissionStatus = await Permission.contacts.request();
  //   if (permissionStatus != PermissionStatus.granted) {
  //     throw Exception('Permission denied');
  //   }
  // }

  void checkContactsPermission() async {
    if (await Permission.contacts.request().isGranted) {
      Get.to(ContactPage());
      // Permission is already granted
      // Do something here, like fetch the contacts
    } else {
      // Permission hasn't been granted yet
      // Request it from the user
      await Permission.contacts.request();
      // Check the status again after requesting it
      if (await Permission.contacts.isGranted) {
        Get.to(ContactPage());
        // Permission has been granted now
        // Do something here, like fetch the contacts
      } else {
        // Permission still hasn't been granted
        // Show a message or disable the functionality that requires the permission
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text("Home"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          checkContactsPermission();
        },
        child: Icon(Icons.contacts),
      ),
    );
  }
}
