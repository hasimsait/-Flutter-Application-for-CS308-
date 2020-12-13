import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
import 'helper/constants.dart';
import 'helper/requests.dart';
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
  Image profilePicture =
      Image.memory(base64Decode(Constants.sampleProfilePictureBASE64));
  bool isFollowing = false;
  var userInfo;
  int followerCt = 0;
  int followingCt = 0;
  User thisUser;
  _ProfileState(this.userName);

  @override
  void initState() {
    print('profile.dart: the username is: '+Requests.currUserName.toString());
      currUser = Requests.currUserName;
      if (userName == currUser)
        //if user clicks his own profile picture or something
        isMyProfile = true;

    if (userName == "") {
      //if self profile page
      isMyProfile = true;
        userName = Requests.currUserName;
        currUser = Requests.currUserName;
        print('PROFILE.DART: looking up self profile, username set to: '+userName);
    }
    thisUser = User(userName);
    thisUser.getInfo().then((value) {
      thisUser=value;
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
                                EditUserInfo(userName, profilePicture)),
                      ).then((up) {
                        //edit user info calls requests.edit anyways, just update the user accordingly
                        // ie. why did I send the same request twice?
                        // found the answer: to be able to show it update in demo
                        thisUser.getInfo().then((value) {
                          setState(() {
                            updateFields(value);
                          });
                        });
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
              viewPosts(userName),
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
  } //TODO REQUEST replace with sending requests then assigning the value.

  void unfollowRequest(String userName) {
    isFollowing = false;
  } //TODO REQUEST replace with sending requests then assigning the value.

  Widget userActions(bool isMyProfile, bool isFollowing, String userName) {
    if (isMyProfile)
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                return null;
                //TODO REQUEST redirect to followers list
              },
              child: Text("Followers:" + followerCt.toString()),
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            RaisedButton(
              onPressed: () {
                return null;
                //TODO REQUEST redirect to following list
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
                return null; //TODO REQUEST
                //ADMIN gets to select the timeout length, user deactivates
              },
              child: Text("DEACTIVATE ACCOUNT"),
              //TODO this is a dropdown where the admin selects a date and sends request to deactivate till that picked date
            ),
            RaisedButton(
              onPressed: () {
                Requests().deleteAccount().then((value) {
                  //TODO display success message or failed
                });
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
                //TODO REQUEST redirect to followers list
              },
              child: Text("Followers:" + followerCt.toString()),
            ),
            RaisedButton(
              onPressed: () {
                return null;
                //TODO REQUEST redirect to following list
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

  Widget viewPosts(String userName) {
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
    profilePicture = Image.memory(base64Decode(value.myProfilePicture));
    myName = value.myName;
    isFollowing = value.isFollowing;
    followerCt = value.followerCt;
    followingCt = value.followingCt;
    setState(() {});
  }
}
