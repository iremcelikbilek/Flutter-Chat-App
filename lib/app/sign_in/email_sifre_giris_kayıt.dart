import 'package:canli_sohbet_app/app/error_exception.dart';
import 'package:canli_sohbet_app/common_widget/responsive_alert_dialog.dart';
import 'package:canli_sohbet_app/common_widget/social_log_in_button.dart';
import 'package:canli_sohbet_app/models/user.dart';
import 'package:canli_sohbet_app/view-models/user_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum FormType { Register, Login }

class EmailSifreLoginPage extends StatefulWidget {
  @override
  _EmailSifreLoginPageState createState() => _EmailSifreLoginPageState();
}

class _EmailSifreLoginPageState extends State<EmailSifreLoginPage> {
  String _email, _password;
  String _buttonText, _linkText;
  String _emailErrorMessage;
  var _formType = FormType.Login;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _buttonText = (_formType == FormType.Login) ? "Giriş Yap" : "Kayıt Ol";
    _linkText = (_formType == FormType.Login)
        ? "Hesabınız Yok Mu ? Kayıt Olun"
        : "Hesabınız Var Mı ? Giriş Yapın";

    final _userViewModel = Provider.of<UserViewModel>(context);

    /* if (_userViewModel.viewState == ViewState.IDLE) {
      if (_userViewModel.userModel != null) {
        return HomePage();
      }
    } else {
      return Center(child: CircularProgressIndicator());
    }*/

    if (_userViewModel.userModel != null) {
      Future.delayed(Duration(milliseconds: 10), () {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Giriş/Kayıt"),
      ),
      body: (_userViewModel.viewState == ViewState.IDLE)
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          errorText: (_userViewModel.emailErrorMessage != null)
                              ? _userViewModel.emailErrorMessage
                              : null,
                          prefixIcon: Icon(Icons.email),
                          hintText: "Email'inizi giriniz",
                          labelText: "Email :",
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (inputText) {
                          _email = inputText;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          errorText:
                              (_userViewModel.passwordErrorMessage != null)
                                  ? _userViewModel.passwordErrorMessage
                                  : null,
                          prefixIcon: Icon(Icons.vpn_key),
                          hintText: "Şifre'nizi giriniz",
                          labelText: "Şifre :",
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (inputText) {
                          _password = inputText;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      SocialLoginButton(
                        buttonText: _buttonText,
                        buttonColor: Theme.of(context).accentColor,
                        onPresssed: () => _formSubmit(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FlatButton(
                        onPressed: () => _changeForm(),
                        child: Text(_linkText),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  // stateful widget'larda parametre olarak context geçmesek bile sınıfın tamamında bu context'e erişebilirim
  void _formSubmit() async {
    _formKey.currentState.save();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    if (_formType == FormType.Login) {
      try {
        UserModel _userModel =
            await userViewModel.signInWithEmailPassword(_email, _password);
        if (_userModel != null)
          debugPrint(
              "Email şifre ile giriş yapan user : ${_userModel.toString()}");
      } on FirebaseAuthException catch (e) {
        debugPrint("For submit sign in metodunda HATA :" + e.code);
        userViewModel.emailErrorMessage = (e.code == "emaıl-already-ın-use") ? Errors.showError(e.code): null;
        userViewModel.passwordErrorMessage = (e.code == "wrong-password") ? Errors.showError(e.code): null;
        ResponsiveAlertDialog(title: "Kullanıcı Girişinde Hata", content: Errors.showError(e.code), mainButton: "Tamam").show(context);
      }
    } else {
      try {
        UserModel _userModel =
            await userViewModel.createUserWithEmailPassword(_email, _password);
        if (_userModel != null)
          debugPrint(
              "Email şifre ile  oluşturulan user : ${_userModel.toString()}");
      } on FirebaseAuthException catch (e) {
        print("For submit create metodunda HATA :" + Errors.showError(e.code));
        userViewModel.emailErrorMessage = Errors.showError(e.code);
        ResponsiveAlertDialog(
                title: "Kullanıcı Oluşturmada Hata",
                content: Errors.showError(e.code),
                mainButton: "Tamam")
            .show(context);
      }
    }
  }

  void _changeForm() {
    setState(() {
      _formType =
          (_formType == FormType.Login) ? FormType.Register : FormType.Login;
    });
  }
}
