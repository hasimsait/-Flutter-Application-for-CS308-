//TODO add profile route
//TODO send a request to the backend, parse it and display.
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
import 'profile_picture.dart';
import 'helper/constants.dart';
import 'user.dart';
import 'edit_user_info.dart';

class Profile extends StatefulWidget {
  final String
      userName; //this may be a string or whatever, TODO change accordingly.
  Profile(this.userName);

  @override
  State<StatefulWidget> createState() => _ProfileState(userName);
}

class _ProfileState extends State<Profile> {
  String userName; //"" if self profile
  bool isMyProfile = false;
  String myName = "Loading, please wait.";
  Image profilePicture =
      Image.memory(base64Decode(Constants.sampleProfilePictureBASE64));//TODO replace with placeholder image, this can not be null

  _ProfileState(this.userName);

  @override
  void initState() {
    if (userName == "") {
      //if self profile
      isMyProfile = true;
      FlutterSession().get('userName').then((value) {
        userName = value['data'];
      });
    }
    User(userName).getInfo().then((value) {
      setState(() {
        profilePicture = value.myProfilePicture;
        myName = value.myName;
        //...TODO set the rest of the fields accordingly
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          userName,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: <Widget>[
          isMyProfile
              ?
              //user shouldn't be able to edit someone else's profile info
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    //TODO edit user info part
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditUserInfo(userName,myName,profilePicture)),
                    );
                  })
              : null,
        ],
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            Padding(
              child: Container(
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
          ],
        ),
      ),
    );
  }
}

/*
Widget Profile () {
  return Scaffold();
}*/
