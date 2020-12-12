import 'dart:io';
import 'package:teamone_social_media/helper/requests.dart';

import 'helper/constants.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'profile_picture.dart';
import 'post.dart';

class User {
  Image myProfilePicture = Image.memory(
      base64Decode(Constants.sampleProfilePictureBASE64)); //null protection
  String myName =
      ""; //Haşim Sait Göktan//null protection//TODO this field does not exist???
  String userName; //hasimsait
  bool isFollowing;
  int followerCt;
  int followingCt;

  String email;
  bool active = true;
  bool deleted = false;
  User(this.userName);

  Future<User> getInfo() async {
    if (!Constants.DEPLOYED) {
      User info = await Requests().getUserInfo(userName);
      this.myProfilePicture = info.myProfilePicture;
      this.myName = info.myName;
      this.isFollowing =
          info.isFollowing; //true if currentUser is following this user.
      this.followerCt = info.followerCt;
      this.followingCt = info.followingCt;
      this.email = info.email;
      this.active = info.active;
      this.deleted = info.deleted;
      return this;
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

  Future<Map<int, Post>> getPosts() async {
    return await Requests().getPosts(userName, "posts");
  }

  Future<Map<int, Post>> getFeedItems() async {
    return await Requests().getPosts(userName, "feed");
  }
}
