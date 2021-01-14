import 'dart:io';

import 'package:canli_sohbet_app/locator.dart';
import 'package:canli_sohbet_app/models/chat.dart';
import 'package:canli_sohbet_app/models/conversation.dart';
import 'package:canli_sohbet_app/models/user.dart';
import 'package:canli_sohbet_app/services/auth_base.dart';
import 'package:canli_sohbet_app/services/fake_auth_service.dart';
import 'package:canli_sohbet_app/services/firebase_auth_service.dart';
import 'package:canli_sohbet_app/services/firebase_storage_service.dart';
import 'package:canli_sohbet_app/services/firestore_db_service.dart';
import 'package:canli_sohbet_app/services/notification_service.dart';
import 'package:flutter/material.dart';

enum AppMode {DEBUG, RELEASE}

class UserRepository implements AuthBase{

  FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  FakeAuthServices _fakeAuthServices = locator<FakeAuthServices>();
  FirestoreDbService _firestoreDbService = locator<FirestoreDbService>();
  FirebaseStorageService _firebaseStorageService = locator<FirebaseStorageService>();
  NotificationService _notificationService = locator<NotificationService>();

  AppMode appMode = AppMode.RELEASE;

  List<UserModel> allUsers = [];
  Map<String, String> userTokenList = Map<String, String>();

  @override
  Future<UserModel> currentUser() async{
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthServices.currentUser();
    }else{
      UserModel _user = await _firebaseAuthService.currentUser();
      if(_user != null) return await _firestoreDbService.readUser(_user.userID);
      else return null;
    }
  }

  @override
  Future<UserModel> signInAnonymously() async{
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthServices.signInAnonymously();
    }else{
      return await _firebaseAuthService.signInAnonymously();
    }
  }

  @override
  Future<bool> signOut() async{
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthServices.signOut();
    }else{
      return await _firebaseAuthService.signOut();
    }
  }

  //Firestore'dan gelen saveUser metodu eklendi.
  @override
  Future<UserModel> signInWithGoogle() async{
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthServices.signInWithGoogle();
    }else{
      UserModel _user = await _firebaseAuthService.signInWithGoogle();
      if(_user != null){
        bool result = await _firestoreDbService.saveUser(_user);
        if(result){
          //auth ile gelen user'ı değil firestore'a kaydettiğim user'ı return etmek istiyorum
          return await _firestoreDbService.readUser(_user.userID);
        }else{
          await _firebaseAuthService.signOut();
          return null;
        }
      }
      else return null;
    }
  }

  //Firestore'dan gelen saveUser metodu eklendi.
  @override
  Future<UserModel> createUserWithEmailPassword(String email, String password) async{
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthServices.createUserWithEmailPassword(email, password);
    }else{
      UserModel _user = await _firebaseAuthService.createUserWithEmailPassword(email, password);
      bool result = await _firestoreDbService.saveUser(_user);
      if(result){
        //auth ile gelen user'ı değil firestore'a kaydettiğim user'ı return etmek istiyorum
        return await _firestoreDbService.readUser(_user.userID);
      }else return null;
    }
  }

  @override
  Future<UserModel> signInWithEmailPassword(String email, String password) async{
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthServices.signInWithEmailPassword(email, password);
    }else{
      //auth ile gelen user'ı değil firestore'a kaydettiğim user'ı return etmek istiyorum
      UserModel _registeredUser = await _firebaseAuthService.signInWithEmailPassword(email, password);
      return await _firestoreDbService.readUser(_registeredUser.userID);
    }
  }

  Future<bool> updateUserName(String userID, String newUserName) async{
    if(appMode == AppMode.DEBUG){
      //return await _fakeAuthServices.signInWithEmailPassword(email, password);
      return false;
    }else {
      bool _result = await _firestoreDbService.updateUserName(
          userID, newUserName);
      return _result;
    }
  }

  Future<String> uploadFile(String userID, String fileType, File fileToUpload) async{
    if(appMode == AppMode.DEBUG){
      return null;
    }else {
      String downloadLink = await _firebaseStorageService.uploadFile(userID, fileType, fileToUpload);
      await _firestoreDbService.updateProfilePhoto(userID,downloadLink);
      return downloadLink;
    }

  }

  Future<List<UserModel>> getAllUsers() async{
    if(appMode == AppMode.DEBUG){
      return [];
    }else {
      allUsers = await _firestoreDbService.getAllUsers();
      return allUsers;
    }
  }

  Future<UserModel> getUser(String userID) async{
    if(appMode == AppMode.DEBUG){
      return null;
    }else {
      var user = await _firestoreDbService.getUser(userID);
      return user;
    }
  }

  Stream<List<Chat>> getChat(String currentUserID, String typedUserID) {
    if(appMode == AppMode.DEBUG){
      return Stream.empty();
    }else {
      return _firestoreDbService.getChat(currentUserID, typedUserID);
    }
  }

  Future<bool> saveMessage(Chat messageToBeSaved, UserModel typedUser,currentUser) async{
    if(appMode == AppMode.DEBUG){
      return true;
    }else {
      bool result =  await _firestoreDbService.saveMessage(messageToBeSaved,typedUser,currentUser);
      if(result){
        var token = "";
        if(userTokenList.containsKey(messageToBeSaved.toUser)){
          token = userTokenList[messageToBeSaved.toUser];
          print("Localden geldi : $token");
        }else{
          token = await _firestoreDbService.getToken(messageToBeSaved.toUser);
          if(token != null)
          userTokenList[messageToBeSaved.toUser] = token;
          print("Veritabanından geldi : $token");
        }
        if(token != null)
        await _notificationService.sendNotification(messageToBeSaved, currentUser, token);
        return true;
      }else return false;
    }
  }

  Stream<List<Conversation>> getAllConversations(String userID) {
    if(appMode == AppMode.DEBUG){
      return Stream.empty();
    }else {
      //var conversationList =
       //getNewConversationList(conversationList).asStream();
      return _firestoreDbService.getAllConversation(userID);
    }
  }

