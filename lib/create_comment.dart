import 'package:flutter/material.dart';
import 'helper/requests.dart';

class CreateComment extends StatefulWidget {
  final int postID;
  final String currUserName;
  CreateComment(this.postID, this.currUserName);
  @override
  State<StatefulWidget> createState() =>
      _CreateCommentState(postID, currUserName);
}

class _CreateCommentState extends State<CreateComment> {
  int postID;
  String currUserName;
  final _postFieldController = TextEditingController();
  _CreateCommentState(this.postID, this.currUserName);

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
        title: new Text("Create Comment"),
      ),
      body: new Center(
        child: Column(
          children: <Widget>[
            new TextFormField(
              controller: _postFieldController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'What\'s on your mind?'),
              autofocus: true,
            ),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.check_circle_outline_rounded),
                  onPressed: _postComment,
                ),
                IconButton(
                    icon: Icon(Icons.cancel_outlined),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _postComment() {
    Requests()
        .postComment(_postFieldController.text, postID, currUserName)
        .then((value) {
      if (value) {
        Navigator.pop(context, true);
      } else {
        //TODO display error message;
      }
    });
  }
}
