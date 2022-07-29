

import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/pages/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'completeprofile.dart';
import 'homepage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  
   TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  void checkValue(){
     String email = emailController.text.trim();
     String password = passwordController.text.trim();
    
    if (email == "" || password == "" ) {
        UIHelper.showAlertDialog(context, "Incomplete Data", "Please Fill all the feild");
    } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
        .hasMatch(email)) {
       UIHelper.showAlertDialog(context, "Incorrect Mail", "Please Fill  the email address corerectly");
    }else{
      logIn(email,password);
    } 

  }

void logIn(String email,String password) async{


  UserCredential? Credential;
  UIHelper.showLoadingDialog(context, 'Logging In...');
   try{
    Credential= await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

   } on FirebaseException catch(e){
  //closing loading dailog
    Navigator.pop(context);

  UIHelper.showAlertDialog(context,"Error Occured",e.message.toString());
   
   }
   
   if(Credential!=null){
    String uid=Credential.user!.uid;

    DocumentSnapshot userData= await FirebaseFirestore.instance.collection('users').doc(uid).get();
   
    User_model user_model= User_model.fromMap(userData.data() as Map<String,dynamic>);
    // go to home pade
    print("Log In Successful");

            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(context, 
            
            MaterialPageRoute(builder: 
            ((context) {
              
              return HomePage(usermodel: user_model, firebaseUser: Credential!.user!);
            }

            )
            )

            );


   }


}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding:EdgeInsets.symmetric(horizontal:40),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children:  [
                  Text(
                    'Chat App',
                    style:   TextStyle(
                      color: Color(0xFFE50914),
                      fontSize:40,
                      fontWeight:FontWeight.bold
                    ),
                  ),
                  TextField(
                     controller:emailController,
                      keyboardType:TextInputType.emailAddress,
                    decoration:InputDecoration(
                       prefixIcon: Icon(Icons.email),

                      hintText: "Email...",
                      
                    ),
                  ),
                   SizedBox(
                    height:10,
                   ),
                  
                  TextField(
                    controller:passwordController,
                    obscureText:true,
                    decoration:InputDecoration(
                        prefixIcon: Icon(Icons.vpn_key),
                      
                      hintText: "Password...",
                       
                    ),
                  ),
                  
                   SizedBox(
                    height:20,
                   ),
                   
                   Row(
                     children: [
                       Expanded(
                         child: CupertinoButton(
                          onPressed:(){
                           checkValue();
                           
                          },
                          color:Color(0xFFE50914),
                          child:Text('Log In'),
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
      bottomNavigationBar:Container(
        child:Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
          Text("Don't have an account?",style:TextStyle(
            fontSize:16
          ),),
          CupertinoButton(child: Text('Sign Up',
          style:TextStyle(fontSize:16,color: Color(0xFFE50914),),
          ), onPressed: (){

           Navigator.push(context,MaterialPageRoute(builder: (context){
             return SignUp();
           }));

          })

        ],),
      ),
    );
  }
}
