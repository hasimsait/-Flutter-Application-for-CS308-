import 'package:flutter/material.dart';
import 'feed.dart';
class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  Widget build(BuildContext context) {

    Widget child ;
    if(tabItem == "Feed")
      child = feed();
    //else if(tabItem == "Page2")//TODO refactor the tabitem string and create builders, otherwise they will keep throwing exceptions.
      //child = Page2();
    //else if(tabItem == "Page3")
      //child = Page3();

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => child
        );
      },
    );
  }
}

