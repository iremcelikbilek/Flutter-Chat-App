import 'package:canli_sohbet_app/app/sign_in/email_sifre_giris_kay%C4%B1t.dart';
import 'package:canli_sohbet_app/common_widget/social_log_in_button.dart';
import 'package:canli_sohbet_app/models/user.dart';
import 'package:canli_sohbet_app/view-models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Canlı Sohbet App"),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Oturum Aç",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
            SizedBox(
              height: 8,
            ),
            SocialLoginButton(
              buttonText: "Gmail ile Giriş Yap",
              buttonColor: Colors.white,
              buttonIcon: Image.asset("assets/images/google-logo.png"),
              textColor: Colors.black87,
              onPresssed: () => _signInWithGoogle(context),
            ),
            SocialLoginButton(
              buttonColor: Color(0xFF334D92),
              buttonText: "Facebook ile Giriş Yap",
              buttonIcon: Image.asset("assets/images/facebook-logo.png"),
              onPresssed: () {},
            ),
            SocialLoginButton(
              buttonText: "Email ve Şifre ile Giriş Yap ",
              buttonIcon: Icon(
                Icons.email,
                size: 32,
              ),
              onPresssed: () => _signInWithEmailPassword(context),
            ),
            SocialLoginButton(
              buttonText: "Misafir Girişi ",
              buttonIcon: Icon(Icons.supervised_user_circle),
              buttonColor: Colors.teal,
              onPresssed: () => _misafirGirisi(context),
            )
          ],
        ),
      ),
    );
  }

  void _misafirGirisi(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    UserModel _user = await _userViewModel.signInAnonymously();
    //debugPrint("Oturum Açan User: ${_user.userID}");
  }

  void _signInWithGoogle(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    UserModel _user = await _userViewModel.signInWithGoogle();
    if(_user != null) debugPrint("Oturum Açan Google User: ${_user.userID}");
  }

  void _signInWithEmailPassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => EmailSifreLoginPage(),
      ),
    );
  }
}
