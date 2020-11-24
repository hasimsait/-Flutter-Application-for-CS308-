//TODO basically search but you send request for feed,
//TODO also add messages anchor
import 'package:flutter/material.dart';
import 'createpost.dart';
import 'helper/constants.dart';
import 'package:flutter_session/flutter_session.dart';
import 'user.dart';
import 'post.dart';

class Feed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  User currUser;
  ListView feedView;

  Future<Widget> displayFeed(Map<int, Post> posts) async {
    List<Widget> postWidgets=[];
    await posts.forEach((key, value) async {
      print(key);
      print(value.text);
      Widget a = await value.displayPost(currUser.userName,context);
      if(a!=null)
        postWidgets.add(a);
    });
    if(postWidgets!=null)
    return ListView(
      children: postWidgets,
    );
    else return Text("WTF");
  }

  @override
  void initState() {
    super.initState();
    feedView = ListView(
      children: <Widget>[
        Text(
          'Please wait while we retrieve your feed.',
        ),
      ],
    );
    FlutterSession().get('userName').then((value) {
      currUser = User(value['data']);
      currUser.getFeedItems().then((value) {
        displayFeed(value).then((value) {
          feedView = value;
          setState(() {});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Constants.appName),
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
              //TODO request feed of the user.
            } else {
              return null;
            }
          });
        },
        tooltip: 'Create a new post',
        child: new Icon(Icons.create),
      ),
    );
  }
}
