import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:teamone_social_media/profile.dart';
import 'helper/constants.dart';
import 'dart:io';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'create_comment.dart';

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
  //dart does not allow you to overload constructors so I made them optional
  //var post = MyPost(text:"bezkoder", location: "US");

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
      String currentUserName, BuildContext context) async {
    //TODO turn topic/location/comment button into anchors.
    User owner = User(postOwnerName);
    owner = await owner.getInfo(currentUserName);
    bool liked = false; //TODO get this by requesting the likes and dislikes
    bool disliked = false;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: CircleAvatar(
                  radius: 25, backgroundImage: owner.myProfilePicture.image),
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
      List<Widget> comms = [];
      postComments.forEach((key, value) {
        comms.add(Text(
          key + ":" + value,
          textAlign: TextAlign.left,
        ));
      });
      return Column(
        children: comms,
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
}
