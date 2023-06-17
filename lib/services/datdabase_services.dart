import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;
  DatabaseServices({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupsCollection =
      FirebaseFirestore.instance.collection('groups');



//saving the user data
       Future savingUserData(String fullName,String email) async{

        return await userCollection.doc(uid).set({
       "fullName":fullName,
       "email": email,
       "groups":[],
       "profilePic": [],
       "uid":uid,

      
        });
       }

//gettijng user data

Future<Query<Object?>> gettingUserData(String email) async{
   
   Query<Object?> snapshot  =await userCollection.where('email', isEqualTo: email);
      return snapshot;
       }
//getting user groups

Future getUserGroups() async{
  return userCollection.doc(uid).snapshots();

}




}
