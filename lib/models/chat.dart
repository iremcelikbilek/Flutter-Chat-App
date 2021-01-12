import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String fromUser;  //kimden
  final String toUser;    //kime
  final bool fromMe;
  final String message;
  final Timestamp sendDate;

  Chat({this.fromUser, this.toUser, this.fromMe, this.message, this.sendDate});

  Map<String, dynamic> toMap(){
    return {
      'fromUser' : fromUser,
      'toUser' : toUser,
      'fromMe' : fromMe,
      'message' : message,
      'sendDate' : sendDate ?? FieldValue.serverTimestamp()
    };
  }

  Chat.fromMap(Map<String, dynamic> map) :
        fromUser = map['fromUser'],
        toUser = map['toUser'],
        fromMe = map['fromMe'],
        message = map['message'],
        sendDate = map['sendDate'];



}