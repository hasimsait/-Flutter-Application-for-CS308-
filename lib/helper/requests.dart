import 'dart:convert';
import 'dart:io';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'package:teamone_social_media/helper/session.dart';
import 'constants.dart';

class Requests {
  static String token;

  Future<String> auth(LoginData data) async {
    if (Constants.DEPLOYED) {
      var response = await http.post(
        Constants.backendURL + Constants.signInEndpoint,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': data.name,
          'password': data.password,
        }),
      );
      if (response.statusCode >= 400 || response.statusCode < 100)
        return 'Email address or password wrong, try again';
      Session sessionToken = Session(
          id: 0,
          data: json.decode(response.body)[
              "token"]); //TODO check the response of an auth by the server
      await FlutterSession().set('sessionToken', sessionToken);
      token = json.decode(response.body)["token"];
      Session userName = Session(
          id: 1,
          data: json.decode(response.body)[
              "userName"]); //TODO check the response of an auth by the server
      await FlutterSession().set('userName', userName);
      return null;
    } else {
      Session sessionToken =
          Session(id: 0, data: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
      await FlutterSession().set('sessionToken', sessionToken);
      token = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
      Session userName = Session(id: 1, data: 'hasimsait');
      await FlutterSession().set('userName', userName);
      return null;
    }
  }

  Future<String> signupUser(LoginData data) {
    //TODO modify this function for whatever they did in the backend, not in acceptance criteria
    return null; //
  }

  Future<String> recoverPassword(String name) {
    //TODO modify this function for whatever they did in the backend, this feature hasn't been implemented yet, also not in acceptance criteria
    return null;
  }

  bool editPost() {
    //TODO send the request to edit post endpoint with this.postID
    //throw UnimplementedError();
    if (Constants.DEPLOYED) {
    } else
      return true;
  }

  Future<bool> updateUserInfo(
      String newName, File newPP, String userName) async {
    //TODO get selected Image, turn it into string and post the request to change user info, if response is succes, setstate and pop.
    if (!Constants.DEPLOYED)
      return true;
    //the part below depends on how the edit works in the backend. worst case we create an user instance getInfo then set the fields to those and send that.
    else if (newName != null && newPP == null) {
      //set myName = newName;
    } else if (newName == "" && newPP != null) {
      //set pp to newPP;
    } else if (newName != null && newPP != null) {
      //set myName = newName;
      //set pp to newPP;
    }
  }
}
