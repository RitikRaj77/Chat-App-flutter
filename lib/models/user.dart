class User_model{
  String? uid;
  String? fullname;
  String? email;
  String? profilpic;

  User_model({this.uid,this.fullname,this.email,this.profilpic});
   // deserialization json->map->OBJECT 
  User_model.fromMap(Map<String,dynamic> mp){
      uid=mp["id"];
       fullname=mp["fullname"];
      email=mp["email"];
     
      profilpic=mp["profilpic"];
  }
  //serialization
  Map<String,dynamic> toMap(){
      return {
       "id":uid,
       "fullname":fullname,
       "email":email,
       "profilpic":profilpic

      };

  }

}