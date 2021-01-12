import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String chat_owner;
  final String talking_with;
  final bool seen;
  final String last_message;
  final Timestamp creation_date;
  final Timestamp seen_date;
  final String talkingWithUserName;
  final String talkingWithProfileURL;

  Conversation({this.chat_owner, this.talking_with, this.seen, this.last_message, this.creation_date, this.seen_date, this.talkingWithUserName, this.talkingWithProfileURL});

  Map<String, dynamic> toMap(){
    return {
      'chat_owner' : chat_owner,
      'talking_with' : talking_with,
      'seen' : seen,
      'last_message' : last_message ?? FieldValue.serverTimestamp(),
      'creation_date' : creation_date ?? FieldValue.serverTimestamp(),
      'seen_date' : seen_date,
      'talkingWithUserName' : talkingWithUserName,
      'talkingWithProfileURL' : talkingWithProfileURL
    };
  }

  Conversation.fromMap(Map<String, dynamic> map) :
      chat_owner = map['chat_owner'],
      talking_with = map['talking_with'],
      seen = map['seen'],
      last_message = map['last_message'],
      creation_date = map['creation_date'],
      seen_date = map['seen_date'],
      talkingWithUserName = map['talkingWithUserName'],
      talkingWithProfileURL = map['talkingWithProfileURL'];

  @override
  String toString() {
    return 'Conversation{chat_owner: $chat_owner, talking_with: $talking_with, seen: $seen, last_message: $last_message, creation_date: $creation_date, seen_date: $seen_date, talkingWithUserName: $talkingWithUserName, talkingWithProfileURL: $talkingWithProfileURL}';
  }
}