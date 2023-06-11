// import 'dart:math';

import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/services/datdabase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

class AuthServices {
  final FirebaseAuth firebaseaauth = FirebaseAuth.instance;
  //signin

      Future loginWithEmailAndPassword(
      String email, String password) async {
    try {
      User user = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password))
          .user!;

      if (user != null) {
      
        return true;
      }
    } on FirebaseAuthException catch (e) {
      // print(e);
      return e.message;
    }
  }

  //register
  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password))
          .user!;

      if (user != null) {
        await DatabaseServices(uid: user.uid)
            .savingUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      // print(e);
      return e.message;
    }
  }

  // signout

  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSf('');
      await HelperFunctions.saveUserNameSf('');

      await firebaseaauth.signOut();
    } catch (e) {
      return null;
    }
  }
}
