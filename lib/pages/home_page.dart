import 'package:flutter/material.dart';
import 'package:luxury_guide_project/pages/people_tab_page.dart';
import 'package:luxury_guide_project/pages/profile_tab_page.dart';
import 'package:provider/provider.dart';

import '../model/m_user.dart';
import '../view_model/people_tab_page_view_model.dart';
import '../view_model/profile_tab_page_view_model.dart';
import 'chat_tab_page.dart';
import 'my_custom_nav_bar.dart';

class HomePage extends StatefulWidget {
  MUser sessionOwner;

  HomePage({required this.sessionOwner, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.People;

  Widget _buildPage(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.Profile:
        return ChangeNotifierProvider(
            create: (context) => ProfileTabPageViewModel(),
            child: ProfilePage(SessionOwner: widget.sessionOwner));
      case TabItem.People:
        return ChangeNotifierProvider(
          create: (context) => PeopleTabPageViewModel(),
          child: PeopleTabPage(gelenSessionOwner: widget.sessionOwner),
        );
      case TabItem.Chat:
        return ChatTabPage(
          gelenSessionOwner: widget.sessionOwner,
        );

      // return ChatListPage();
    }
  }

  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.People: GlobalKey<NavigatorState>(),
    TabItem.Chat: GlobalKey<NavigatorState>(),
    TabItem.Profile: GlobalKey<NavigatorState>()
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var result =
            await navigatorKeys[_currentTab]?.currentState?.maybePop(context);
        var reverseResult = !result!;
        return reverseResult;
      },
      child: MyCustomNavigationBar(
        navigatorKeys: navigatorKeys,
        buildPage: _buildPage,
        currentTab: _currentTab,
        onSelected: (TabItem secilenTab) {
          setState(() {
            _currentTab = secilenTab;
          });
          print("Secili tab:${secilenTab}");
        },
      ),
    );
  }
}
