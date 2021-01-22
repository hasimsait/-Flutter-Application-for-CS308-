import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
import 'package:teamone_social_media/dynamic_widget_list.dart';
import 'helper/constants.dart';
import 'helper/requests.dart';
import 'user.dart';
import 'edit_user_info.dart';
import 'specificPost.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:teamone_social_media/recommendations.dart';
import 'dart:io';
import 'package:flushbar/flushbar.dart';

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
  List<Widget> postWidgets;
  int daysOfSuspension = 0;
  Widget recommendations =
      Text('Please wait while we retrieve recommendations');

  @override
  void initState() {
    print('profile.dart: the username is: ' + Requests.currUserName.toString());
    currUser = Requests.currUserName;
    if (userName == currUser)
      //if user clicks his own profile picture or something
      isMyProfile = true;

    if (userName == "") {
      //if self profile page
      isMyProfile = true;
      userName = Requests.currUserName;
      currUser = Requests.currUserName;
      print('PROFILE.DART: looking up self profile, username set to: ' +
          userName);
    }
    thisUser = User(userName);
    thisUser.getInfo().then((value) {
      thisUser = value;
      //print(thisUser.posts.length);
      setState(() {
        updateFields(value);
      });
    });
    getRecommended();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    postWidgets = [SizedBox()];
    //EVEN THIS DOES NOT MAKE IT CREATE THE SPECIFIC POST WIDGETS FROM SCRATCH. FUCK IT I'M NOT WASTING MORE TIME ON THIS BULLSHIT. YOU COULD MAKE THE EDIT_POST RETURN A POST WHEN REQUEST IS SUCCESSFUL AND UPDATE THE SPECIFIC POST WIDGET WITH IT, IT WOULD LOOK HORRIBLE THO.
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
        child: new ListView(
          children: <Widget>[
            new Column(
              children: <Widget>[
                Padding(
                    child: Container(
                        child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profilePicture.image,
                    )),
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                Text(
                  myName,
                  style: TextStyle(fontSize: 25),
                ),
                userActions(isMyProfile, isFollowing, userName),
                recommendations,
                (userName == null || thisUser == null || thisUser.posts == null)
                    ? Text('Please wait while we retrieve the posts.')
                    : viewPosts(userName),
                /*new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  switchView(),
                  switchViewToAdmin(),
                ],
              )*/
              ],
            ),
          ],
        ),
      ),
    );
  }

  void followRequest(String userName) {
    Requests().followUser(userName).then((value) {
      if (value)
        isFollowing = true;
      else {
        Flushbar(
          title: "Something went wrong.",
          message: "User could not be followed, please try again later.",
          duration: Duration(seconds: 3),
        )..show(context);
      }
      setState(() {});
    });
  }

  void unfollowRequest(String userName) {
    Requests().unfollowUser(userName).then((value) {
      if (value)
        isFollowing = false;
      else {
        Flushbar(
          title: "Something went wrong.",
          message: "User could not be unfollowed, please try again later.",
          duration: Duration(seconds: 3),
        )..show(context);
      }
      setState(() {});
    });
  }

  Widget userActions(bool isMyProfile, bool isFollowing, String userName) {
    if (isMyProfile)
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Requests().getFollowersOf(userName).then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DynamicWidgetList(value)),
                  );
                });
              },
              child: Container(
                child: Text(
                  "Followers:" + followerCt.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                width: 90,
                alignment: Alignment.center,
              ),
              color: Colors.blue,
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            RaisedButton(
              onPressed: () {
                Requests().getFollowedOf(userName).then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DynamicWidgetList(value)),
                  );
                });
              },
              child: Container(
                child: Text(
                  "Following:" + followingCt.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                width: 90,
                alignment: Alignment.center,
              ),
              color: Colors.blue,
            ),
          ]); //instead it returns the delete account stuff
    if (Requests.isAdmin) {
      return Column(children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                //TODO x is selected with a dropdown, x days of suspension
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
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Requests().getFollowersOf(userName).then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DynamicWidgetList(value)),
                  );
                });
              },
              child: Text("Followers:" + followerCt.toString()),
            ),
            RaisedButton(
              onPressed: () {
                Requests().getFollowedOf(userName).then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DynamicWidgetList(value)),
                  );
                });
              },
              child: Text("Following:" + followingCt.toString()),
            ),
          ],
        ),
      ]);
    } else {
      if (isFollowing != null && isFollowing)
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(23.5)),
            RaisedButton(
              onPressed: () {
                unfollowRequest(userName);
                setState(() {});
              },
              child: Text(
                "UNFOLLOW",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
            ),
            IconButton(
                icon: Icon(Icons.report),
                onPressed: () {
                  Requests().reportUser(userName).then((value) {
                    if (value) {
                      Flushbar(
                        title: "Success!.",
                        message:
                            "You've reported this user, their account will be reviewed.",
                        duration: Duration(seconds: 3),
                      )..show(context);
                      setState(() {}); //so that the post disappears
                    } else {
                      Flushbar(
                        title: "Something went wrong.",
                        message:
                            "User could not be reported, please try again later.",
                        duration: Duration(seconds: 3),
                      )..show(context);
                      print("PROFILE.DART: Couldn't report user:" + userName);
                    }
                  });
                }),
          ],
        );
      else
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(23.5)),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    followRequest(userName);
                  });
                },
                child: Text(
                  "FOLLOW",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
              ),
              IconButton(
                  icon: Icon(Icons.report),
                  onPressed: () {
                    Requests().reportUser(userName).then((value) {
                      if (value) {
                        Flushbar(
                          title: "Success!.",
                          message:
                              "You've reported this user, their account will be reviewed.",
                          duration: Duration(seconds: 3),
                        )..show(context);
                        setState(() {}); //so that the post disappears
                      } else {
                        Flushbar(
                          title: "Something went wrong.",
                          message:
                              "User could not be reported, please try again later.",
                          duration: Duration(seconds: 3),
                        )..show(context);
                        print("PROFILE.DART: Couldn't report user:" + userName);
                      }
                    });
                  }),
            ]);
    }
  }

  Widget viewPosts(String userName) {
    //THE POSTS UNDER PROFILE DO THE SAME DUMB SHIT FEED DOES, IF YOU ATTEMPT TO LIKE AFTER IT RELOADS, IT WILL THROW AN ERROR AS IF THAT SPECIFICPOST WIDGET DOES NOT EXIST (WHICH IS CORRECT, IT SHOULD'VE BEEN DELETED AND RECREATED)
    //COPY OF FEED's one, todo move it to a helper AND FIX IT
    if (thisUser != null) {
      if (postWidgets != null)
        postWidgets.forEach((element) {
          element = SizedBox();
        });
      //this should be getting rid of the specificpost instances. somehow it doesn't. FUCK flutter.
      postWidgets = [];
      var posts = thisUser.getPosts();
      print('PROFILE.DART: RECEIVED THE POSTS OF THE USER: ' + userName);
      posts.forEach((value) {
        var postWidget =
            new SpecificPost(currentUserName: currUser, currPost: value);
        postWidgets.add(postWidget);
        postWidgets.add(Padding(
          padding: const EdgeInsets.all(0),
        ));
      });
      if (postWidgets != null) {
        setState(() {});
        print('PROFILE.DART: received ' +
            (postWidgets.length / 2).toString() +
            ' specific_post widgets.');
        return SingleChildScrollView(
          child: Column(
            children: postWidgets,
          ),
        );
      } else
        return Text("WTF");
    } else {
      print('PROFILE.DART: could not find a user to print the posts.');
      return SizedBox();
    }
  }

  void updateFields(User value) {
    profilePicture = Image.memory(base64Decode(value.myProfilePicture));
    myName = value.myName;
    isFollowing = value.isFollowing;
    followerCt = value.followerCt;
    followingCt = value.followingCt;
    setState(() {});
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

  void getRecommended() {
    Requests().getRecommended().then((value) {
      List<String> userNames = value[0];
      List<String> commonConnectionCounts = value[1];
      recommendations = Card(
        child: Column(children: <Widget>[
          Container(
            child: Text(
              'Who to follow?',
              style: TextStyle(
                  fontSize: 20,
                  backgroundColor: Colors.blue,
                  color: Colors.white),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
              height: 55,
              width: 450,
              child: Card(
                  child: Recommendations(
                      userNames: userNames,
                      commonConnectionCounts: commonConnectionCounts)))
        ]),
        color: Colors.blue,
      );
      setState(() {});
      print('PROFILE.DART: listed ' +
          userNames.length.toString() +
          ' user recommendations');
    });
  }
}
