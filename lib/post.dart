import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:teamone_social_media/profile.dart';
import 'create_post.dart';
import 'helper/constants.dart';
import 'dart:io';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'create_comment.dart';
import 'package:path_provider/path_provider.dart';

class Post {
  String text;
  String image;
  String topic;
  String videoURL;
  String placeName;
  String placeGeoID;
  //ABOVE ARE WHAT YOU SEND TO CREATE A POST

  //Below apply to posts received from feed etc.
  int postID; //dart integers == java longs
  String postOwnerName;
  DateTime postDate;
  int postLikes;
  int postDislikes;
  Map<String, String> postComments; //yorum ve yorum yapanin usernamei

  Post(
      {this.text,
      this.image,
      this.topic,
      this.videoURL,
      this.placeName,
      this.placeGeoID,
      this.postID,
      this.postOwnerName,
      this.postDate,
      this.postLikes,
      this.postDislikes,
      this.postComments});

  Future<http.Response> sendPost() async {
    dynamic sessionToken = await FlutterSession().get('sessionToken');
    dynamic userName = await FlutterSession().get('userName');
    //Map<String,String> usToken={'token':sessionToken};
    //String dumbTrickThatWontWorkButImTooLazyToEncodeJSON=usToken.toString();
    return http.post(
      Constants.backendURL + Constants.createPostAPI,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'currentUser': {'token': sessionToken}
            .toString() //TODO check the name of the token's field in API
        // TODO fix it ASAP, you do not create 2D json arrays this way in dart.
      },
      body: jsonEncode(<String, String>{
        'postOwnerName': userName,
        'postText': text == null ? "" : text,
        'postImage': (image == null) ? null : image,
        'postTopic': topic,
        'postVideoURL': (videoURL == null) ? null : videoURL,
        'postGeoName': placeName == null ? null : placeName.toString(),
        'postGeoID': placeGeoID == null ? null : placeGeoID.toString(),
      }),
    );
  }

  Future<Widget> displayPost(
      //TODO turn this into postwidget stateful class so that we can setState
      String currentUserName,
      BuildContext context) async {
    //TODO turn topic/location/comment button into anchors.
    User owner = User(postOwnerName);
    owner = await owner.getInfo(currentUserName);
    bool liked = false; //TODO get this by requesting the likes and dislikes
    bool disliked = false;
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
                          editPost(context);
                        }),
                    IconButton(icon: Icon(Icons.cancel), onPressed: _deletePost)
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
                liked = this.like(currentUserName);
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
                disliked = this.dislike(currentUserName);
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

  like(String currentUserName) {
    //currentUserName likes the post this.postID
    if (!Constants.DEPLOYED) {
      print(currentUserName +
          " likes the post " +
          this.postID.toString() +
          " by " +
          this.postOwnerName);
      return true;
    } else {
      //TODO
      // this may require some trickery since we need setState to update the image
      //currently does not update the icon
    }
  }

  dislike(String currentUserName) {
    if (!Constants.DEPLOYED) {
      print(currentUserName +
          " dislikes the post " +
          this.postID.toString() +
          " by " +
          this.postOwnerName +
          "but we can't update the icon since setState...");
      return true;
    } else {
      //TODO
    }
  }

  void _deletePost() {
    throw UnimplementedError();
    //TODO send request to delete this.postID, if 404 create snackbar, if 200 display "post is deleted"
  }

  void editPost(context) {
    //TODO turn image or videoURL strings into File and pass it as either imageFile or videoFile
    //reverse base64Encode(file.readAsBytesSync());
    var file;
    if (this.image != null) {
      //if the post has an image file attached to it
      _localFile().then((value) {
        File(value.path).writeAsBytesSync(base64Decode(this.image));
        return value;
      }).then((value) {
        print("We got the picture");
        navigateToEditPostRoute(context, value);
      });
      //file =  File(tempFile)(base64Decode(this.image));
    } else if (this.videoURL != null) {
      _localFile().then((value) {
        File(value.path).writeAsBytesSync(base64Decode(this.videoURL));
        return value;
      }).then((value) {
        print("We got the video");
        navigateToEditPostRoute(context, value);
      });
    } else {
      navigateToEditPostRoute(context, null);
    }
  }

  void navigateToEditPostRoute(context, file) {
    print(this.text);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreatePost(
                postID: this.postID,
                text: this.text,
                placeName: this.placeName,
                placeGeoID: this.placeGeoID,
                topic: this.topic,
                videoFile: this.videoURL == null ? null : file,
                imageFile: this.image == null ? null : file,
              )),
    );
  }

  Future<File> _localFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/tempFile');
  }
}
