//TODO add feed route
//TODO basically search but you send request for feed,
//TODO has post widget/anchor. is the default route of the bottom navigation bar
//TODO also add messages anchor
import 'package:flutter/material.dart';
import 'createpost.dart';
import 'helper/constants.dart';

class Feed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  //pickFile,attach to tweet
  //selectLocation
  //
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Constants.appName),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'This route will contain posts',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePost()),
          );
        },
        tooltip: 'Create a new post',
        child: new Icon(Icons.create),
      ),
    );
  }
}
