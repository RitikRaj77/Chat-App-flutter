
//import 'dart:convert';
// message which we will send in chatroom
class Message{
String? sender;
String? text;
//seen is false until B not see it
bool? seen;
DateTime? createdon;//when message created
String? messageId;

Message({this.messageId,this.sender,this.text,this.seen,this.createdon});

Message.fromMap(Map<String,dynamic> mp){
  sender=mp["sender"];
  text=mp["text"];
  seen=mp["seen"];
  createdon=mp["createdon"].toDate();
  messageId=mp['messageid'];

}
 Map<String,dynamic> toMap(){

  return {
  "messageid":messageId,
  "sender":sender,
  "text":text,
  "seen":seen,
  "createdon":createdon
  };

 }


}