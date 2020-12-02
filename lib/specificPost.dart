import 'package:flutter/material.dart';
import 'post.dart';
import 'user.dart';
import 'profile.dart';
import 'dart:convert';
import 'create_comment.dart';
import 'helper/constants.dart';

class SpecificPost extends StatefulWidget {
  final String currentUserName;
  final Post currPost;
  SpecificPost({this.currentUserName, this.currPost});
  @override
  State<StatefulWidget> createState() =>
      _SpecificPostState(this.currentUserName, this.currPost);
}

class _SpecificPostState extends State<SpecificPost> {
  String currentUserName;
  Post currPost;
  User owner;
  var postOwnerName = "";
  var topic;
  var placeName;
  var text = "";
  var postDate = DateTime.now();
  var image;
  var videoURL;
  var postLikes = 0;
  var postDislikes = 0;
  var postID = 0;
  var postComments;
  bool liked =
      false; //TODO get this by requesting the likes and dislikes and checking if the user is in that list.
  bool disliked = false;
  _SpecificPostState(this.currentUserName, this.currPost);

  void initState() {
    //this must stay here
    super.initState();
    owner = User(currPost.postOwnerName);

    owner.getInfo(currentUserName).then((value) {
      owner = value;
      setState(() {});
    });
    postOwnerName = currPost.postOwnerName;
    topic = currPost.topic;
    placeName = currPost.placeName;
    text = currPost.text;
    postDate = currPost.postDate;
    image = currPost.image;
    videoURL = currPost.videoURL;
    postLikes = currPost.postLikes;
    postDislikes = currPost.postDislikes;
    postID = currPost.postID;
    postComments = currPost.postComments;
    liked =
        false; //TODO get this by requesting the likes and dislikes and checking if the user is in that list.
    disliked = false;
  }

  @override
  Widget build(BuildContext context) {
    //TODO turn topic/location/comment button into anchors.
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  icon: CircleAvatar(
                      radius: 25,
                      backgroundImage: owner.myProfilePicture.image),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Profile(postOwnerName)),
                    );
                  },
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      owner.myName,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 15),
                    ),
                    topic != null && topic != ""
                        ? Text(
                            topic,
                            textAlign: TextAlign.left,
                          )
                        : SizedBox(),
                    placeName != null && placeName != ""
                        ? Text(
                            placeName,
                          )
                        : SizedBox(), //TODO topic and location are anchors which push a new route
                    Container(
                      child: Text(
                        postDate.toString().substring(0, 16),
                        textAlign: TextAlign.left,
                      ),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    ),
                  ],
                ),
              ],
            ),
            postOwnerName == currentUserName
                ? Row(children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          currPost.editPost(context);
                        }),
                    IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: currPost.deletePost)
                  ])
                : SizedBox(),
          ],
        ),

        Text(text, style: TextStyle(fontSize: 20)),
        image != null && image != ""
            ? Image.memory(base64Decode(image))
            : _displayVideo(videoURL),
        //A post can't have both video and image and displaying video is messy.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.thumb_up,
                color: liked ? Colors.blue : Colors.black38,
              ),
              iconSize: 30,
              onPressed: () {
                liked = currPost.like(currentUserName);
                setState(() {});
              },
            ),
            Text(postLikes.toString()),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            ),
            IconButton(
              icon: Icon(
                Icons.thumb_down,
                color: disliked ? Colors.blue : Colors.black38,
              ),
              iconSize: 30,
              onPressed: () {
                disliked = currPost.dislike(currentUserName);
                setState(() {});
              },
            ),
            Text(postDislikes.toString()),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            ),
            IconButton(
              icon: Icon(
                Icons.add_comment,
                color: Colors.black38,
              ),
              iconSize: 30,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateComment(postID)),
                  //TODO get the post data again, setState
                  //for now I'll rely on user being smart enough to reload the feed.
                );
              },
            ),
          ],
        ),
        _displayComments(postComments),
      ],
    );
  }

  Widget _displayVideo(String videoURL) {
    if (videoURL != null && videoURL != "")
      return SizedBox();
    //TODO display video
    else {
      return SizedBox();
    }
  }

  Widget _displayComments(Map<String, String> postComments) {
    if (postComments == null || postComments.length == 0) {
      return Text(
          "Currently there are no comments on this post. Be the first!");
    } else {
      List<Widget> comments = [];
      postComments.forEach((key, value) {
        comments.add(Text(
          key + ":" + value,
          textAlign: TextAlign.left,
        ));
      });
      return Column(
        children: comments,
      );
    }
  }
}
