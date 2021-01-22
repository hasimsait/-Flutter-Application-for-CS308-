import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'helper/requests.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditUserInfo extends StatefulWidget {
  final String userName;
  final Image profilePicture;
  EditUserInfo(this.userName, this.profilePicture);

  @override
  State<StatefulWidget> createState() =>
      _EditUserInfoState(userName, profilePicture);
}

class _EditUserInfoState extends State<EditUserInfo> {
  final String userName;
  Image profilePicture;
  File newPP;
  final picker = ImagePicker();
  _EditUserInfoState(this.userName, this.profilePicture);
  final _postFieldController = TextEditingController();
  int daysOfSuspension = 0;
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
                Requests()
                    .updateUserInfo(_postFieldController.text, newPP)
                    .then((value) {
                  if (value) {
                    if (_postFieldController.text != null && newPP == null)
                      Navigator.pop(context, [_postFieldController.text]);
                    else if (_postFieldController.text == "" && newPP != null)
                      Navigator.pop(context, [newPP]);
                    else if (_postFieldController.text != null && newPP != null)
                      Navigator.pop(
                          context, [_postFieldController.text, newPP]);
                  } else {
                    //display error message
                  }
                });
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
                decoration: InputDecoration(hintText: userName),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.check_circle_outline_rounded),
                      iconSize: 50,
                      onPressed: () {
                        Requests()
                            .updateUserInfo(_postFieldController.text, newPP)
                            .then((value) {
                          if (value) {
                            print(
                                "EDIT_USER_INFO.DART: user info successfully edited, popping the current route.");
                            Navigator.pop(context);
                          } else {
                            //display error message
                          }
                        });
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
                  _showDialog();
                },
                child: Text("DEACTIVATE ACCOUNT"),
              ),
              RaisedButton(
                onPressed: () {
                  Requests().deleteAccount(userName).then((value) {
                    if (value) {
                      Flushbar(
                        title: "Success!",
                        message: "Account successfully deleted!",
                        duration: Duration(seconds: 3),
                      )..show(context);
                    } else {
                      Flushbar(
                        title: "Something went wrong.",
                        message:
                            "Account could not be deleted, please try again later.",
                        duration: Duration(seconds: 3),
                      )..show(context);
                    }
                  });
                },
                child: Text("DELETE ACCOUNT"),
              ),
            ],
          ),
        ),
      ),
    );
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

  void _showDialog() {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 0,
            maxValue: 1000000000000,
            title: new Text("Pick days of suspension"),
            initialIntegerValue: daysOfSuspension,
          );
        }).then((value) {
      if (value != null) {
        setState(() => daysOfSuspension = value);
        Requests().timeOutAccount(userName, daysOfSuspension).then((value) {
          if (value) {
            Flushbar(
              title: "Success!.",
              message: "User successfully suspended!",
              duration: Duration(seconds: 3),
            )..show(context);
            setState(() {}); //so that the post disappears
          } else {
            Flushbar(
              title: "Something went wrong.",
              message: "User could not be suspended, please try again later.",
              duration: Duration(seconds: 3),
            )..show(context);
            print("PROFILE.DART: Couldn't report user:" + userName);
          }
        });
      }
    });
  }
}
