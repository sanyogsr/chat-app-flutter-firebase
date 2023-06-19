import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/auth/register_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/datdabase_services.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  final formKey = GlobalKey<FormState>();
  AuthServices authServices = AuthServices();
  // bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // _isLoading
          //     ? Center(
          //         child: CircularProgressIndicator(
          //           color: Theme.of(context).primaryColor,
          //         ),
          //       )
          SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                const  Text(
                    'Groupie',
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Login now to see what we are talking',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Image.asset('assets/login.png'),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color(0xFFee7b64),
                        )),
                    onChanged: (value) {
                      setState(() {
                        email = value;

                        print(value);
                      });
                    },
                    validator: (val) {
                      if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                          .hasMatch(val!)) {
                        return 'Invalid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xFFee7b64),
                        )),
                    validator: (val) {
                      if (val!.length < 8) {
                        return "please enter atleast 8 characters";
                      } else
                        return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        password = value;

                        print(value);
                      });
                    },
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            backgroundColor: Theme.of(context).primaryColor),
                        onPressed: () {
                          login();
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text.rich(TextSpan(
                      text: "Don't have a account ? ",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                            text: "Register Here",
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                nextScreen(context, RegisterPage());
                              })
                      ]))
                ],
              )),
        ),
      ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        // _isLoading = true;
      });
      await authServices
          .loginWithEmailAndPassword(email, password)
          .then((value) async {
        if (value == true) {
          //saving shared preferences
          Query<Object?> query = await DatabaseServices(
                  uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserData(email);
          QuerySnapshot snapshot = await query.get();

          //saving the values to our sshared_preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSf(email);
          await HelperFunctions.saveUserNameSf(snapshot.docs[0]['fullName']);

          nextScreenreplace(context, const HomePage());
        } else {
          showSnackBar(context, Colors.red, value);
          // _isLoading = false;
        }
      });
    }
  }
}
