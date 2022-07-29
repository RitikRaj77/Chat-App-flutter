// model for chating between users

class ChatRoom{
   String? chatroomid;
   Map<String,dynamic>? participants;
   String? lastMessage;


   ChatRoom({this.chatroomid,this.participants,this.lastMessage});

   
   ChatRoom.fromMap(Map<String,dynamic> mp){
     chatroomid=mp["chatroomid"];
     participants=mp["participants"];
     lastMessage=mp["lastmessage"];

   }
   
   Map<String,dynamic> toMap(){
     return {
      "chatroomid":chatroomid,
      "participants":participants,
      "lastmessage":lastMessage

     };

   }


}