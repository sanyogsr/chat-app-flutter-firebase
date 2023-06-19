import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String email = "";
  String password = "";
  String fullName = "";
  AuthServices authServices = AuthServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Groupie',
                          style: TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Login now to see what we are talking',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                        Image.asset('assets/register.png'),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Ful Name',
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xFFee7b64),
                              )),
                          validator: (val) {
                            if (val!.isNotEmpty) {
                              return null;
                            } else {
                              return "Please enter your name";
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              fullName = value;

                              print(value);
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Email',
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color(0xFFee7b64),
                              )),
                          validator: (val) {
                            if (!RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(val!)) {
                              return 'Enter Valid Email';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                        ),
                        const SizedBox(
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
                              return "Enter atleast 8 characters";
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
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                              onPressed: () {
                                register();
                              },
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text.rich(TextSpan(
                            text: "Already have a account ? ",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Login Here",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreen(context, LoginPage());
                                    })
                            ]))
                      ],
                    )),
              ),
            ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authServices
          .registerUserWithEmailAndPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          //saving shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSf(email);
          await HelperFunctions.saveUserNameSf(fullName);
          nextScreenreplace(context, const HomePage());
        } else {
          showSnackBar(context, Colors.red, value);
          _isLoading = false;
        }
      });
    }
  }
}
