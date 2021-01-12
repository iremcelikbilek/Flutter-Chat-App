import 'package:canli_sohbet_app/locator.dart';
import 'package:canli_sohbet_app/models/user.dart';
import 'package:canli_sohbet_app/repository/user_repository.dart';
import 'package:flutter/material.dart';

enum AllUserViewState {Idle, Loaded, Busy}

class AllUsersViewModel with ChangeNotifier{
  UserRepository _repository = locator<UserRepository>();
  AllUserViewState _state = AllUserViewState.Idle;
  List<UserModel> _allUsers;
  UserModel _theLastUserToGet;
  static final _elementToBeGet = 10;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  List<UserModel> get allUsers => _allUsers;

  AllUserViewState get state => _state;

  set state(AllUserViewState value) {
    _state = value;
    notifyListeners();
  }

  AllUsersViewModel(){
    _allUsers = [];
    _theLastUserToGet = null;
    getUsersWithPagination(_theLastUserToGet, false);
  }

  Future<void> getUsersWithPagination(UserModel theLastUserToGet, bool isNewElement) async{

    if(_allUsers.length > 0){
      _theLastUserToGet = _allUsers.last;
      print("En son getirilen userName : ${_theLastUserToGet.userName}");
    }

    if(isNewElement){

    }else{
      //_state değişkenini değil state kullanıyorum çünkü zaten set metodu benim _state değerime bu yeni değeri atıyor !!!
      state = AllUserViewState.Busy;
    }

    List<UserModel> newList = await  _repository.getUsersWithPagination(_theLastUserToGet, _elementToBeGet);
    newList.forEach((user) => print("Getirilen userName : ${user.userName}"));

    if(newList.length < _elementToBeGet){
      _hasMore = false;
    }

    _allUsers.addAll(newList);
    state = AllUserViewState.Loaded;
  }

  Future<void> getMoreUsers() async{
    print("AllUsersViewModel'deki getMoreUsers tetiklendi");
    if(_hasMore) getUsersWithPagination(_theLastUserToGet, true);
    else print("Daha fazla eleman yok o yüzden eleman çağırılmayacak");
    await Future.delayed(Duration(seconds: 2));
  }

  Future<Null> refresh() async{
    _hasMore = true;
    _theLastUserToGet = null;
    getUsersWithPagination(_theLastUserToGet, false);
  }
}