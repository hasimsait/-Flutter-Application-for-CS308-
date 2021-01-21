import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teamone_social_media/profile.dart';
import 'package:teamone_social_media/user.dart';

import 'helper/requests.dart';

class DynamicWidgetList extends StatefulWidget {
  final List<List<dynamic>> elements;
  final bool noAppBar;
  //[username],
  //[topicName],
  //[locationId],
  //in this order, always.
  DynamicWidgetList(this.elements,{this.noAppBar});
  @override
  State<StatefulWidget> createState() => _DynamicWidgetListState(this.elements,(this.noAppBar!=null&&this.noAppBar==true));
}

class _DynamicWidgetListState extends State<DynamicWidgetList> {
  List<List<dynamic>> elements;
  bool noAppBar;
  _DynamicWidgetListState(this.elements,this.noAppBar);
  List<Widget> elementWidgets = [];

  void initState() {
    super.initState();
    _listUsers().then((value) {
      elementWidgets = value;
      for (int i = 0; i < elements[1].length; i++) {
        //topic with unfollow button
        try {
          elementWidgets.add(
              Card(child:Padding(padding:EdgeInsets.fromLTRB(5, 0, 5, 0) ,child:
            Row(
              children: <Widget>[
            Container(alignment: Alignment.centerLeft,width: 205,child:Flex(direction: Axis.vertical,children:<Widget>[Text(elements[1][i])]),),
                RaisedButton(
                    child: Text('unfollow this topic'),
                    onPressed: () {
                      Requests().unfollowTopic(elements[1][i]);
                    })
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),),),
          );
        } catch (Exception) {
          print('DYNAMIC WIDGET LIST.DART: A TOPIC FUCKED UP WHILE LISTING');
        }
      }
      for (int i = 0; i < elements[2].length; i++) {
        try {
          elementWidgets.add(
              Card(child:Padding(padding:EdgeInsets.fromLTRB(5, 0, 5, 0) ,child:
            Row(
              children: <Widget>[
            Container(alignment: Alignment.centerLeft,width: 205,child:Flex(direction: Axis.vertical,children:<Widget>[Text(elements[2][i]),],),),
                RaisedButton(
                    child: Text('unfollow this location'),
                    onPressed: () {
                      Requests().unfollowLocation(elements[2][i]);
                    })
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),),),
          );
        } catch (Exception) {
          print('DYNAMIC WIDGET LIST.DART: A LOCATION FUCKED UP WHILE LISTING');
        }
      }
      if (elementWidgets == null) {
        print("DYNAMIC WIDGET LIST.DART: nothing to list");
        elementWidgets = [];
        elementWidgets.add(SizedBox());
      }
      print("DYNAMIC WIDGET LIST.DART: done listing");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.noAppBar!=null && this.noAppBar==true)
      return new Scaffold(
        body: new Center(
          child: ListView(children: elementWidgets),
        ),
      );
    return new Scaffold(
      appBar: AppBar(),
      body: new Center(
        child: ListView(children: elementWidgets),
      ),
    );
  }

  Future<List<Widget>> _listUsers() async {
    List<Widget> temp = [];
    //print('::::::::::::::::::::::::::::::::');
    //print(elements[0].length.toString());
    for (int i = 0; i < elements[0].length; i++) {
      try {
        //print('SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS');
        //pp and name, pp is anchor
        var user = elements[0][i];
        User thisUser = User(user);
        thisUser = await thisUser.getInfo();
        temp.insert(
          i,
            Card(child:Padding(padding:EdgeInsets.fromLTRB(5, 0, 5, 0) ,child:
          Row(children:<Widget>[
          IconButton(
            iconSize: 50,
            icon: CircleAvatar(
                radius: 50,
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
                Container(alignment: Alignment.centerLeft,width: 205,child:Flex(direction: Axis.vertical,children:<Widget>[Text(
              user,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 25),
            ),]))
          ],
        ))));
      } catch (Exception) {
        print('DYNAMIC WIDGET LIST.DART: A USER FUCKED UP WHILE LISTING');
      }
    }
    print("DYNAMIC WIDGET LIST.DART: done listing " +
        temp.length.toString() +
        " users");
    return temp;
  }
}
