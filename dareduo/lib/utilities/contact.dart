// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:contacts_service/contacts_service.dart';
// import 'package:permission_handler/permission_handler.dart';

// Future<void> requestContactPermission() async {
//   PermissionStatus permissionStatus = await Permission.contacts.request();
//   if (permissionStatus != PermissionStatus.granted) {
//     throw Exception('Permission denied');
//   }
// }

// Future<void> getAppUsers() async {
//   FirebaseFirestore.instance.collection('users').get().then((querySnapshot) {
//     List<String> appUsers = [];
//     querySnapshot.docs.forEach((doc) {
//       appUsers.add(doc.data()!['phoneNumber'].toString());
//     });
//     // return appUsers;
//   });
// }

// // Future<List<Contact>> getContacts() async {
// //   Iterable<Contact> contacts =
// //       await ContactsService.getContacts(withThumbnails: false);
// //   List<Contact> phoneContacts = contacts
// //       .where((contact) =>
// //           contact.phones!.isNotEmpty &&
// //           contact.displayName != null &&
// //           contact.displayName!.isNotEmpty)
// //       .toList();
// //   List appUsers = await getAppUsers();
// //   List<Contact> appContacts = phoneContacts
// //       .where((contact) => appUsers.contains(contact.phones!.first.value))
// //       .toList();
// //   return appContacts;
// // }
