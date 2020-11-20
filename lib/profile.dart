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
  String currUser;
  bool isMyProfile = false;
  String myName = "Loading, please wait.";
  Image profilePicture = Image.memory(base64Decode(Constants
      .sampleProfilePictureBASE64)); //TODO replace with placeholder image, this can not be null
  bool isFollowing = false;
  var userInfo;
  int followerCt=0;
  int followingCt=0;
  _ProfileState(this.userName);

  @override
  void initState() {
    FlutterSession().get('userName').then((value) {
      currUser = value['data'];
    });
    if (userName == "") {
      //if self profile
      isMyProfile = true;
      FlutterSession().get('userName').then((value) {
        userName = value['data'];
        currUser=value['data'];
      });
    }
    User(userName).getInfo(userName).then((value) {
      setState(() {
        profilePicture = value.myProfilePicture;
        myName = value.myName;
        isFollowing = value.isFollowing;
        followerCt = value.followerCt;
        followingCt=value.followingCt;
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
                      );
                    })
              ]
            : null,
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
            followButton(isMyProfile, isFollowing, userName),
            viewPostsButton (userName),
            switchView(),
          ],
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

  Widget followButton(bool isMyProfile, bool isFollowing, String userName) {
    if (isMyProfile)
      return Column(children: <Widget>[
        RaisedButton(
          onPressed: () {
            return null;
            //TODO redirect to followers list
          },
          child: Text("Followers:"+followerCt.toString()),
        ),
        RaisedButton(
          onPressed: () {
            return null;
            //TODO redirect to following list
          },
          child: Text("Following:"+followingCt.toString()),
        ),
      ]); //instead it returns the delete account stuff
    if(currUser=="ADMIN"){
      //TODO change this to whatever they do for admin
        return Column(children: <Widget>[
          RaisedButton(
            onPressed: () {
              return null;//TODO
              //ADMIN gets to select the timeout length, user deactivates
            },
            child: Text("DEACTIVATE ACCOUNT"),
          ),
          RaisedButton(
            onPressed: () {
              return null;//TODO
            },
            child: Text("DELETE ACCOUNT"),
          ),
          RaisedButton(
            onPressed: () {
              return null;
              //TODO redirect to followers list
            },
            child: Text("Followers:"+followerCt.toString()),
          ),
          RaisedButton(
            onPressed: () {
              return null;
              //TODO redirect to following list
            },
            child: Text("Following:"+followingCt.toString()),
          ),
        ]);
    }
    else {
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

  Widget viewPostsButton (String userName) {
    return RaisedButton(
      onPressed: () {
        return null;
        //TODO turn the button into a listview of posts.
        //posts=User(userName).getPosts()
        //return listPosts(posts)
      },
      child: Text("Posts by "+userName),
    );
  }
}

