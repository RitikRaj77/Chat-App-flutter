import 'dart:developer';

import 'package:chat_app/models/chatroom.dart';
import 'package:chat_app/models/helper.dart';
import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/pages/chatroompage.dart';
import 'package:chat_app/pages/login.dart';
import 'package:chat_app/pages/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/user.dart';

class HomePage extends StatefulWidget {
  final User_model usermodel;
  final User firebaseUser;

  const HomePage({ Key? key ,required this.firebaseUser,required this.usermodel}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar:AppBar(
        actions: [
          IconButton(onPressed: () async {
           await FirebaseAuth.instance.signOut();
           Navigator.popUntil(context, (route) => route.isFirst);
           Navigator.pushReplacement(context, 
           MaterialPageRoute(builder: 
           (context){
            return Login();
           }
           )
           );
          }, icon: Icon(Icons.exit_to_app))
        ],
        automaticallyImplyLeading:false,
        centerTitle:true,
        title:Text('Chat App',style: TextStyle(fontSize:23),),),
        
       floatingActionButton:FloatingActionButton(
        backgroundColor:Color(0xFFE50914),
        onPressed: (){
       
       


        Navigator.push(context, 
        
        MaterialPageRoute(builder: 
        ((context) {
          return Search(firebaseUser: widget.firebaseUser, user_model: widget.usermodel);
        })

        )
        );

        },
       child:Icon(Icons.search),

       ),
       body:SafeArea(child: 
       Container(
        child:StreamBuilder(
          stream:FirebaseFirestore.instance.collection('chatrooms').where
          ("participants.${widget.usermodel.uid}",isEqualTo:true).snapshots(),
        builder:(context,snapshot){
          if(snapshot.connectionState==ConnectionState.active){
                     if(snapshot.hasData){
                       
                         QuerySnapshot chatroomsnapshot=snapshot.data as QuerySnapshot;

                         return ListView.builder(
                          itemCount: chatroomsnapshot.docs.length,
                          itemBuilder:(context,index){
                            ChatRoom chatRoomModel=ChatRoom.fromMap(chatroomsnapshot.docs[index].data()as Map<String,dynamic>);

                            Map<String,dynamic> participants=chatRoomModel.participants!;

                            List<String> participantkeys=participants.keys.toList();

                            participantkeys.remove(widget.usermodel.uid);
                            // log(participantkeys[0].toString());


                            return FutureBuilder (
                              future: Helper.getUserById(participantkeys[0].toString()),
                              builder:(context,userData){
                                if(userData.connectionState==ConnectionState.done)
                                {
                                  if(userData.data!=null){
                                     User_model targetUser=userData.data as User_model;
                                return ListTile(
                                  onTap:(){
                                    Navigator.push(context, 
                                    MaterialPageRoute(builder: 
                                    
                                    (context){
                                      return ChatRoomPage(
                                      chatRoomModel:chatRoomModel,
                                      firebaseuser:widget.firebaseUser,
                                      userModel:widget.usermodel,
                                      targetUser:targetUser,

                                      );
                                    }
                                    )

                                    );
                                  },
                                  title:Text(targetUser.fullname.toString()),
                                  subtitle:(chatRoomModel.lastMessage.toString()!="")?Text(chatRoomModel.lastMessage.toString()):Text('Say hi to your freind!',style:TextStyle(color:Color(0xFFE50914))),
                                  leading:CircleAvatar(
                                  backgroundImage:NetworkImage(targetUser.profilpic.toString()),
                                  backgroundColor:Colors.grey,

                                  ),
                                );
                                  }else{
                                     return Container();
                                  }
                                }
                                else{
                                  return Container();
                                }
                              },
                            );

                          },
                         );

                     }else if(snapshot.hasError){
                          return Center(
                            child:Text(snapshot.hasError.toString()),
                          );
                     }else{
                        return Center(
                          child:Text('No Chats'),
                        );
                     }
          }else{
            return Center(
              child:CircularProgressIndicator(),
            );
          }
        },
        ),

       ),

       ),   
    );
  }
}