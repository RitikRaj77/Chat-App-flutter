

import 'package:chat_app/models/user.dart';
import 'package:chat_app/pages/completeprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart ';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/models/uihelper.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ConfirmPController = TextEditingController();

  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String ConfirmPassword = ConfirmPController.text.trim();

    if (email == "" || password == "" || ConfirmPassword == "") {
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please Fill all the feild");
    } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
        .hasMatch(email)) {
     UIHelper.showAlertDialog(context, "Incorrect Mail", "Please Fill  the email address corerectly");
    } else if (password != ConfirmPassword) {
     UIHelper.showAlertDialog(context, "Error in Password", "Password do not match");
      
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    // firebase ek class deta hai
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, 'Signing In...');

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "Error Occured", e.message.toString());
    }

    if (credential != null) {
      // use of firestore
      // create uid for every users

      String uid = credential.user!.uid;
      //every doc has unique name
      User_model newUser =
          User_model(uid: uid, email: email, fullname: "", profilpic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then(
            (value) {
             print('New User Created');
              Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(context, 
            
            MaterialPageRoute(builder: 
            ((context) {
              
              return CompleteProfile(userModel: newUser, firebaseUser: credential!.user!);
            }

            )
            )

            );

            }
            


          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Chat App',
                    style: TextStyle(
                        color: Color(0xFFE50914),
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Email...",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key),
                      focusColor: Colors.red,
                      hintText: "Password...",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: ConfirmPController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key),
                      focusColor: Colors.red,
                      hintText: "Confirm Password...",
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          onPressed: () {

                            checkValue();
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) {
                            //     return CompleteProfile();
                            //   }),
                            // );
                          },
                          color: Color(0xFFE50914),
                          child: Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
                child: Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFE50914),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
}
