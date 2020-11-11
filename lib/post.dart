//TODO add create new post widget that will be displayed on top of feed
//TODO add autocomplete to the create post
//TODO user can add images and or videos, pick locations and add hashtags
import 'package:flutter/material.dart';
import 'helper/constants.dart';
import 'mypost.dart';
class Post extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PostState();
}

class _PostState extends State<Post> {
  final _postFieldController= TextEditingController();
  Future<bool> _sendPost() {
    int status = 400;
    print("clicked POST button,send the request with ${_postFieldController.text} ");
    MyPost post= new MyPost(text:_postFieldController.text);
    //TODO send the post
    status=200;//or 302 whatever.
    if (status<400 && status>=200)
      {
        Navigator.pop(context,post);
      }
    //TODO create snackbar with "service is temporarily available."
    return null;
  }

  void initState() {
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
        title: new Text(Constants.postAppBarText),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.create),
            onPressed: () {
              _sendPost();
            },
          ),
        ],
      ),
      body: new Center(
        child: new Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new TextFormField (
              controller: _postFieldController,
              decoration: InputDecoration(border: OutlineInputBorder(),hintText:'What\'s on your mind?'),
              autofocus: true,
            ),
          ],
        ),
      ),
    );
  }
}

