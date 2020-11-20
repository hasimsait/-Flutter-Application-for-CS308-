import 'package:http/http.dart' as http;
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
   this.myProfilePicture= await ProfilePicture(this.userName).get();
   //TODO this.myName etc. are all strings, send a simple request, save them to session(or not)
    this.myName=Constants.placeHolderName;
    this.isFollowing=true;//true if currentUser is following this.
    this.followerCt=100;
    this.followingCt=99;
    return this;
  }

  Future<Map<String,Post>>getPosts() async{
    //send request for this.username's posts, return it.
    return null;
  }

}