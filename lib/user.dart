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

class User{
  Image myProfilePicture;
  String myName;//Haşim Sait Göktan
  String userName;//hasimsait
  bool isFollowing;
  int followerCt;
  int followingCt;
  //TODO check what they did in backend, (which fields user has)
  User(this.userName);

  Future<User> getInfo(String currentUser) async{
   //TODO request user info, set image: to the image string, set the rest to variables below
    this.myProfilePicture= await ProfilePicture(this.userName).get(image: Constants.sampleProfilePictureBASE64);
    this.myName=Constants.placeHolderName;
    this.isFollowing=true;//true if currentUser is following this user.
    this.followerCt=100;
    this.followingCt=99;
    return this;
  }
  Future<User> setName(String newName) async{
    //TODO delete the entire thing below send request to change these, if accepted request to get the info again and return it
    //send request to update
    //return getInfo(this.userName);
    this.myName=newName;
    return this;
  }
  Future<User> setPicture(File newPicture) async{
    //TODO delete the entire thing below send request to change these, if accepted request to get the info again and return it
    //send request to update
    //return getInfo(this.userName);//So that if any error/cropping happens, user gets to see it
    this.myProfilePicture= Image.file(newPicture);
    return this;
  }
  Future<User> setNameAndPicture(String newName,File newPicture) async{
    //TODO delete the entire thing below send request to change these, if accepted request to get the info again and return it
    //send request to update
    //return getInfo(this.userName);
    this.myProfilePicture= Image.file(newPicture);
    this.myName=newName;
    return this;
  }
  Future<Map<String,Post>>getPosts() async{
    //send request for this.username's posts, return it.
    return null;
  }

}