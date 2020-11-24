import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'helper/constants.dart';
import 'dart:io';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
import 'user.dart';

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

  Future<Widget> displayPost(String currentUserName) async {
    User owner = User(postOwnerName);
    owner.getInfo(currentUserName).then((value) {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              owner.myProfilePicture,
              Text(postOwnerName), //Text(owner.myName),
            ],
          ),
          Text(postDate.toString()),
          topic != null && topic != ""
              ? Text(topic)
              : SizedBox(), //TODO check if this worked
          placeName != null && placeName != ""
              ? Text(placeName)
              : SizedBox(), //TODO topic and location are anchors which push a new route
          Text(text),
          image != null && image != ""
              ? Image.memory(base64Decode(image))
              : _displayVideo(
                  videoURL), //A post can't have both video and image
          Row(
            children: <Widget>[
              Icon(Icons.thumb_up),
              Text(postLikes.toString()),
              Icon(Icons.thumb_down),
              Text(postDislikes.toString()),
            ],
          ),
          _displayComments(postComments),
        ],
      );
    });
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
      List<Widget> comms;
      postComments.forEach((key, value) {
        comms.add(Text(key + ":" + value));
      });
      return Column(
        children: comms,
      );
    }
  }
}
