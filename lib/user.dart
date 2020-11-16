import 'package:http/http.dart' as http;
import 'helper/constants.dart';
import 'package:flutter_session/flutter_session.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'helper/session.dart';
import 'profile_picture.dart';

class User{
  Image myProfilePicture;
  String myName;//Haşim Sait Göktan
  String userName;//hasimsait
  //TODO check what they did in backend, (which fields user has)
  User(this.userName);

  Future<User> getInfo() async{
   this.myProfilePicture= await ProfilePicture(this.userName).get();
   //TODO this.myName etc. are all strings, send a simple request, save them to session(or not)
    this.myName=Constants.placeHolderName;
    return this;
  }

}