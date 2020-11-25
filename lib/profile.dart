import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
import 'helper/constants.dart';
import 'user.dart';
import 'edit_user_info.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  final String userName;
  Profile(this.userName);

  @override
  State<StatefulWidget> createState() => _ProfileState(userName);
}

class _ProfileState extends State<Profile> {
  String userName; //"" if self profile
  String currUser;
  bool isMyProfile = false;
  String myName = "Loading, please wait.";
  Image profilePicture = Image.memory(base64Decode(Constants
      .sampleProfilePictureBASE64)); //TODO replace with placeholder image, this can not be null
  bool isFollowing = false;
  var userInfo;
  int followerCt = 0;
  int followingCt = 0;
  User thisUser;
  _ProfileState(this.userName);

  @override
  void initState() {
    thisUser = User(userName);
    FlutterSession().get('userName').then((value) {
      currUser = value['data'];
      if (userName == currUser)
        //if user clicks his own profile picture
        isMyProfile = true;
    });
    if (userName == "") {
      //if self profile page
      isMyProfile = true;
      FlutterSession().get('userName').then((value) {
        userName = value['data'];
        currUser = value['data'];
      });
    }
    thisUser.getInfo(userName).then((value) {
      setState(() {
        updateFields(value);
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
        actions: isMyProfile
            ? <Widget>[
                //user shouldn't be able to edit someone else's profile info
                IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditUserInfo(userName, myName, profilePicture)),
                      ).then((up) {
                        if (up != null) {
                          print(up.length);
                          if (up.length == 1 && up[0] is String) {
                            setState(() {
                              thisUser.setName(up[0]).then((value) {
                                setState(() {
                                  updateFields(value);
                                });
                              });
                            });
                          } else {
                            if (up.length == 1 && up[0] is File) {
                              setState(() {
                                thisUser.setPicture(up[0]).then((value) {
                                  print("changing the profile picture");
                                  setState(() {
                                    updateFields(value);
                                  });
                                });
                              });
                            } else {
                              if (up.length == 2 &&
                                  up[0] is String &&
                                  up[1] is File) {
                                setState(() {
                                  thisUser
                                      .setNameAndPicture(up[0], up[1])
                                      .then((value) {
                                    setState(() {
                                      updateFields(value);
                                    });
                                  });
                                });
                              }
                            }
                          }
                        }
                      });
                    })
              ]
            : null,
      ),
      body: new Center(
        child: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              Padding(
                  child: Container(
                      child: CircleAvatar(
                    radius: 100,
                    backgroundImage: profilePicture.image,
                  )),
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
              Text(
                myName,
                style: TextStyle(fontSize: 25),
              ),
              userActions(isMyProfile, isFollowing, userName),
              viewPostsButton(userName),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  switchView(),
                  switchViewToAdmin(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void followRequest(String userName) {
    isFollowing = true;
  } //TODO replace with sending requests then assigning the value.

  void unfollowRequest(String userName) {
    isFollowing = false;
  } //TODO replace with sending requests then assigning the value.

  Widget userActions(bool isMyProfile, bool isFollowing, String userName) {
    if (isMyProfile)
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                return null;
                //TODO redirect to followers list
              },
              child: Text("Followers:" + followerCt.toString()),
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            RaisedButton(
              onPressed: () {
                return null;
                //TODO redirect to following list
              },
              child: Text("Following:" + followingCt.toString()),
            ),
          ]); //instead it returns the delete account stuff
    if (currUser == "ADMIN") {
      //TODO change this to whatever they do to specify admin
      return Column(children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                return null; //TODO
                //ADMIN gets to select the timeout length, user deactivates
              },
              child: Text("DEACTIVATE ACCOUNT"),
              //TODO this is a dropdown where the admin selects a date and sends request to deactivate till that picked date
            ),
            RaisedButton(
              onPressed: () {
                return null; //TODO
              },
              child: Text("DELETE ACCOUNT"),
            ),
          ],
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                return null;
                //TODO redirect to followers list
              },
              child: Text("Followers:" + followerCt.toString()),
            ),
            RaisedButton(
              onPressed: () {
                return null;
                //TODO redirect to following list
              },
              child: Text("Following:" + followingCt.toString()),
            ),
          ],
        ),
      ]);
    } else {
      if (isFollowing)
        return RaisedButton(
          onPressed: () {
            unfollowRequest(userName);
            setState(() {});
          },
          child: Text("UNFOLLOW"),
        );
      else
        return RaisedButton(
          onPressed: () {
            setState(() {
              followRequest(userName);
            });
          },
          child: Text("FOLLOW"),
        );
    }
  }

  Widget viewPostsButton(String userName) {
    return RaisedButton(
      onPressed: () {
        return null;
        //TODO turn the button into a listview of posts.
        //posts=User(userName).getPosts()
        //return listPosts(posts)
      },
      child: Text("Posts by " + userName),
    );
  }

  void aaaaa() {
    isMyProfile = !isMyProfile;
  }

  Widget switchView() {
    return RaisedButton(
      onPressed: () {
        aaaaa();
        setState(() {});
      },
      child: Column(children: <Widget>[
        Text("SWITCH VIEW"),
        Icon(Icons.remove_red_eye),
        Text("THIS IS A DEBUG BUTTON")
      ]),
    );
  }

  void admin() {
    var temp;
    if (currUser != "ADMIN") {
      isMyProfile = false;
      temp = currUser;
      currUser = "ADMIN";
    } else {
      isMyProfile = true;
      currUser = temp;
    }
  }

  Widget switchViewToAdmin() {
    return RaisedButton(
      onPressed: () {
        admin();
        setState(() {});
      },
      child: Column(children: <Widget>[
        Text("SWITCH VIEW TO ADMIN"),
        Icon(Icons.flash_on),
        Text("THIS IS A DEBUG BUTTON")
      ]),
    );
  }

  void updateFields(User value) {
    profilePicture = value.myProfilePicture;
    myName = value.myName;
    isFollowing = value.isFollowing;
    followerCt = value.followerCt;
    followingCt = value.followingCt;
    setState(() {});
  }
}
