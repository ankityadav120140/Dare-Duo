// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dareduo/utilities/global.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final storageRef = FirebaseStorage.instance.ref();

class chatScreen extends StatefulWidget {
  final String phone2;
  final String name2;
  const chatScreen({required this.phone2, required this.name2, super.key});

  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  String? Phone;
  int score1 = 0;
  int score2 = 0;
  bool creating = false;
  late TextEditingController dare;
  late TextEditingController score;
  bool dareCreated = false;
  bool dareReceived = false;

  bool loading = false;
  String getChatId(String userId1, String userId2) {
    List<String> users = [userId1, userId2];
    users.sort(); // sort the user IDs alphabetically
    return '${users[0]}_${users[1]}'; // concatenate the user IDs with an underscore
  }

  void getData() {
    Phone = preferences.getString("phone");
  }

  void setData() async {
    String chatID =
        getChatId(preferences.getString("phone").toString(), widget.phone2);
    DocumentReference ref =
        FirebaseFirestore.instance.collection("chats").doc(chatID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({
          "score1": 0,
          "score2": 0,
        });
      } else {
        ref.update({
          "score1": score1,
          "score2": score2,
        });
      }
    });
  }

  void setDare() async {
    String chatID =
        getChatId(preferences.getString("phone").toString(), widget.phone2);
    DocumentReference ref = FirebaseFirestore.instance
        .collection("chats")
        .doc(chatID)
        .collection("Dare")
        .doc(chatID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({
          "sender": Phone,
          "reciever": widget.phone2,
          "dare": dare.text,
          "points": score.text,
          "proof": "",
        });
      } else {
        ref.update({
          "sender": Phone,
          "reciever": widget.phone2,
          "dare": dare.text,
          "points": score.text,
          "proof": "",
        });
      }
    });
    setState(() {
      loading = false;
    });
  }

  Future<String> uploadFile(File uploadFile, String value, String path) async {
    var profileFile = storageRef.child('$path/$value');
    UploadTask task = profileFile.putFile(uploadFile);
    TaskSnapshot snapshot = await task;
    String fileUrl = await snapshot.ref.getDownloadURL();
    return fileUrl.toString();
  }

  void sendProof() async {
    selectProof();
    String chatID =
        getChatId(preferences.getString("phone").toString(), widget.phone2);
    DocumentReference ref = FirebaseFirestore.instance
        .collection("chats")
        .doc(chatID)
        .collection("Dare")
        .doc(chatID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({
          // "sender": Phone,
          // "reciever": widget.phone2,
          // "dare": dare.text,
          // "points": score.text,
          "proof": proof,
        });
      } else {
        ref.update({
          // "sender": Phone,
          // "reciever": widget.phone2,
          // "dare": dare.text,
          // "points": score.text,
          "proof": proof,
        });
      }
    });
  }

  File? proofPic;
  String proof = '';

  void selectProof() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        proofPic = File(result.files.single.path.toString());
      });
      proof = await uploadFile(proofPic!, "Proof", Phone.toString());
    } else {
      print("No file selected");
    }
  }

  void Approve() async {
    String chatID =
        getChatId(preferences.getString("phone").toString(), widget.phone2);
    DocumentReference ref =
        FirebaseFirestore.instance.collection("chats").doc(chatID);
    DocumentReference ref2 = FirebaseFirestore.instance
        .collection("chats")
        .doc(chatID)
        .collection("Dare")
        .doc(chatID);
    DocumentSnapshot snap2 = await ref2.get();
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({
          "score1": 0,
          "score2": 0,
        });
      } else {
        ref.update({
          // "score1": FieldValue.increment(snap2.data['fafe']),
          "score2": 100,
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    setData();
    dare = TextEditingController(text: "");
    score = TextEditingController(text: "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.name2),
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(getChatId(
                      preferences.getString("phone").toString(), widget.phone2))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors.red,
                            child: Text(
                              snapshot.data!['score1'].toString(),
                              // ignore: prefer_const_constructors
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors.blue,
                            child: Text(
                              snapshot.data!['score2'].toString(),
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: creating
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            border: Border.all(
                                              color: Colors.blue,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        padding: const EdgeInsets.all(5),
                                        margin: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              maxLines: 3,
                                              controller: dare,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Enter Your Dare here';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Dare',
                                              ),
                                            ),
                                            TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: score,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Enter Total Points';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Points',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                          ),
                                          // creating == true
                                          //     ?
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                border: Border.all(
                                                  color: Colors.blue,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            child: IconButton(
                                              onPressed: () async {
                                                setState(() {
                                                  loading = true;
                                                  creating = false;
                                                });
                                                setDare();
                                              },
                                              icon: Icon(
                                                Icons.done_outline,
                                                size: 30,
                                              ),
                                            ),
                                          )
                                          // : Container(
                                          //     decoration: BoxDecoration(
                                          //       color: Colors.blue.shade100,
                                          //       border: Border.all(
                                          //         color: Colors.blue,
                                          //       ),
                                          //       borderRadius:
                                          //           BorderRadius.circular(25),
                                          //     ),
                                          //     child: IconButton(
                                          //       onPressed: () {
                                          //         setState(
                                          //           () {
                                          //             creating != creating;
                                          //           },
                                          //         );
                                          //       },
                                          //       icon: Icon(
                                          //         Icons.edit,
                                          //         size: 30,
                                          //       ),
                                          //     ),
                                          //   ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('chats')
                                    .doc(getChatId(
                                        preferences
                                            .getString("phone")
                                            .toString(),
                                        widget.phone2))
                                    .collection("Dare")
                                    .doc(getChatId(
                                        preferences
                                            .getString("phone")
                                            .toString(),
                                        widget.phone2))
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.data!.exists) {
                                    return Column(
                                      children: [
                                        snapshot.data!['sender'] == Phone
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .blue.shade100,
                                                        border: Border.all(
                                                          color: Colors.blue,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          snapshot
                                                              .data!['dare'],
                                                          style: TextStyle(
                                                              fontSize: 17),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 10),
                                                          height: 2,
                                                          color: Colors.blue,
                                                        ),
                                                        Text(
                                                          snapshot
                                                              .data!['points'],
                                                          style: TextStyle(
                                                              fontSize: 17),
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .blue),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: snapshot.data![
                                                                      'proof'] !=
                                                                  ""
                                                              ? Container(
                                                                  // height: MediaQuery.of(
                                                                  //             context)
                                                                  //         .size
                                                                  //         .height *
                                                                  //     0.3,
                                                                  child: Column(
                                                                    children: [
                                                                      Image.network(
                                                                          snapshot
                                                                              .data!['proof']),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Approve();
                                                                        },
                                                                        child: Text(
                                                                            "Approve"),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : Container(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .red
                                                                    .shade100,
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .red,
                                                                  width: 2,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        margin: const EdgeInsets
                                                            .all(10),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              snapshot.data![
                                                                  'dare'],
                                                              style: TextStyle(
                                                                  fontSize: 17),
                                                            ),
                                                            Container(
                                                              margin: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 10),
                                                              height: 2,
                                                              color: Colors.red,
                                                            ),
                                                            Text(
                                                              snapshot.data![
                                                                  'points'],
                                                              style: TextStyle(
                                                                  fontSize: 17),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .blue),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            sendProof();
                                                          },
                                                          child: snapshot.data![
                                                                      'proof'] ==
                                                                  ""
                                                              ? Text(
                                                                  "Send Proof",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                )
                                                              : Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.2,
                                                                  child: Image.network(
                                                                      snapshot.data![
                                                                          'proof']),
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Start Giving Dares NOWW!"),
                                      ],
                                    );
                                  }
                                },
                              ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  // return Text('Error: ${snapshot.error}');
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: dareReceived == true
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {});
              },
              label: Container(
                child: Text("Send Proof"),
              ),
            )
          : dareCreated
              ? Container()
              : FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      creating = true;
                      dareCreated = true;
                    });
                  },
                  label: Container(
                    child: Text("Create Challenge"),
                  ),
                ),
    );
  }
}
