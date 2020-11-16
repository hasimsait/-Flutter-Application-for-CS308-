import 'package:http/http.dart' as http;
import 'helper/constants.dart';
import 'package:flutter_session/flutter_session.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'helper/session.dart';

class ProfilePicture{
  //PickedFile image;
  String userID;
  String picture; //db stores them as strings, I will too.

  ProfilePicture(this.userID);

  Future<Image> get()async {
    dynamic profilePicture=await FlutterSession().get('pp'+userID);
    //we could define a profile class in session manager but I'm not sure what we would cache, therefore I wil not.
    if(profilePicture==null || profilePicture['data']==null){
      print("requesting the image from the server");
      //request the picture of the user.
      //TODO learn how they serve profile pictures, request the picture, convert to base 64, use it instead of the constant.
      Session profilePicture = Session( data: Constants.sampleProfilePictureBASE64);
      await FlutterSession().set('pp'+userID, profilePicture);
      return Image.memory(base64Decode(Constants.sampleProfilePictureBASE64));
    }
    else{
      print("loading from session");
      return Image.memory(base64Decode(profilePicture['data']));
    }
  }
}