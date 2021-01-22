import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:teamone_social_media/dynamic_widget_list.dart';
import 'package:teamone_social_media/helper/requests.dart';
import 'create_post.dart';
import 'helper/constants.dart';
import 'package:flutter_session/flutter_session.dart';
import 'user.dart';
import 'post.dart';
import 'specificPost.dart';

class Feed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  User currUser;
  List<Widget> postWidgets = [];
  Widget fml =Text("Please wait while we retrieve your feed");

  Future<Widget> displayFeed(Map<int, Post> posts) async {
    if (postWidgets != null && postWidgets != []) {
      postWidgets.forEach((element) {
        setState(() {
          element = SizedBox();
        });
      });
      postWidgets.clear();
      setState(() {});
    }

    List<Widget> temp = [];
    temp.add(Padding(
      padding: const EdgeInsets.all(2),
    ));
    setState(() {
      fml=Text("Please wait while we retrieve your feed");
    });

    posts.forEach((key, value) {
      print('FEED.DART: ' + value.postID.toString() + 'will be rendered now');
      temp.add(
          SpecificPost(currentUserName: currUser.userName, currPost: value));
      temp.add(Padding(
        padding: const EdgeInsets.all(0),
      ));
    });
    postWidgets = temp;
    fml=ListView(
      children: postWidgets,
    );
    setState(() {

    });
  }

  @override
  void initState() {
    currUser = User(Requests.currUserName);
    _loadFeed();
    print('FEED.DART: initialized feed widget');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Constants.appName),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadFeed),
          !Requests.isAdmin
              ? SizedBox()
              : IconButton(
                  icon: Icon(Icons.people_rounded),
                  onPressed: () {
                    Requests().getWaitingReportedUsers().then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DynamicWidgetList(value)),
                      );
                    });
                  },
                ),
        ],
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          child: fml,
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePost()),
          ).then((value) {
            if (Constants.DEPLOYED) {
              _loadFeed();
              setState(() {

              });
            } else {}
            if(value!=null && value){
              print('_______________'+value.toString()+'_______________________');
              if (value) {
                Flushbar(
                  title: "Success!",
                  message: "Post created successfully",
                  duration: Duration(seconds: 1),
                )..show(context);
              } else if(value!=null){
                Flushbar(
                  title: "Something went wrong.",
                  message:
                  "Failed to create the post, please try again later.",
                  duration: Duration(seconds: 3),
                )..show(context);
              }
              setState(() {});
            }
          });
        },
        tooltip: 'Create a new post',
        child: new Icon(Icons.create),
      ),
    );
  }

  void _loadFeed() {
    fml=Text("Please wait while we retrieve your feed");
    setState(() {

    });
    //if currUser admin make it retrieve the reports (in the backend) its that simple. done.
    currUser.getFeedItems().then((feedItems) {
      if (feedItems != null) {
        if (feedItems.length != 0) {
          displayFeed(feedItems).then((value) {
            print("FEED.DART: We got the listview feed.");
            setState(() {});
          });
        } else {
          fml=Text(
            'Looks like there are no posts here, come back later!',
          );
          print('FEED.DART: no feed items. but not null');
          setState(() {});
        }
      } else {
        postWidgets.clear();
        fml=Text(
          'Looks like there are no posts here, come back later!',
        );
        print('FEED.DART: no feed items. and null');
        setState(() {});
      }
    });
  }
}
