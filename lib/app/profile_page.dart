import 'dart:io';

import 'package:canli_sohbet_app/common_widget/responsive_alert_dialog.dart';
import 'package:canli_sohbet_app/common_widget/social_log_in_button.dart';
import 'package:canli_sohbet_app/view-models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  TextEditingController _textEditingController ;
  File profilePhoto;

  /*@override
  void initState() {
    super.initState();
    //_textEditingController = TextEditingController();
  }*/
  String _userName;
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
     _textEditingController = TextEditingController();
    var viewModel = Provider.of<UserViewModel>(context);
    _textEditingController.text = viewModel.userModel.userName;
    debugPrint("Profildeki user:" + viewModel.userModel.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          FlatButton(onPressed: (){
            _confirmForSignOut(context);
          }, child: Text("Çıkış Yap",style: TextStyle(color: Colors.white),),),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    showModalBottomSheet(context: context, builder: (context){
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera),
                              title: Text("Kameradan çek"),
                              onTap: () => _takePhoto(),
                            ),
                            ListTile(
                              leading: Icon(Icons.image),
                              title: Text("Galeriden seç"),
                              onTap: () => _pickImage(),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                  child: CircleAvatar( backgroundImage: (profilePhoto == null) ? NetworkImage(viewModel.userModel.profileURL) : FileImage(profilePhoto),
                    backgroundColor: Colors.black,
                    radius: 75,
                  //child: Image.network(viewModel.userModel.profileURL),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextFormField(
                          initialValue: viewModel.userModel.eMail,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Email :",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            labelText: "User Name :",
                            hintText: "User Name giriniz",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SocialLoginButton(buttonText: "GÜNCELLE",onPresssed: (){
                  _updateUserName(context);
                  _updateProfilePhoto(context);
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _signOut(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    bool result = await _userViewModel.signOut();
    return result;
  }

  Future<void> _confirmForSignOut(BuildContext context) async{
    bool result = await ResponsiveAlertDialog(
      title: "Emin Misiniz ?",
      content: "Çıkmak istiyorsanız tamam butonuna basınız",
      mainButton: "Tamam",
      cancelButton: "Vazgeç",
    ).show(context);

    if(result){
      _signOut(context);
    }
  }

  void _updateUserName(BuildContext context) async{
    final _userViewModel = Provider.of<UserViewModel>(context,listen: false);
    if(_userViewModel.userModel.userName != _textEditingController.text){
       bool result = await _userViewModel.updateUserName(_userViewModel.userModel.userID, _textEditingController.text);
       if(result){
         ResponsiveAlertDialog(
           title: "BAŞARILI",
           content: "User Name başarılı bir şekilde güncellendi",
           mainButton: "Tamam",
         ).show(context);
       }else{
        _textEditingController.text = _userViewModel.userModel.userName;
         ResponsiveAlertDialog(
           title: "HATA",
           content: "Bu username kullanımda farklı bir userName deneyin",
           mainButton: "Tamam",
         ).show(context);
       }
    }
  }

  void _takePhoto() async{
    PickedFile pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    Navigator.of(context).pop();
    setState(() {
      profilePhoto = File(pickedFile.path);
    });

  }

  void _pickImage() async{
    PickedFile pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    Navigator.of(context).pop();
    setState(() {
      profilePhoto = File(pickedFile.path);
    });

  }

  void _updateProfilePhoto(BuildContext context) async{
    final _userViewModel = Provider.of<UserViewModel>(context,listen: false);
    if(profilePhoto != null){
      var url = await _userViewModel.uploadFile(_userViewModel.userModel.userID, "profile_photo", profilePhoto);
      debugPrint("url: $url");
      if(url != null){
        ResponsiveAlertDialog(
          title: "BAŞARILI",
          content: "Fotoğrafınız başarılı bir şekilde güncellendi",
          mainButton: "Tamam",
        ).show(context);
      }
    }

  }
}
