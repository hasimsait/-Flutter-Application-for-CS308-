import 'dart:convert';
import 'dart:io';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'package:teamone_social_media/helper/session.dart';
import 'constants.dart';
import 'package:teamone_social_media/post.dart';

class Requests {
  static String token;
  static Map<String, String> header;

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
      //TODO set header here
      /*
      {
          'Content-Type': 'application/json; charset=UTF-8',
          'currentUser': {'token': sessionToken}
              .toString() //TODO check the name of the token's field in API
          // TODO fix it ASAP, you do not create 2D json arrays this way in dart.
       }
      */
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

  Future<bool> updateUserInfo(
      String newName, File newPP, String userName) async {
    //TODO get selected Image, turn it into string and post the request to change user info, if response is succes, setstate and pop.
    if (!Constants.DEPLOYED)
      return true;
    //the part below depends on how the edit works in the backend. worst case we create an user instance getInfo then set the fields to those and send that.
    else {
      if (newPP != null) {
        String imageAsString = base64Encode(newPP.readAsBytesSync());
      }
      if (newName != null && newPP == null) {
        //set myName = newName;
      } else if (newName == "" && newPP != null) {
        //set pp to newPP;
      } else if (newName != null && newPP != null) {
        //set myName = newName;
        //set pp to newPP;
      }
    }
  }

  Future<bool> postComment(String text, int postID, currUserName) async {
    if (Constants.DEPLOYED) {
      //TODO send the request to comment to postID
      //if successful return true, else return false.
    } else {
      return true;
    }
  }

  Future<Post> reloadPost(int postID, {Post oldPost}) async {
    //TODO remove oldPost from parameters.
    if (Constants.DEPLOYED || oldPost == null) {
      //TODO request the post from the server (this method is called when user edits the post or a comment is posted under the post.)
    } else {
      var newComm;
      if (oldPost.postComments != null) {
        newComm = Map<String,String>.from(oldPost.postComments);
            newComm.addAll({"reload the feed": "to see your comment"});
      }else
        newComm = {"reload the feed": "to see your comment"};
      var newPost=oldPost.from();
      newPost.postComments=newComm;
      return newPost;
    }
  }

  Future<bool> sendPost(Post myPost) async {
    if (Constants.DEPLOYED) {
      dynamic userName = await FlutterSession().get('userName');
      var response = await http.post(
        Constants.backendURL + Constants.createPostEndpoint,
        headers: header,
        body: jsonEncode(<String, String>{
          'postOwnerName': userName,
          'postText': myPost.text == null ? "" : myPost.text,
          'postImage': (myPost.image == null) ? null : myPost.image,
          'postTopic': myPost.topic,
          'postVideoURL': (myPost.videoURL == null) ? null : myPost.videoURL,
          'postGeoName':
              myPost.placeName == null ? null : myPost.placeName.toString(),
          'postGeoID':
              myPost.placeGeoID == null ? null : myPost.placeGeoID.toString(),
        }),
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        return true;
      } else {
        return false;
      }
    } else {
      print(Constants.backendURL + Constants.createPostEndpoint);
      return true;
    }
  }

  Future<bool> editPost(Post myPost) async {
    if (Constants.DEPLOYED) {
      dynamic userName = await FlutterSession().get('userName');
      var response = await http.post(
        Constants.backendURL +
            Constants.editPostEndpoint +
            myPost.postID.toString(), //api/v1/posts/edit/postID
        headers: header,
        body: jsonEncode(<String, String>{
          'postOwnerName':
              userName, //I could do myPost.postOwnerName but this seems like a better idea
          'postText': myPost.text == null ? "" : myPost.text,
          'postImage': (myPost.image == null) ? null : myPost.image,
          'postTopic': myPost.topic,
          'postVideoURL': (myPost.videoURL == null) ? null : myPost.videoURL,
          'postGeoName':
              myPost.placeName == null ? null : myPost.placeName.toString(),
          'postGeoID':
              myPost.placeGeoID == null ? null : myPost.placeGeoID.toString(),
        }),
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        return true;
      } else {
        return false;
      }
    } else {
      print(Constants.backendURL +
          Constants.editPostEndpoint +
          myPost.postID.toString());
      return true;
    }
  }

  Future<bool> deletePost(int postID) async {
    if (Constants.DEPLOYED) {
      var response = await http.post(
        Constants.backendURL + Constants.deletePostEndpoint + postID.toString(),
        headers: header,
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        return true;
      } else {
        return false;
      }
    } else {
      print(Constants.backendURL +
          Constants.deletePostEndpoint +
          postID.toString());
      return true;
    }
  }
}
