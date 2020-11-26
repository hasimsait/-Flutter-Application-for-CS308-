import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'helper/constants.dart';
import 'package:flutter_session/flutter_session.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'helper/session.dart';
import 'profile_picture.dart';
import 'post.dart';

class User {
  Image myProfilePicture;
  String myName; //Haşim Sait Göktan
  String userName; //hasimsait
  bool isFollowing;
  int followerCt;
  int followingCt;
  //TODO check what they did in backend, (which fields user has)
  User(this.userName);

  Future<User> getInfo(String currentUser) async {
    if (Constants.DEPLOYED) {
      //TODO request user info, set image: to the image string, set the rest to variables below

    } else {
      this.myProfilePicture = await ProfilePicture(this.userName)
          .get(image: Constants.sampleProfilePictureBASE64);
      this.myName = Constants.placeHolderName;
      this.isFollowing = true; //true if currentUser is following this user.
      this.followerCt = 100;
      this.followingCt = 99;
      return this;
    }
  }

  Future<User> setName(String newName) async {
    //TODO delete the entire thing below send request to change these, if accepted request to get the info again and return it
    //send request to update
    //return getInfo(this.userName);
    if (Constants.DEPLOYED) {
    } else {
      this.myName = newName;
      return this;
    }
  }

  Future<User> setPicture(File newPicture) async {
    //TODO delete the entire thing below send request to change these, if accepted request to get the info again and return it
    //send request to update
    //return getInfo(this.userName);//So that if any error/cropping happens, user gets to see it
    if (Constants.DEPLOYED) {
    } else {
      this.myProfilePicture = Image.file(newPicture);
      return this;
    }
  }

  Future<User> setNameAndPicture(String newName, File newPicture) async {
    //TODO delete the entire thing below send request to change these, if accepted request to get the info again and return it
    //send request to update
    //return getInfo(this.userName);
    if (Constants.DEPLOYED) {
    } else {
      this.myProfilePicture = Image.file(newPicture);
      this.myName = newName;
      return this;
    }
  }

  Future<Map<String, Post>> getPosts() async {
    //send request for this.username's posts, return it.
    if (Constants.DEPLOYED) {
    } else {
      return null;
    }
  }

  Future<Map<int, Post>> getFeedItems() async {
    if (Constants.DEPLOYED) {
      //TODO send request for the feed
      //TODO parse the feed
      //TODO for i in posts.length()
      //res.append(i,Post(posts[i]))
      //return res
      //use currUser.userName
    } else {
      return <int, Post>{
        0: Post(
            text: "This is a sample post with an image and a location.",
            placeName: "Sample Place Name",
            postDate: DateTime.now(),
            image: Constants.sampleProfilePictureBASE64,
            postID: 0,
            postLikes: 0,
            postDislikes: 10,
            postOwnerName: "hasimsait",
            postComments: {
              "ahmet": "sample comment",
              "mehmet": "lorem ipsum..."
            }),
        1: Post(
            text: "This is another sample post under a topic.",
            postDate: DateTime.now(),
            postID: 1,
            topic: "Sample Topic",
            postLikes: 10,
            postDislikes: 0,
            postOwnerName: "hasimsait"),
        2: Post(
            text:
                "This is a post from another user. Name and image are static, don't mind them.",
            postDate: DateTime.now(),
            postID: 2,
            postLikes: 100,
            postDislikes: 10,
            postOwnerName: "aaaaaa",
            postComments: {
              "ayşe": "sample comment",
              "ĞĞĞĞĞ": "lorem ipsum..."
            }),
      };
    }
  }
}
