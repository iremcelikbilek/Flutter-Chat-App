import 'dart:async';

import 'package:canli_sohbet_app/locator.dart';
import 'package:canli_sohbet_app/models/chat.dart';
import 'package:canli_sohbet_app/models/user.dart';
import 'package:canli_sohbet_app/repository/user_repository.dart';
import 'package:flutter/material.dart';

enum ChatViewState {Idle, Loaded, Busy}

class ChatViewModel with ChangeNotifier{
  List<Chat> _allChat;
  ChatViewState _chatViewState = ChatViewState.Idle;
  static final _elementToBeGet = 10;
  UserRepository _repository = locator<UserRepository>();
  Chat _theLastMessageToBeGet;
  Chat _theFirstMessageToBeGet;
  bool _hasMore = true;
  bool _isNewMessageListener = false;
  StreamSubscription _streamSubscription;

  final UserModel currentUser;
  final UserModel typedUser;

  ChatViewModel({@required this.currentUser, @required this.typedUser}){
    _allChat = [];
    getChatWithPagination(false);
  }

  @override
  dispose() {
    print("ChatViewModel dispose edildi");
    _streamSubscription.cancel();
    super.dispose();
  }



  bool get hasMore => _hasMore;

  List<Chat> get allChat => _allChat;

  ChatViewState get chatViewState => _chatViewState;

  set chatViewState(ChatViewState value) {
    _chatViewState = value;
    notifyListeners();
  }

  void getChatWithPagination(bool isNewElement) async{
    if(_allChat.length > 0){
      _theLastMessageToBeGet = _allChat.last;
    }

    if(!isNewElement) chatViewState = ChatViewState.Busy;
    var newList = await _repository.getChatWithPagination(currentUser.userID, typedUser.userID, _theLastMessageToBeGet, _elementToBeGet);
    newList.forEach((message) => print("Gelen mesaj : ${message.message}"));

    if(newList.length < _elementToBeGet){
      _hasMore = false;
    }

    _allChat.addAll(newList);
    if(_allChat.length > 0){
      _theFirstMessageToBeGet = _allChat.first;
      print("Listeye eklenen ilk mesaj : ${_theFirstMessageToBeGet.message}");
    }

    chatViewState = ChatViewState.Loaded;

    if(_isNewMessageListener == false){
      _isNewMessageListener = true;
      print("Listener yok o yüzden atanacak !!!");
      newMessageListener();
    }

  }

  Future<bool> saveMessage(Chat messageToBeSaved, UserModel typedUser, UserModel currentUser) async{
    return await _repository.saveMessage(messageToBeSaved, typedUser, currentUser);
  }

  Future<void> getMoreMessages() async{
    print("ChatViewModel'deki getMoreMessages tetiklendi");
    if(_hasMore) getChatWithPagination(true);
    else print("Daha fazla eleman yok o yüzden eleman çağırılmayacak");
    await Future.delayed(Duration(seconds: 2));
  }

  void newMessageListener() {
    print("Yeni mesajlar için listener atandı");
    //instant = anlık
    _streamSubscription = _repository.getChat(currentUser.userID, typedUser.userID)
        .listen((instantData) {
          if(instantData.isNotEmpty){
            print("Listener tetiklendi ve anlık veri . ${instantData[0].message}");
            //Eğer sohbet boşsa direkt ekle
            if(_theFirstMessageToBeGet == null){
              _allChat.insert(0, instantData[0]);
            }
            //Eğer daha önceden gelen bi sohbet varsa ilk mesajı tekrar eklememek için kontrol yap.
            if(instantData[0].sendDate != null){
              if(_theFirstMessageToBeGet.sendDate.millisecondsSinceEpoch != instantData[0].sendDate.millisecondsSinceEpoch)
                _allChat.insert(0, instantData[0]);
            }

            chatViewState = ChatViewState.Loaded; //değişikliği algılamam için
          }
    });
  }
}