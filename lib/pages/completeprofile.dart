import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class CompleteProfile extends StatefulWidget {
  final User_model userModel;
  final User firebaseUser;

  const CompleteProfile({Key? key,required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
// non nullable
// required
 File? imageFile;
TextEditingController fullNameController=TextEditingController();



 void selectImage(ImageSource source) async {
  
  
  XFile? pickedFile= await ImagePicker().pickImage(source: source);
  
  if(pickedFile!=null){
    cropImage(
      pickedFile
    );
  }

 }

 void cropImage(XFile file) async{
   File? croppedImage = await ImageCropper().cropImage(sourcePath: file.path,
   aspectRatio:CropAspectRatio(ratioX: 1, ratioY: 1),
   compressQuality:25
   );
  
  if(croppedImage!=null){

    setState(() {
      imageFile=croppedImage;
    });
  }


 }

 void showPhotoOptions(){

    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text('Upload Profile Picture'),
        content:Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap:(){
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
                
              },
              leading:Icon(Icons.photo_album),
              title:Text('Select from Gallary'),
            ),
            ListTile(
              onTap:(){
                 Navigator.pop(context);
                selectImage(ImageSource.camera);
               

              },
              leading:Icon(Icons.camera_alt_rounded),
              title:Text('Select from Camera'),
            )
          ],
        ),
      );
    }
    
    
    );

  }

  void checkValue(){
    String fullname=fullNameController.text.trim();
    if(fullname==""|| imageFile==null){
    UIHelper.showAlertDialog(context,"Incomplete Data", "Please fill all the feilds");
    }else{
      log('Uploading data');
      uploadData();
    }
  }
 void uploadData() async{
    //firebase storage
   UIHelper.showLoadingDialog(context, "Uploading Image...");

    UploadTask uploadTask=  FirebaseStorage.instance.ref("profilepictures").
    child(widget.userModel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot= await uploadTask;

    String? imageurl=await snapshot.ref.getDownloadURL();
    String? fullname=fullNameController.text.trim();

    widget.userModel.fullname=fullname;
    widget.userModel.profilpic=imageurl;

    await FirebaseFirestore.instance.collection("users").doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value){log('Uploaded Successfully');
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: 
      ((context) {
        return HomePage(firebaseUser: widget.firebaseUser, usermodel: widget.userModel);
      }

      )
      
      )
      );
    });
    
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:false,
        centerTitle: true,
        title: Text("Complete Profile"),
      ),
      body:SafeArea(
        child:Container(
          padding:EdgeInsets.symmetric(horizontal: 40),
          child:ListView(
            children: [

              SizedBox(height: 20,),

              CupertinoButton(
                onPressed:(){
                  showPhotoOptions();
                },
                padding:EdgeInsets.all(0),
                child: CircleAvatar(
                  radius:60,
                  backgroundColor:Color(0xFFE50914),
                  backgroundImage:(imageFile!=null)?FileImage(imageFile!):null,
                  child:(imageFile==null)?Icon(Icons.person,size:58,color:Colors.white,):null,
                ),
              ),
              
              SizedBox(height: 20,),
             
             TextField(
              controller:fullNameController,
              decoration:InputDecoration(
                hintText:'Full Name',

              ),
             ),
             SizedBox(height:20,),

            Row(
                     children: [
                       Expanded(
                         child: CupertinoButton(
                          onPressed:(){
                            checkValue();
                          },
                          color:Color(0xFFE50914),
                          child:Text('Enter'),
                         ),
                       ),
                     ],
                   ),

            ],
          ),
        ),
        
        ),
    );
  }
}
