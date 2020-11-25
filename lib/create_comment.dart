import 'package:flutter/material.dart';

class CreateComment extends StatefulWidget {
  final int postID;
  CreateComment(this.postID);
  @override
  State<StatefulWidget> createState() => _CreateCommentState(postID);
}

class _CreateCommentState extends State<CreateComment> {
  int postID;
  _CreateCommentState(this.postID);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
    //TODO check if comments have images etc. or just simple text,
    //you could also not display all comments under the post and go the instagram route.
  }
}
