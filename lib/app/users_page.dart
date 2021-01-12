import 'package:canli_sohbet_app/app/chat_page.dart';
import 'package:canli_sohbet_app/models/user.dart';
import 'package:canli_sohbet_app/view-models/all_users_view_model.dart';
import 'package:canli_sohbet_app/view-models/chat_view_model.dart';
import 'package:canli_sohbet_app/view-models/user_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    //minScroolExtent listenin en sonuna geldiğimizde olur.
    //maxScroolExtent listenin en başına geldiğimizde olur.
    _scrollController.addListener(_listScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    //UserViewModel userViewModel = Provider.of<UserViewModel>(context);
    //userViewModel.getAllUsers();
    return Scaffold(
      appBar: AppBar(
        title: Text("Kullanıcılar"),
      ),
      body: Consumer<AllUsersViewModel>(
        builder: (BuildContext context, AllUsersViewModel model, Widget child){
          if(model.state == AllUserViewState.Busy){
            return Center(child: CircularProgressIndicator());
          }else if(model.state == AllUserViewState.Loaded){
            return RefreshIndicator(
              onRefresh: model.refresh,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: (model.hasMore) ? model.allUsers.length + 1 : model.allUsers.length,
                itemBuilder: (context, index) {
                  if(model.hasMore && index == model.allUsers.length){
                    return _waitForNewUserList();
                  }else{
                    return _userListDelegate(index);
                  }
                },
              ),
            );
          }else{
            return Container();
          }
        },
      ),
    );
  }

  /*getUser() async{
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    if (!_hasMore) {
      print("Firebaseden boşuna veri çekilmeyecek");
      return;
    }
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var userList = await userViewModel.getUsersWithPagination(_theLastUserToGet, _elementToBeGet);
     // _alUsers yerine theLastUserToGet alındı refresh indicator kullanımı için düzelteme.....
    if(_theLastUserToGet == null){
      _allUsers = [];
      _allUsers.addAll(userList);
    }else{
      _allUsers.addAll(userList);
    }

    if (userList.length < _elementToBeGet) {
      _hasMore = false;
    }

    _theLastUserToGet = _allUsers.last;

    setState(() {
      _isLoading = false;
    });
  }*/

  /*getUser1(UserModel theLastUserToGet) async {
    if (!_hasMore) {
      print("Firebaseden boşuna veri çekilmeyecek");
      return;
    }
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot;

    if (theLastUserToGet == null) {
      print("İlk defa kullanıcılar getiriliyor");
      querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .orderBy("userName")
          .limit(_elementToBeGet)
          .get();
      _allUsers = [];
    } else {
      print("Sonraki kullanıcılar getiriliyor");
      querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .orderBy("userName")
          .startAfter([theLastUserToGet.userName])
          .limit(_elementToBeGet)
          .get();
    }

    if (querySnapshot.docs.length < _elementToBeGet) {
      _hasMore = false;
    }

    for (DocumentSnapshot snapshot in querySnapshot.docs) {
      UserModel singleUser = UserModel.fromMap(snapshot.data());
      _allUsers.add(singleUser);
      print("Getirilen userName: ${singleUser.userName}");
    }

    _theLastUserToGet = _allUsers.last;
    print("En son getirilen userName: $_theLastUserToGet");
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }*/

  /*Widget _createUserList() {
    if(_allUsers.length > 1){
      return RefreshIndicator(
        onRefresh: _userListRefresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _allUsers.length + 1,
          itemBuilder: (context, index) {
            print("index değeri: $index ve Listedeki toplam eleman sayısı : ${_allUsers.length}");
            if(index == _allUsers.length){
              print("Yeni elemanlar bekleniyor");
              return _waitForNewUserList();
            }
            return _userListDelegate(index);
          },
        ),
      );
    }else{
      return Center(
        child: Text("Gösterilecek kullanıcı yok"),
      );
    }

  }*/

  Widget _userListDelegate(int index) {

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final allUsersViewModel = Provider.of<AllUsersViewModel>(context);

    var delegate = allUsersViewModel.allUsers[index];

    if(delegate.userID == userViewModel.userModel.userID) return Container();
    return Card(
      color: Colors.cyan.withAlpha(20),
      elevation: 2,
      child: ListTile(
        onTap: (){
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
              create: (context) => ChatViewModel(currentUser: userViewModel.userModel, typedUser: delegate),
                child: ChatPage()
            ),
            ),
          );
        },
        leading: CircleAvatar(backgroundImage: NetworkImage(delegate.profileURL),),
        title: Text(delegate.userName),
        subtitle: Text(delegate.eMail),
      ),
    );
  }

  Widget _waitForNewUserList() {
    return Padding(padding: EdgeInsets.all(8),
    child: Center(
      child: CircularProgressIndicator(),
    ),);
  }

  /*Future<Null> _userListRefresh() async{
    //_allUsers = [];
    _theLastUserToGet = null;
    _hasMore = true;
    getUser();
  }*/

  void getMoreUsers() async{
    if(_isLoading == false){
      _isLoading = true;
      final allUsersViewModel = Provider.of<AllUsersViewModel>(context,listen: false);
      await allUsersViewModel.getMoreUsers();
      _isLoading = false;
    }

  }

  void _listScrollListener() {
    if(_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange ){
      getMoreUsers();
    }

    /*   if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          print("Sayfanın en başındayız");
        } else {
          print("Listenin sonundayız");
          getMoreUsers();
        }
      }*/
  }
}

/*Scaffold(
      appBar: AppBar(
        title: Text("Users"),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: userViewModel.getAllUsers(),
        builder:
            (BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) {
          if (snapshot.hasData) {
            List<UserModel> allUsers = snapshot.data;
            if (allUsers.length > 0) {
              return RefreshIndicator(
                onRefresh: _refreshUserList,
                child: ListView.builder(
                    itemCount: allUsers.length,
                    itemBuilder: (context, index) {
                      if (allUsers[index].userID != userViewModel.userModel.userID) {
                        return ListTile(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(builder: (context) => ChatPage(currentUser: userViewModel.userModel, typedUser: allUsers[index])),
                            );
                          },
                          title: Text(allUsers[index].userName),
                          subtitle: Text(allUsers[index].eMail),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(allUsers[index].profileURL),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),
              );
            } else {
              return Center(
                  child: Text("Kayıtlı bir kullanıcı bulunmamaktadır"));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );*/

/*Future<Null> _refreshUserList() async{
    setState(() {});
    Future.delayed(Duration(seconds: 2));
    return null;
  }*/
