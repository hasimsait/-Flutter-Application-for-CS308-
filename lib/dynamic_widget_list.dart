import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teamone_social_media/profile.dart';
import 'package:teamone_social_media/user.dart';

import 'helper/requests.dart';

class DynamicWidgetList extends StatefulWidget {
  final List<List<dynamic>> elements;
  //[username],
  //[topicName],
  //[locationId],
  //in this order, always.
  DynamicWidgetList(this.elements);
  @override
  State<StatefulWidget> createState() => _DynamicWidgetListState(this.elements);
}

class _DynamicWidgetListState extends State<DynamicWidgetList> {
  List<List<dynamic>> elements;
  _DynamicWidgetListState(this.elements);
  List<Widget> elementWidgets = [];

  void initState() {
    super.initState();
    _listUsers().then((value) {
      elementWidgets=value;
      for (int i = 0; i < elements[1].length; i++) {
        //topic with unfollow button
        try {
          elementWidgets.add(
            Row(
              children: <Widget>[
                Text(elements[1][i]),
                RaisedButton(
                    child: Text('unfollow this topic'),
                    onPressed: () {
                      Requests().unfollowTopic(elements[1][i]);
                    })
              ],
            ),
          );
        } catch (Exception) {
          print('DYNAMIC WIDGET LIST.DART: A TOPIC FUCKED UP WHILE LISTING');
        }
      }
      for (int i = 0; i < elements[2].length; i++) {
        try {
          elementWidgets.add(
            Row(
              children: <Widget>[
                Text(elements[2][i]),
                RaisedButton(
                    child: Text('unfollow this location'),
                    onPressed: () {
                      Requests().unfollowLocation(elements[2][i]);
                    })
              ],
            ),
          );
        } catch (Exception) {
          print('DYNAMIC WIDGET LIST.DART: A LOCATION FUCKED UP WHILE LISTING');
        }
      }
      if(elementWidgets==null ){
        print("DYNAMIC WIDGET LIST.DART: nothing to list");
        elementWidgets=[];
        elementWidgets.add(SizedBox());
      }
      print("DYNAMIC WIDGET LIST.DART: done listing");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(),
      body: new Center(
        child: ListView(children: elementWidgets),
      ),
    );
  }

  Future<List<Widget>>_listUsers() async {
    List<Widget> temp=[];
    for (int i = 0; i < elements[0].length; i++) {
      try {
        //pp and name, pp is anchor
        var user = elements[0][i];
        User thisUser = User(user);
        thisUser=await thisUser.getInfo();
          temp.add(
            IconButton(
              icon: CircleAvatar(
                  radius: 25,
                  backgroundImage:
                  Image.memory(base64Decode(thisUser.myProfilePicture))
                      .image),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile(user)),
                );
              },
            ),
          );
      } catch (Exception) {
        print('DYNAMIC WIDGET LIST.DART: A USER FUCKED UP WHILE LISTING');
      }
      print("DYNAMIC WIDGET LIST.DART: done listing users");
      return temp;
    }
  }
}
