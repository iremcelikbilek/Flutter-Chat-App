import 'package:canli_sohbet_app/models/chat.dart';
import 'package:canli_sohbet_app/models/user.dart';
import 'package:canli_sohbet_app/view-models/chat_view_model.dart';
import 'package:canli_sohbet_app/view-models/user_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: (chatViewModel.chatViewState == ChatViewState.Busy)
      ? _waitForNewUserList()
      : Center(
        child: Container(
          color: Colors.black87,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildMessageListArea(),
              buildNewMessageSendArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessageListArea() {
    return Consumer<ChatViewModel>(
      builder: (BuildContext context, ChatViewModel model, Widget child){
        return Expanded(
          child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: (model.hasMore) ? model.allChat.length + 1 : model.allChat.length,
              itemBuilder: (context, index) {
                if(model.hasMore && model.allChat.length == index){
                  return _waitForNewUserList();
                }else return _createMessageBalloon(model.allChat[index]);
              }),
        );
      },
    );
  }

  Widget buildNewMessageSendArea()  {
    final chatViewModel = Provider.of<ChatViewModel>(context);
    return Container(
              margin: EdgeInsets.only(bottom: 8, left: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      cursorColor: Colors.blueGrey,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Mesaj yazın",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: FloatingActionButton(
                      elevation: 0,
                      backgroundColor: Theme.of(context).accentColor,
                      child: Icon(
                        Icons.send,
                        size: 35,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (_messageController.text.trim().length > 0) {
                          Chat messageToBeSaved = Chat(
                            fromUser: chatViewModel.currentUser.userID,
                            toUser: chatViewModel.typedUser.userID,
                            fromMe: true,
                            message: _messageController.text,
                          );
                          bool result = await chatViewModel
                              .saveMessage(messageToBeSaved,chatViewModel.typedUser, chatViewModel.currentUser);
                          if (result) {
                            _messageController.clear();
                            _scrollController.animateTo(0.0,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeOut);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
  }

  Widget _createMessageBalloon(Chat message) {
    final chatViewModel = Provider.of<ChatViewModel>(context);
    Color incomingMessage = Theme.of(context).accentColor;
    Color outgoingMessage = Theme.of(context).primaryColor;
    bool fromMe = message.fromMe; // Eğer bendense(true) outgoingMessage false ise incoming message

    var hourMinuteValue = "";

    try{
      hourMinuteValue =  _showHourMinute(message.sendDate ?? Timestamp(1,1)) ;
    }catch(e){
      debugPrint("Saat çevirmede hata : $e");
    }

    if (fromMe) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.all(4),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: outgoingMessage,
                    ),
                    child: Text(
                      message.message,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(hourMinuteValue, style: TextStyle(color: Colors.white),),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(chatViewModel.typedUser.profileURL),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.all(4),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: incomingMessage,
                    ),
                    child: Text(
                      message.message,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(hourMinuteValue, style: TextStyle(color: Colors.white),),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _waitForNewUserList() {
    return Padding(padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  String _showHourMinute(Timestamp sendDate) {
    var formatter = DateFormat.Hm();
    var formattedDate = formatter.format(sendDate.toDate());
    return formattedDate;
  }

  void _scrollListener() {
    if(_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange ){
      getOldMessages();
    }
  }

  void getOldMessages() async{
    print("Listenin en üstündeyiz eski mesajları getir");
    final chatViewModel = Provider.of<ChatViewModel>(context,listen: false);

    if(_isLoading == false){
      _isLoading = true;
      await chatViewModel.getMoreMessages();
      _isLoading = false;
    }
  }


}

/// **** ESKİ HALİ ****
/*class ChatPage extends StatefulWidget {

  final UserModel currentUser;
  final UserModel typedUser;

  const ChatPage({this.currentUser, this.typedUser});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final _userViewModel = Provider.of<UserViewModel>(context);
    UserModel currentUser = widget.currentUser;
    UserModel typedUser = widget.typedUser;
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Center(
        child: Container(
          color: Colors.black87,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: StreamBuilder<List<Chat>>(
                  stream: _userViewModel.getChat(
                      currentUser.userID, typedUser.userID),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Chat>> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    List<Chat> allMessages = snapshot.data;
                    return ListView.builder(
                      reverse: true,
                        controller: _scrollController,
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          return _createMessageBalloon(allMessages[index]);
                        });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8, left: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        cursorColor: Colors.blueGrey,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Mesaj yazın",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: Theme.of(context).accentColor,
                        child: Icon(
                          Icons.send,
                          size: 35,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          if (_messageController.text.trim().length > 0) {
                            Chat messageToBeSaved = Chat(
                              fromUser: currentUser.userID,
                              toUser: typedUser.userID,
                              fromMe: true,
                              message: _messageController.text,
                            );
                            bool result = await _userViewModel
                                .saveMessage(messageToBeSaved,typedUser,currentUser);
                            if (result) {
                              _messageController.clear();
                              _scrollController.animateTo(0.0,
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeOut);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createMessageBalloon(Chat message) {
    Color incomingMessage = Theme.of(context).accentColor;
    Color outgoingMessage = Theme.of(context).primaryColor;
    bool fromMe = message
        .fromMe; // Eğer bendense(true) outgoingMessage false ise incoming message

    var hourMinuteValue = "";

    try{
      hourMinuteValue =  _showHourMinute(message.sendDate ?? Timestamp(1,1)) ;
    }catch(e){
      debugPrint("Saat çevirmede hata : $e");
    }

    if (fromMe) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.all(4),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: outgoingMessage,
                    ),
                    child: Text(
                      message.message,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(hourMinuteValue, style: TextStyle(color: Colors.white),),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.typedUser.profileURL),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.all(4),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: incomingMessage,
                    ),
                    child: Text(
                      message.message,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(hourMinuteValue, style: TextStyle(color: Colors.white),),
              ],
            ),
          ],
        ),
      );
    }
  }

  String _showHourMinute(Timestamp sendDate) {
    var formatter = DateFormat.Hm();
    var formattedDate = formatter.format(sendDate.toDate());
    return formattedDate;
  }
}*/