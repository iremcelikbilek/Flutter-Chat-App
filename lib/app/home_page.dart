import 'package:canli_sohbet_app/app/custom_bottom_navbar.dart';
import 'package:canli_sohbet_app/app/my_chat_page.dart';
import 'package:canli_sohbet_app/app/profile_page.dart';
import 'package:canli_sohbet_app/app/tab_items.dart';
import 'package:canli_sohbet_app/app/users_page.dart';
import 'package:canli_sohbet_app/notification_handler.dart';
import 'package:canli_sohbet_app/view-models/all_users_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String id;
  HomePage({this.id});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TabItem _currentTab = TabItem.Users;
  Map<TabItem, Widget> allPages() {
    return {
      TabItem.Users: ChangeNotifierProvider(
        create: (context) => AllUsersViewModel(),
        child: UsersPage(),
      ),
      TabItem.MyChat : MyChatPage(),
      TabItem.Profile: ProfilePage(),
    };
  }

  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.Users: GlobalKey<NavigatorState>(), // Yeni nesne
    TabItem.MyChat : GlobalKey<NavigatorState>(),
    TabItem.Profile: GlobalKey<NavigatorState>(), // Yeni nesne
  };

  @override
  void initState() {
    super.initState();
    NotificationHandler().initializeFCMNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await navigatorKeys[_currentTab].currentState.maybePop(),
      child: CustomBottomNavbar(
        navigatorKeys: navigatorKeys,
        pageBuilder: allPages(),
        currentTab: _currentTab,
        onSelectedTab: (tabItem) {
          if(tabItem == _currentTab){
            navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
          }else{
            setState(() {
              _currentTab = tabItem;
            });
          }
          debugPrint("Seçilen Tab Item : $tabItem");
        },
      ),
    );
  }
}

/*Future<bool> _cikisYap(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context,listen: false);
    bool result = await _userViewModel.signOut();
    return result;
  }*/
