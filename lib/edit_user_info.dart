import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
import 'profile_picture.dart';
import 'helper/constants.dart';
import 'user.dart';
import 'dart:io';
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
  final String userName;
  String myName;
  Image profilePicture;
  File newPP;
  final picker = ImagePicker();
  _EditUserInfoState(this.userName, this.myName, this.profilePicture);
  final _postFieldController = TextEditingController();
  void initState() {
    //this must stay here
    super.initState();
    _postFieldController.addListener(() {
      final text = _postFieldController.text;
      _postFieldController.value = _postFieldController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  void dispose() {
    _postFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          userName + "'s settings",
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check_circle_outline_rounded),
              onPressed: () {
                updateUserInfo(_postFieldController.text, newPP);
              }),
          IconButton(
              icon: Icon(Icons.cancel_outlined),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
      body: new Center(
        child: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              Padding(
                child: Container(
                  child: IconButton(
                    icon: CircleAvatar(
                      radius: 100,
                      backgroundImage: profilePicture.image,
                    ),
                    iconSize: 200,
                    onPressed: () {
                      _getImage(ImageSource.gallery);
                    },
                  ),
                ),
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              ),
              new TextFormField(
                controller: _postFieldController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(hintText: myName),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.check_circle_outline_rounded),
                      iconSize: 50,
                      onPressed: () {
                        updateUserInfo(_postFieldController.text, newPP);
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
                  return null; //TODO
                },
                child: Text("DELETE ACCOUNT"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateUserInfo(String newName, File newPP) {
    if (newName != null && newPP == null) {
      myName = newName;
      print(myName);
      //TODO name validator creates error message
      if (Constants.DEPLOYED) {
        //TODO get selected Image, turn it into string and post the request to change user info, if response is succes, setstate and pop.
      } else {
        Navigator.pop(context, [myName]);
      }
      return null;
    }
    if (newName == "" && newPP != null) {
      if (Constants.DEPLOYED) {
        //TODO get selected Image, turn it into string and post the request to change user info, if response is succes, setstate and pop.
      } else {
        Navigator.pop(context, [newPP]);
      }
      return null;
    }
    if (newName != null && newPP != null) {
      myName = newName;
      print(myName);
      //TODO name validator creates error message
      if (Constants.DEPLOYED) {
        //TODO get selected Image, turn it into string and post the request to change user info, if response is succes, setstate and pop.
      } else {
        Navigator.pop(context, [myName, newPP]);
      }
      return null;
    }
  }

  Future _getImage(source) async {
    //we may make it return file and fileType instead of setState
    setState(() {
      newPP = null;
    });

    final pickedFile = await picker.getImage(source: source);
    setState(() {
      if (pickedFile != null && pickedFile.path != null) {
        newPP = File(pickedFile.path);
        print("got the newly selected picture");
        profilePicture = Image.file(
          File(newPP.path),
        );
        setState(() {
          print("set the preview image to the newly selected picture");
        });
      } else {
        print('No image selected.');
      }
    });
  }
}