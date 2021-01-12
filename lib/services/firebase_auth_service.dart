import 'package:canli_sohbet_app/models/user.dart';
import 'package:canli_sohbet_app/services/auth_base.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService extends AuthBase {

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserModel> currentUser() async{
    try{
      User user = _firebaseAuth.currentUser;
      return userModelFromFirebase(user);
    }catch(e){
      print("HATA CURRENT USER $e");
    }
  }

  @override
  Future<UserModel> signInAnonymously() async{
    try{
      UserCredential credential =  await  _firebaseAuth.signInAnonymously();
      return userModelFromFirebase(credential.user);
    }catch(e){
      print("HATA SIGN IN : $e");
      return null;
    }
  }

  @override
  Future<bool> signOut() async{
    try{
      final _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return true;
    }catch(e){
      print(("HATA SIGN OUT : $e"));
      return false;
    }
  }

  UserModel userModelFromFirebase(User user) {
    if(user == null)
      return null;
    return UserModel(userID: user.uid, eMail: user.email);
  }

  @override
  Future<UserModel> signInWithGoogle() async{
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount _googleUser = await _googleSignIn.signIn();

    if(_googleUser != null){
      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
      if(_googleAuth.idToken != null && _googleAuth.accessToken != null){
        UserCredential credential = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken)
        );
        User _userFromGoogle = credential.user;
        return userModelFromFirebase(_userFromGoogle);
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  @override
  Future<UserModel> createUserWithEmailPassword(String email, String password) async{
    UserCredential credential =  await  _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return userModelFromFirebase(credential.user);
  }

  @override
  Future<UserModel> signInWithEmailPassword(String email, String password) async{
    UserCredential credential =  await  _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return userModelFromFirebase(credential.user);
  }

}