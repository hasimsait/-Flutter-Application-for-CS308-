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
  String myName = ""; //Haşim Sait Göktan//null protection
  String userName; //hasimsait
  bool isFollowing;
  int followerCt;
  int followingCt;
  //TODO check what they did in backend, (which fields user has)
  User(this.userName);

  Future<User> getInfo() async {
    if (Constants.DEPLOYED) {
      User info = await Requests().getUserInfo(userName);
      this.myProfilePicture = info.myProfilePicture;
      this.myName = info.myName;
      this.isFollowing = info.isFollowing; //true if currentUser is following this user.
      this.followerCt = info.followerCt;
      this.followingCt = info.followingCt;
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

  Future<User> setName(String newName) async {
    if (Constants.DEPLOYED) {
      await Requests().updateUserInfo(newName,null);
      this.getInfo();//TODO this may not work properly
    } else {
      this.myName = newName;
      return this;
    }
  }

  Future<User> setPicture(File newPicture) async {
    if (Constants.DEPLOYED) {
      await Requests().updateUserInfo(null,newPicture);
      this.getInfo();//TODO this may not work properly
    } else {
      this.myProfilePicture = Image.file(newPicture);
      return this;
    }
  }

  Future<User> setNameAndPicture(String newName, File newPicture) async {
    if (Constants.DEPLOYED) {
      await Requests().updateUserInfo(newName,newPicture);
      this.getInfo();//TODO this may not work properly
    } else {
      this.myProfilePicture = Image.file(newPicture);
      this.myName = newName;
      return this;
    }
  }

  Future<Map<int, Post>> getPosts() async {
    return await Requests().getPosts(userName,"posts");
  }

  Future<Map<int, Post>> getFeedItems() async {
    return await Requests().getPosts(userName,"feed");
  }
}
