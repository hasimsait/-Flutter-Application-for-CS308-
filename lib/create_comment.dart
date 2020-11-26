import 'package:flutter/material.dart';
import 'package:teamone_social_media/helper/constants.dart';

class CreateComment extends StatefulWidget {
  final int postID;
  CreateComment(this.postID);
  @override
  State<StatefulWidget> createState() => _CreateCommentState(postID);
}

class _CreateCommentState extends State<CreateComment> {
  int postID;
  final _postFieldController = TextEditingController();
  _CreateCommentState(this.postID);

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
    // TODO: implement build
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
                  onPressed: _postCommment,
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

  void _postCommment() {
    if (Constants.DEPLOYED) {
      //TODO send the request to comment to postID
      //if 404 display error message, if 200 pop and return true
    } else {
      Navigator.pop(context, true);
    }
  }
}
