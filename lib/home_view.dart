import 'package:flutter/material.dart';
import 'helper/tab_navigator.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _currentPage = "Feed";
  List<String> pageKeys = ["Feed", "Search", 'Messages',"Notifications", "Profile"];
  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Feed": GlobalKey<NavigatorState>(),
    "Search": GlobalKey<NavigatorState>(),
    "Messages": GlobalKey<NavigatorState>(),
    "Notifications": GlobalKey<NavigatorState>(),
    "Profile": GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 0;

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentPage].currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != "Feed") {
            _selectTab("Feed", 1);
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          _buildOffstageNavigator("Feed"),
          _buildOffstageNavigator("Search"),
          _buildOffstageNavigator("Messages"),
          _buildOffstageNavigator("Notifications"),
          _buildOffstageNavigator("Profile"),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blueAccent,
          onTap: (int index) {
            _selectTab(pageKeys[index], index);
          },
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.email),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}
