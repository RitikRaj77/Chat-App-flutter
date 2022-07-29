import 'dart:developer';

import 'package:chat_app/models/helper.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/pages/completeprofile.dart';
import 'package:chat_app/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'pages/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login.dart';

var uuid =Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
   
   User? currentUser=FirebaseAuth.instance.currentUser;
   

   if(currentUser!=null){
   User_model?  user_model= await Helper.getUserById(currentUser.uid);
   if(user_model!=null) 
    {
      //log(currentUser.uid.toString());
      
      runApp(MyAppLoggedIn(firebaseUser:currentUser, userModel: user_model) );
    
    }
    else{
      runApp(const MyApp());
    }
  
   }else{
      runApp(const MyApp());
   }

 
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
        appBarTheme: const AppBarTheme(
          color: Color(0xFFE50914),
        ),
      ),
      home: const Login(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final User_model userModel;
  final User firebaseUser;

   const MyAppLoggedIn({Key? key, required this.firebaseUser, required this.userModel}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
        appBarTheme: const AppBarTheme(
          color: Color(0xFFE50914),
        ),
      ),
      home:  HomePage(usermodel: userModel,firebaseUser: firebaseUser),
    );
  }
}
