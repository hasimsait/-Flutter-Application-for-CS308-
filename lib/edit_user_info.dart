import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
import 'profile_picture.dart';
import 'helper/constants.dart';
import 'user.dart';
import 'package:image_picker/image_picker.dart';

class EditUserInfo extends StatefulWidget {
  final String userName;
  String myName;
  Image profilePicture;
  EditUserInfo(this.userName, this.myName, this.profilePicture);

  @override
  State<StatefulWidget> createState() =>
      _EditUserInfoState(userName, myName, profilePicture);
}

class _EditUserInfoState extends State<EditUserInfo> {
  final String
      userName; //this may be a string or whatever, TODO change accordingly.
  String myName;
  Image profilePicture;
  _EditUserInfoState(this.userName, this.myName, this.profilePicture);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          //TODO turn this into an input field with validation
          userName,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check_circle_outline_rounded),
              onPressed: () {
                //TODO send the request to save changes and pop route
              }),
          IconButton(
              icon: Icon(Icons.cancel_outlined),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            Padding(
              child: Container(
                  //TODO turn this into a image_picker preview
                  child: CircleAvatar(
                radius: 100,
                backgroundImage: profilePicture.image,
              )),
              padding: EdgeInsets.all(10),
            ),
            Text(
              myName,
              style: TextStyle(fontSize: 25),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.check_circle_outline_rounded),
                    iconSize: 50,
                    onPressed: () {
                      //TODO send the request to save changes and pop route
                    }),
                IconButton(
                    icon: Icon(Icons.cancel_outlined),
                    iconSize: 50,
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ),
            RaisedButton(
              onPressed: () {
                return null;
                //TODO
              },
              child: Text("DEACTIVATE ACCOUNT"),
            ),
            RaisedButton(
              onPressed: () {
                return null;//TODO
              },
              child: Text("DELETE ACCOUNT"),
            ),
          ],
        ),
      ),
    );
  }
}
