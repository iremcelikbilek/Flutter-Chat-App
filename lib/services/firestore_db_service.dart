import 'package:canli_sohbet_app/models/chat.dart';
import 'package:canli_sohbet_app/models/conversation.dart';
import 'package:canli_sohbet_app/models/user.dart';
import 'package:canli_sohbet_app/services/db_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreDbService implements DbBase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(UserModel user) async {
    /*Map _userMapToAdd = user.toMap();
    _userMapToAdd['createdAt'] = FieldValue.serverTimestamp();
    _userMapToAdd['updatedAt'] = FieldValue.serverTimestamp();*/

    await _firestore.collection("users").doc(user.userID).set(user.toMap());

    DocumentSnapshot _readUser =
        await _firestore.doc("users/${user.userID}").get();
    Map _userInformationMapRead = _readUser.data();
    UserModel _readUserModel = UserModel.fromMap(_userInformationMapRead);
    print("Okunan User Nesnesi : " + _readUserModel.toString());
    return true;
  }

  @override
  Future<UserModel> readUser(String userID) async {
    DocumentSnapshot _readUserSnapshot =
        await _firestore.collection("users").doc(userID).get();
    Map<String, dynamic> _readUserMap = _readUserSnapshot.data();
    UserModel _readUser = UserModel.fromMap(_readUserMap);
    debugPrint("Okunan User: ${_readUser.toString()}");
    return _readUser;
  }

  @override
  Future<bool> updateUserName(String userID, String newUserName) async {
    QuerySnapshot updateUser = await _firestore
        .collection("users")
        .where("userName", isEqualTo: newUserName)
        .get();
    if (updateUser.docs.length >= 1) {
      return false;
    } else {
      await _firestore.collection("users").doc(userID).update({
        'userName': newUserName,
      });
      return true;
    }
  }

  @override
  Future<bool> updateProfilePhoto(String userID, String downloadLink) async {
    await _firestore.collection("users").doc(userID).update({
      'profileURL': downloadLink,
    });
    return true;
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection("users").get();
    List<UserModel> allUsers = [];

    for (QueryDocumentSnapshot userDoc in querySnapshot.docs) {
      UserModel user = UserModel.fromMap(userDoc.data());
      allUsers.add(user);
    }
    //WITH MAP
    //allUsers = querySnapshot.docs.map((userDoc) => UserModel.fromMap(userDoc.data())).toList();
    return allUsers;
  }

  // Kendi eklediğim kısım ************
  @override
  Future<UserModel> getUser(String userID) async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection("users").doc(userID).get();

    UserModel user = UserModel.fromMap(documentSnapshot.data());
    return user;
  }
  ///GÜNCELLEME YAPIYORUM !!!
  @override
  Stream<List<Chat>> getChat(String currentUserID, String typedUserID) {
    Stream<QuerySnapshot> querySnapshot = _firestore
        .collection("chat")
        .doc(currentUserID + "--" + typedUserID)
        .collection("messages")
        .orderBy("sendDate", descending: true)
        .limit(1)   //NEW
        .snapshots();

    Stream<List<Chat>> chatListStream = querySnapshot.map((messageList) =>
        messageList.docs
            .map((message) => Chat.fromMap(message.data()))
            .toList());

    return chatListStream;
  }

  @override
  Future<bool> saveMessage(
      Chat messageToBeSaved, UserModel typedUser, currentUser) async {
    var messageID = _firestore.collection("chat").doc().id;
    String currentUserDocID =
        messageToBeSaved.fromUser + "--" + messageToBeSaved.toUser;
    String receiverUserDocID =
        messageToBeSaved.toUser + "--" + messageToBeSaved.fromUser;

    await _firestore
        .collection("chat")
        .doc(currentUserDocID)
        .collection("messages")
        .doc(messageID)
        .set(messageToBeSaved.toMap());
    //************************************************
    await _firestore.collection("chat").doc(currentUserDocID).set({
      'chat_owner': messageToBeSaved.fromUser,
      'talking_with': messageToBeSaved.toUser,
      'last_message': messageToBeSaved.message,
      'seen': false, //görüldü
      'creation_date': FieldValue.serverTimestamp(), //oluşturulma tarihi
      'talkingWithUserName': typedUser.userName,
      'talkingWithProfileURL': typedUser.profileURL
    });
    //****************************************************** diğer kişi için
    await _firestore
        .collection("chat")
        .doc(receiverUserDocID)
        .collection("messages")
        .doc(messageID)
        .set({
      'fromUser': messageToBeSaved.fromUser,
      'toUser': messageToBeSaved.toUser,
      'fromMe': false,
      'message': messageToBeSaved.message,
      'sendDate': messageToBeSaved.sendDate ?? FieldValue.serverTimestamp()
    });

    await _firestore.collection("chat").doc(receiverUserDocID).set({
      'chat_owner': messageToBeSaved.toUser,
      'talking_with': messageToBeSaved.fromUser,
      'last_message': messageToBeSaved.message,
      'seen': false, //görüldü
      'creation_date': FieldValue.serverTimestamp(), //oluşturulma tarihi
      'talkingWithUserName': currentUser.userName,
      'talkingWithProfileURL': currentUser.profileURL
    });

    return true;
  }

  @override
  Stream<List<Conversation>> getAllConversation(String userID) {
    Stream<QuerySnapshot> querySnapshot = _firestore
        .collection("chat")
        .where("chat_owner", isEqualTo: userID)
        .orderBy("creation_date", descending: true)
        .snapshots();

    Stream<List<Conversation>> allConversations = querySnapshot.map(
        (conversationList) => conversationList.docs
            .map((conversationDoc) =>
                Conversation.fromMap(conversationDoc.data()))
            .toList());
    return allConversations;
  }

  @override
  Future<DateTime> showTime(String userID) async {
    await _firestore.collection("server").doc(userID).set({
      'time': FieldValue.serverTimestamp(),
    });

    DocumentSnapshot snapshot =
        await _firestore.collection("server").doc(userID).get();
    Timestamp time = snapshot.data()['time'];

    return time.toDate();
  }

  @override
  Future<List<UserModel>> getUsersWithPagination(UserModel theLastUserToGet, int elementToBeGet) async {
    QuerySnapshot querySnapshot;
    List<UserModel> allUsers = [];
    //Liste ilk defa gelecekse baştan başlayıp elementToBeGet'e kadar alırız.
    if (theLastUserToGet == null) {
      querySnapshot = await _firestore
          .collection("users")
          .orderBy("userName")
          .limit(elementToBeGet)
          .get();
    } else {
      querySnapshot = await _firestore
          .collection("users")
          .orderBy("userName")
          .startAfter([theLastUserToGet.userName])
          .limit(elementToBeGet)
          .get();
      debugPrint("else içine girdim");
      await Future.delayed(Duration(seconds: 1));
    }

    for(DocumentSnapshot snapshot in querySnapshot.docs){
      UserModel singleUser = UserModel.fromMap(snapshot.data());
      allUsers.add(singleUser);
    }

    return allUsers;
  }

  Future<List<Chat>> getChatWithPagination(String currentUserID, String typedUserID, Chat theLastMessageToBeGet, int elementToBeGet) async{
    QuerySnapshot querySnapshot;
    List<Chat> allMessages = [];

    if (theLastMessageToBeGet == null) {
      querySnapshot = await _firestore
          .collection("chat")
          .doc(currentUserID + "--" + typedUserID)
          .collection("messages")
          .orderBy("sendDate", descending: true)
          .limit(elementToBeGet)
          .get();
    } else {
      querySnapshot = await _firestore
          .collection("chat")
          .doc(currentUserID + "--" + typedUserID)
          .collection("messages")
          .orderBy("sendDate", descending: true)
          .startAfter([theLastMessageToBeGet.sendDate])
          .limit(elementToBeGet)
          .get();
      await Future.delayed(Duration(seconds: 1));
    }

    for(DocumentSnapshot snapshot in querySnapshot.docs){
      Chat singleMessage = Chat.fromMap(snapshot.data());
      allMessages.add(singleMessage);
    }

    return allMessages;

  }
}
