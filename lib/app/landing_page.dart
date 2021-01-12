import 'package:canli_sohbet_app/app/home_page.dart';
import 'package:canli_sohbet_app/app/sign_in/sign_in_page.dart';
import 'package:canli_sohbet_app/view-models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final _userViewModel = Provider.of<UserViewModel>(context);

    if(_userViewModel.viewState == ViewState.IDLE){
      if(_userViewModel.userModel == null){
        return SignInPage();
      }else{
        return HomePage(id: _userViewModel.userModel.userID,);
      }
    }else{
      return Scaffold(
        appBar: AppBar(title: Text("Hoşgeldiniz"),),
        body: Center(child: CircularProgressIndicator()),
      );
    }

  }

}