/*  Future<List<Conversation>> getNewConversationList(Stream<List<Conversation>> conversationList) async{
    var newConversationList = await (conversationList as Future<List<Conversation>>);
    for(var conversation in newConversationList){
      var userInConversationList = _findUser(conversation.talking_with);
      if(userInConversationList != null){
        debugPrint("VERILER LOCAL CACHE DEN OKUNDU");
        conversation.talkingWithUserName = userInConversationList.userName;
        conversation.talkingWithProfileURL = userInConversationList.profileURL;
      }else{
        debugPrint("VERILER FIREBASE DEN OKUNDU");
        var userToReadFromDatabase = await _firestoreDbService.readUser(conversation.talking_with);
        conversation.talkingWithUserName = userToReadFromDatabase.userName;
        conversation.talkingWithProfileURL = userToReadFromDatabase.profileURL;
      }
    }
    return newConversationList;
  }*/

  UserModel _findUser(String userID){
    for(int i=0; i<allUsers.length; i++){
      if(allUsers[i].userID == userID){
        return allUsers[i];
      }
    }
    //Eğer for döngüsünde return olmadıysam böyle bir kullanıcı yok demektir.Burada null döndürürüm.
    return null;
  }

  Future<List<UserModel>> getUsersWithPagination(UserModel theLastUserToGet, int elementToBeGet) async{
    if(appMode == AppMode.DEBUG){
      return [];
    }else{
      return await _firestoreDbService.getUsersWithPagination(theLastUserToGet, elementToBeGet);
    }
  }

  Future<List<Chat>> getChatWithPagination(String currentUserID, String typedUserID, Chat theLastMessageToBeGet, int elementToBeGet) async{
    if(appMode == AppMode.DEBUG){
      return [];
    }else{
      return await _firestoreDbService.getChatWithPagination(currentUserID, typedUserID, theLastMessageToBeGet, elementToBeGet);
    }
  }

}