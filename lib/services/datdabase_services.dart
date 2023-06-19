import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;
  DatabaseServices({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupsCollection =
      FirebaseFirestore.instance.collection('groups');

//saving the user data
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": [],
      "uid": uid,
    });
  }

//getting user data

  Future<Query<Object?>> gettingUserData(String email) async {
    Query<Object?> snapshot =
        await userCollection.where('email', isEqualTo: email);
    return snapshot;
  }
//getting user Groups

  Future getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating a Group

  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupsCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": '',
      "recentMessageSender": "",
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  //getting the  chats

  getChats(String groupId) async {
    return groupsCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  getGroupAdmin(String groupId) async {
    DocumentReference d = groupsCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  //get group members

  getGroupMembers(groupId) async {
    return groupsCollection.doc(groupId).snapshots();
  }

  //search by name
  searchByName(String groupName) {
    return groupsCollection.where('groupName', isEqualTo: groupName).get();
  }

  //function -- bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userdocumentReference = userCollection.doc(uid);

    DocumentSnapshot documentSnapshot = await userdocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }
// toggling the join/ exit

  Future toggleGroupJoin(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupsCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    //if the user has our groups -> thenn remove or also rejoin the user

    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
      });

      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
      });

      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  //sendd messages

  sendMessage(String groupId, Map<String, dynamic> chatMessagesData) async {
    groupsCollection.doc(groupId).collection("messages").add(chatMessagesData);
    groupsCollection.doc(groupId).update({
      "recentMessage": chatMessagesData["message"],
      "recentMessageSender": chatMessagesData['sender'],
      "recentMessageTime": chatMessagesData['time'].toString()
    });
  }
}
