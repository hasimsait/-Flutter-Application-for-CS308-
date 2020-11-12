import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'helper/constants.dart';
import 'dart:io';
class Post
{
  String text;
  PickedFile image;
  String locationTag;
  String topic;
  String videoURL;
  Post( {this.text,this.image,this.locationTag,this.topic,this.videoURL});
  //dart does not allow you to overload constructors so I made them optional
  //var post = MyPost(text:"bezkoder", location: "US");

  Future<http.Response> sendPost(String token) {
    return http.post(
      Constants.backendURL+Constants.createPostAPI,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'token':token
      },
      body: jsonEncode(<String, String>{
        'postOwnerName':'deneme',//TODO get it from session
        'postText': text,
        'postImage':File(image.path).readAsStringSync(),
        'postTopic':topic,
        'postVideoURL':videoURL,
        'postLocationLatitude':locationTag.split(",")[0],
        'postLocationLongitude':locationTag.split(",")[1],
      }),
    );
  }


}