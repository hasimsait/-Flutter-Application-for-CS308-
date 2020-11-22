import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'helper/constants.dart';
import 'dart:io';
import 'package:flutter_session/flutter_session.dart';

class Post {
  String text;
  PickedFile image;
  double latitude;
  double longitude;
  String topic;
  String videoURL;
  Post(
      {this.text,
      this.image,
      this.latitude,
      this.longitude,
      this.topic,
      this.videoURL});
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
        'postText': text,
        'postImage':
            (image == null) ? null : File(image.path).readAsStringSync(),
        'postTopic': topic,
        'postVideoURL': (videoURL == null) ? null : videoURL,
        'postLocationLatitude': latitude == null ? null : latitude.toString(),
        'postLocationLongitude':
            longitude == null ? null : longitude.toString(),
      }),
    );
  }
}
