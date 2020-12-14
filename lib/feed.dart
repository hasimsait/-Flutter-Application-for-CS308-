//TODO basically search but you send request for feed,
//TODO also add messages anchor
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
  ListView feedView;
  List<Widget> postWidgets;

  Future<Widget> displayFeed(Map<int, Post> posts) async {
    if (postWidgets != null)
      postWidgets.forEach((element) {
        element = null;
      });
    postWidgets = null;
    //this should be getting rid of the specificpost instances. somehow it doesn't. FUCK flutter.
    postWidgets = [];
    posts.forEach((key, value) {
      print('FEED.DART: ' + value.postID.toString() + 'will be rendered now');
      /*if (value.postComments != null) {
        print('FEED.DART: ' +
            value.postID.toString() +
            ' has ' +
            value.postComments.length.toString() +
            ' comments.');
        print('FEED.DART: ' +
            value.postID.toString() +
            ' last comment is: ' +
            value.postComments.entries.last.value);
      }*/
      var postWidget =
          new SpecificPost(currentUserName: currUser.userName, currPost: value);
      //this new doesn't do shit. That's an issue since I need to clean that up
      //in terms of deleting posts and displaying new ones it will be fine but it will not display comments in realtime unless if that new does what it's supposed to do.
      //TODO find a fix for that. setting it to null etc did not fix it. Garbage collector should've picked them up.
      //https://dart.dev/guides/language/effective-dart/usage#dont-use-new GREAT IDEA. CAN'T DELETE OBJECT, CAN'T CREATE NEW.
      //I'll deal with it later. I already spent 3+ hours bc of this dumb thing.
      postWidgets.add(postWidget);
      postWidgets.add(Padding(
        padding: const EdgeInsets.all(10),
      ));
    });
    if (postWidgets != null) {
      return ListView(
        children: postWidgets,
      );
    } else
      return Text("WTF");
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
      body: new Center(
        child: feedView,
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePost()),
          ).then((value) {
            if (Constants.DEPLOYED) {
              _loadFeed();
            } else {}
          });
        },
        tooltip: 'Create a new post',
        child: new Icon(Icons.create),
      ),
    );
  }

  void _loadFeed() {
    feedView = ListView(
      children: <Widget>[
        Text(
          'Please wait while we retrieve your feed.',
        ),
      ],
    );
    //if currUser admin make it retrieve the reports (in the backend) its that simple. done.
    currUser.getFeedItems().then((value) {
      feedView = null;
      if (value == null) {
        feedView = ListView(
          children: <Widget>[
            Text(
              'Looks like there are no posts here, come back later!',
            ),
          ],
        );
      } else {
        displayFeed(value).then((value) {
          print("FEED.DART: We got the listview feed.");
          feedView = value;
          setState(() {});
        });
      }
    });
  }
}
