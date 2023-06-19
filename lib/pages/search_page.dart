import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/datdabase_services.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearch = false;
  String UserName = '';
  User? user;
  bool isJoined = false;
  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  getCurrentUserIdAndName() async {
    await HelperFunctions.getUserNameFromSf().then((value) {
      setState(() {
        UserName = value!;
      });
    });

    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String r) {
    return r.substring(0, r.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'Search',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Column(children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(children: [
              Expanded(
                  child: TextField(
                controller: searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white, fontSize: 15),
                    hintText: "Search groups ......"),
              )),
              GestureDetector(
                onTap: () {
                  initiateSearchMethod();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40)),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              )
            ]),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : groupList()
        ]),
      ),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseServices()
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearch = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearch
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                  UserName,
                  searchSnapshot!.docs[index]['groupId'],
                  searchSnapshot!.docs[index]['groupName'],
                  searchSnapshot!.docs[index]['admin']);
            })
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupName, String admin) async {
    await DatabaseServices(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
// function to check that user has already joined

    joinedOrNot(userName, groupId, groupName, admin);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: 30,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(
        groupName,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
          onTap: () async {
            await DatabaseServices(uid: user!.uid)
                .toggleGroupJoin(groupName, groupId, userName);
            if (isJoined) {
              setState(() {
                isJoined = !isJoined;
              });
              showSnackBar(context, Colors.green,
                  "successfully Joined the $groupName Group");
              Future.delayed(const Duration(seconds: 2), () {
                nextScreen(
                    context,
                    ChatPage(
                        groupId: groupId,
                        groupName: groupName,
                        userName: userName));
              });
            } else {
              setState(() {
                isJoined = !isJoined;
                showSnackBar(context, Colors.red, "Left the  $groupName Group");
              });
            }
          },
          child: isJoined
              ? Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 1)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Joined",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Join Now ',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
    );
  }
}
