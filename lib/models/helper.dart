
import 'package:chat_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Helper{

static Future<User_model?> getUserById(String uid) async{
  User_model? user_model;
    
 DocumentSnapshot docSnap=  await FirebaseFirestore.instance.collection("users").doc(uid).get();

  if(docSnap.data()!=null){
    user_model=User_model.fromMap(docSnap.data() as Map<String,dynamic>);
  }

  return user_model;
}

}