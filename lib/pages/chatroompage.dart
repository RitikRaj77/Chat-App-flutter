import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/chatroom.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final User_model targetUser;
  //model
  final ChatRoom chatRoomModel;

  final User_model userModel;

  final User firebaseuser;

  const ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatRoomModel,
      required this.userModel,
      required this.firebaseuser})
      : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController chatController = TextEditingController();

  void sendMessage() async {
    String messg = chatController.text.trim();
    if (messg != "") {
      //send
      chatController.clear();
      Message newMessage = Message(
          messageId: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: messg,
          seen: false);

      //if we use await it means until our message not reaches to another user our app would stop
      // without using await it will store in your device and it will sync to cloud in background
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoomModel.chatroomid)
          .collection('messages')
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      widget.chatRoomModel.lastMessage=messg;

      FirebaseFirestore.instance
      .collection('chatrooms')
      .doc(widget.chatRoomModel.chatroomid)
      .set(widget.chatRoomModel.toMap());

      log('send succesfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage(widget.targetUser.profilpic.toString()),
                backgroundColor: Colors.grey[500],
              ),
              SizedBox(
                width: 10,
              ),
              Text(widget.targetUser.fullname.toString())
            ],
          ),
        ),
        body: SafeArea(
            child: Container(
          child: Column(
            children: [
              Expanded(
                  child: Container(
                  padding:EdgeInsets.symmetric(horizontal:10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chatrooms')
                      .doc(widget.chatRoomModel.chatroomid)
                      .collection('messages')
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot datasnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: datasnapshot.docs.length,
                          itemBuilder: (context, index) {
                            Message currmessage = Message.fromMap(
                                datasnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            return Row(
                              mainAxisAlignment:(currmessage.sender==widget.userModel.uid)?MainAxisAlignment.end:MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding:EdgeInsets.symmetric(vertical:10,horizontal:10),
                                  margin:EdgeInsets.symmetric(vertical:2),
                                  
                                  decoration:BoxDecoration(
                                    
                                    borderRadius:BorderRadius.circular(10) ,
                                    color:(currmessage.sender==widget.userModel.uid)?Colors.grey:Color(0xFFE50914),

                                  ),
                                  child: Text(
                                    currmessage.text.toString(),
                                    style:TextStyle(
                                      color:Colors.white
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'An Error occured! Please Check your internet Connection'),
                        );
                      } else {
                        return Center(
                          child: Text('Say hello to your new freind'),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              )),
              Container(
                color: Colors.grey.withOpacity(0.2),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        maxLines: null,
                        controller: chatController,
                        decoration: InputDecoration(
                            hintText: 'Chat...', border: InputBorder.none),
                      ),
                    ),
                    IconButton(
                        alignment: Alignment.bottomRight,
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(
                          Icons.send,
                          color: Color(0xFFE50914),
                        ))
                  ],
                ),
              )
            ],
          ),
        )));
  }
}
