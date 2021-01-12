import 'package:canli_sohbet_app/app/chat_page.dart';
import 'package:canli_sohbet_app/models/conversation.dart';
import 'package:canli_sohbet_app/view-models/chat_view_model.dart';
import 'package:canli_sohbet_app/view-models/user_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyChatPage extends StatefulWidget {
  @override
  _MyChatPageState createState() => _MyChatPageState();
}

class _MyChatPageState extends State<MyChatPage> {
  @override
  Widget build(BuildContext context) {
    var _userViewModel = Provider.of<UserViewModel>(context);
    //_getMyChat();
    return Scaffold(
      appBar: AppBar(title: Text("My Chat"),),
      body: StreamBuilder(
        stream: _userViewModel.getAllConversation(_userViewModel.userModel.userID),
        builder: (BuildContext context, AsyncSnapshot<List<Conversation>> snapshot){
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }else{
            var allConversations = snapshot.data;
            if(allConversations.length >0 ){
              return ListView.builder(
                itemCount: allConversations.length,
                itemBuilder: (context, index){
                  var duration = DateTime.now().difference(allConversations[index].creation_date.toDate());
                  timeago.setLocaleMessages("tr", timeago.TrMessages());
                  var aradakiFark = timeago.format(DateTime.now().subtract(duration),locale: "tr");
                  return ListTile(
                    onTap: () async{
                      var typedUser = await _userViewModel.getUser(allConversations[index].talking_with);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                            create: (context) => ChatViewModel(currentUser: _userViewModel.userModel, typedUser: typedUser),
                            child: ChatPage()
                        ),),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(allConversations[index].talkingWithProfileURL),
                    ),
                    title: Text(allConversations[index].talkingWithUserName),
                    subtitle: Text(allConversations[index].last_message+ "  " + aradakiFark),
                  );
                },
              );
            }else{
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat,size: 50,color: Theme.of(context).primaryColor,),
                    Text("Henüz Konuşmanız Yok",style: TextStyle(fontSize: 20),),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _getMyChat() async{
    final userViewModel = Provider.of<UserViewModel>(context);
     var myChat = await FirebaseFirestore.instance.collection("chat")
         .where("chat_owner", isEqualTo: userViewModel.userModel.userID)
         .orderBy("creation_date", descending: true)
         .get();
     for(var chat in myChat.docs){
       print("chat: ${chat.data()}");
     }
  }
}
