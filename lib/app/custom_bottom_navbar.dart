import 'package:canli_sohbet_app/app/tab_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectedTab;
  final Map<TabItem, Widget> pageBuilder;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;

  const CustomBottomNavbar(
      {Key key,
      @required this.currentTab,
      @required this.onSelectedTab,
      @required this.pageBuilder,
      @required this.navigatorKeys})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          _createNavbarItem(TabItem.Users),
          _createNavbarItem(TabItem.MyChat),
          _createNavbarItem(TabItem.Profile),
        ],
        onTap: (index) => onSelectedTab(TabItem.values[index]),
      ),
      tabBuilder: (context, index) {
        final tabToBeCreated = TabItem.values[index];

        return CupertinoTabView(
          navigatorKey: navigatorKeys[tabToBeCreated],
          builder: (context) {
            return pageBuilder[tabToBeCreated];
          },
        );
      },
    );
  }

  BottomNavigationBarItem _createNavbarItem(TabItem tabItem) {
    final createTab = TabItemData.allTabs[tabItem];

    return BottomNavigationBarItem(
      icon: Icon(createTab.icon),
      label: createTab.title,
    );
  }
}
