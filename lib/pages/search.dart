import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/chatroom.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/pages/chatroompage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Search extends StatefulWidget {
  final User_model user_model;
  final User firebaseUser;
 
  const Search({Key? key, required this.firebaseUser, required this.user_model})
      : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController emailController = TextEditingController();

  Future<ChatRoom?> getChatRoom(User_model targetUser) async {
    // used map for users because we can apply where clause on list or array only one time
      // log(widget.firebaseUser.uid.toString());
      // log(targetUser.uid.toString());
    ChatRoom? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms") .where("participants.${widget.user_model.uid}", isEqualTo: true).where("participants.${targetUser.uid}", isEqualTo: true).get();

    if (snapshot.docs.isNotEmpty) {
      // fetching the exisiting one
      // for perticulr chat there is going to be only one chatid and thats why 0 index
     var docData =snapshot.docs[0].data();
    //model for chatroom
     ChatRoom existingChatRoom = ChatRoom.fromMap(docData as Map<String,dynamic>);


    chatRoom=existingChatRoom;


    } else {
      // create one

        

      ChatRoom newChatRoom = ChatRoom(
        //v1 gives string
        chatroomid:uuid.v1(),
        lastMessage:"",
        participants:{
         widget.user_model.uid.toString():true,
         targetUser.uid.toString():true, 
        }


      );

     

      await FirebaseFirestore.instance.collection('chatrooms').doc(newChatRoom.chatroomid).set(newChatRoom.toMap());
     
      chatRoom=newChatRoom;

      log('new chat room created');
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Search Users'),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email...",
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                        child: Text("Search"),
                        color: Color(0xFFE50914),
                        onPressed: () {
                          setState(() {});
                        }),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // required stream
              StreamBuilder(
                // we will get the snapshot according to search

                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("email", isEqualTo: emailController.text)
                    .where("email", isNotEqualTo: widget.user_model.email)
                    .snapshots(),
                // the data we get in stream is snapshot
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot datasnapshot =
                          snapshot.data as QuerySnapshot;

                      if (datasnapshot.docs.isNotEmpty) {
                        Map<String, dynamic> userMap =
                            datasnapshot.docs[0].data() as Map<String, dynamic>;

                            // log(userMap.toString());

                        User_model search_user_model =
                            User_model.fromMap(userMap);
                            


                            // log(widget.firebaseUser.uid.toString());
                            // log(search_user_model.uid.toString());
                            // log(search_user_model.email.toString());

                        return ListTile(
                          onTap: (() async {
                            ChatRoom? chatroommodel =
                                await getChatRoom(search_user_model);

                                if(chatroommodel!=null){
                                  
                                   Navigator.pop(context);
                            Navigator.push(context,

                            MaterialPageRoute(builder:
                            ((context) {
                              return ChatRoomPage(
                              targetUser:search_user_model,
                              userModel:widget.user_model,
                              firebaseuser:widget.firebaseUser,
                              chatRoomModel:chatroommodel,

                              );
                            })
                            )

                            );
                                }

                           
                          }),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(search_user_model.profilpic!),
                            backgroundColor: Colors.grey[500],
                          ),
                          title: Text(search_user_model.fullname!),
                          subtitle: Text(search_user_model.email.toString()),
                          trailing: Icon(Icons.keyboard_arrow_right),
                        );
                      } else {
                        if (emailController.text.isNotEmpty)
                          return Text("No Result Found!");
                        else {
                          return Text('');
                        }
                      }
                    } else if (snapshot.hasError) {
                      return Text("Erorr has occured");
                    } else {
                      return Text("No Result Found!");
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
