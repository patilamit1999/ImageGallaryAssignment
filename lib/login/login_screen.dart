

import 'package:awss3/login/passcode_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants.dart';
import '../main.dart';
import '../model/user_model.dart';
import '../services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isBothValid = false;
  final GlobalKey<FormState> _key = GlobalKey();
  String emailLocal = "", passwordLocal = "";
  DBHelper? dbHelper = DBHelper();

  void successNavigation() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const FilePickingApp(),
      ),
      (Route<dynamic> route) => false, // remove all previous routes
    );
  }

  void loginSubmitEvent(String passcode) async {
    const String emailToBeSent = "12345";
    var isLogin = await dbHelper!.isUserAlreadyExist();
    if (isLogin) {
      var response = await dbHelper!.isUserExist(emailToBeSent, passcode);
      print("Respoonse ----" + response.toString());
      if (response) {
        successNavigation();
      } else {
        const snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('User not Found!!'),
          duration: Duration(seconds: 1),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      add(passcode);
    }
  }

  void add(String passcode) {
    dbHelper!
        .insert(
      User(password: passcode),
    )
        .then((value) {
      const snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text('Registered Successfully'),
        duration: Duration(seconds: 1),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).onError((error, stackTrace) {
      const snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Something Went Wrong!!'),
        duration: Duration(seconds: 1),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const FilePickingApp(),
      ),
      (Route<dynamic> route) => false, // remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Form(
          key: _key,
          autovalidateMode: isBothValid
              ? AutovalidateMode.always
              : AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Login",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 40.0,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.40,
                  width: size.width * 0.90,
                  child: SvgPicture.asset(
                    "assets/images/authentication.svg",
                  ),
                ),
                const SizedBox(height: 20.0),
                PasscodeInput(
                  onCompleted: (passcode) {
                    print("DATA of passcode - $passcode");
                    loginSubmitEvent(passcode);
                  },
                ),
                const SizedBox(height: 20.0),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
