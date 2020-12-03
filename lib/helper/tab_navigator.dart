import 'package:flutter/material.dart';
import '../feed.dart';
import '../search.dart';
import '../profile.dart';
import '../notifications.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;
  static String userName;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (tabItem == "Feed")
      child = Feed();
    else if (tabItem == "Search")
      child = Search();
    else if (tabItem == "Notifications")
      child = Notifications();
    else if (tabItem == "Profile") child = Profile("");
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
