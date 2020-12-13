import 'dart:convert';
import 'dart:io';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'package:teamone_social_media/helper/session.dart';
import 'constants.dart';
import 'package:teamone_social_media/post.dart';
import 'package:teamone_social_media/user.dart';

class Requests {
  static String token;
  static Map<String, String> header;
  static String currUserName;
  static String password;
  //this is a horrible idea but appuserdto to edit info rather than token, dunno why, maybe it can be null, can't be bothered to learn.

  Future<String> auth(LoginData data) async {
    if (Constants.DEPLOYED) {
      //TODO admin (how does authorities look when admin?)
      var response = await http.post(
        Constants.backendURL + Constants.signInEndpoint,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + 'aaa',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'username': data.name,
          'password': data.password,
        }),
      );
      if (response.statusCode >= 400 || response.statusCode < 100)
        return json.decode(response.body)["message"];
      Session sessionToken =
          Session(id: 0, data: json.decode(response.body)["data"]["token"]);
      await FlutterSession().set('sessionToken', sessionToken);
      Session userName =
          Session(id: 1, data: json.decode(response.body)["data"]["userName"]);
      await FlutterSession().set('userName', userName);
      print('requests.dart received: ' +
          json.decode(response.body)["data"].toString() +
          ' after login.');
      token = json.decode(response.body)["data"]["token"];
      header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token,
        'Accept': 'application/json',
      };
      currUserName = data.name;
      return null;
    } else {
      Session sessionToken =
          Session(id: 0, data: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
      await FlutterSession().set('sessionToken', sessionToken);
      Session userName = Session(id: 1, data: data.name);
      await FlutterSession().set('userName', userName);
      token = "MYSTATICTOKEN";
      header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token,
        'Accept': 'application/json',
      };
      currUserName = data.name;
      return null;
    }
  }

  Future<String> signupUser(LoginData data) {
    //TODO send email username pwwd
    return null; //
  }

  Future<String> recoverPassword(String name) {
    //this feature hasn't been implemented yet, also not in acceptance criteria
    return null;
  }

  Future<bool> updateUserInfo(String newName, File newPP) async {
    //this part was a mess
    //TODO post the request to change user info, if response is succes, return true
    if (!Constants.DEPLOYED)
      return true;
    //the part below depends on how the edit works in the backend. worst case we create an user instance getInfo then set the fields to those and send that.
    else {
      String url = Constants.backendURL +
          Constants.profileEndpoint +
          currUserName +
          Constants.editInfoEndpoint;
      //url ="http://172.18.91.97:5000/"; ipconfig+flask to get poor man's postman
      User currUser = User(currUserName);
      String email = "";
      String existingPP = "";
      //todo add/remove whatever field is necessary
      currUser = await currUser.getInfo();
      email = currUser.email;
      existingPP = currUser.myProfilePicture;
      if (newPP != null) {
        String imageAsString = base64Encode(newPP.readAsBytesSync());
        existingPP = imageAsString;
      }
      if (newName != null && newName!="") {
        //I add the existing name as hint (looks better imo), not init text so if the user never edits it it will remain ''.
        //Name field does not exist, they will receive an error if I add it to request.
        print("REQUEST.DART: We currently do not support changing names.");
      }
      var response = await http.put(
        url,
        headers: header,
        /*username pwd email always included*/
        body: jsonEncode(<String, String>{
          'username': currUserName,
          'password': password,
          'email': email,
          'profilePicture': existingPP,
        }),
      );
      print('REQUESTS.DART: trying to updateUserInfo of: ' + currUserName);
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print('REQUESTS.DART: failed to updateUserInfo');
        return false;
      }
      return true;
    }
  }

  Future<bool> postComment(String text, int postID, currUserName) async {
    if (Constants.DEPLOYED) {
      var response = await http.post(
          Constants.backendURL + Constants.interactWithPostEndpoint,
          headers: header,
          body: jsonEncode(<String, String>{
            'postId': postID.toString(),
            'postComment': text,
            'commentatorName': currUserName,
          }));
      if (response.statusCode >= 400 || response.statusCode < 100) return false;
      return true;
    } else {
      return true;
    }
  }

  Future<Post> reloadPost(int postID, {Post oldPost}) async {
    if (Constants.DEPLOYED || oldPost == null) {
      //TODO request the post from the server (this method is called when user edits the post or a comment is posted under the post.)
      //var response=await http.post(Constants.backendURL+SOMETHINGENDPOINT+POSTID,headers:header)
      //if (response.statusCode >= 400 || response.statusCode < 100) return false;
      //       return true;
      print("REQUESTS.DART: " +
          "this feature has not been implemented yet, reloading the feed will not load your edit/comment too. restart the application to see your update to the post.");
    } else {
      var newComm;
      if (oldPost.postComments != null) {
        newComm = Map<String, String>.from(oldPost.postComments);
        newComm.addAll({"reload the feed": "to see your comment"});
      } else
        newComm = {
          "reloading posts are not implemented yet": "the post would reload"
        };
      var newPost = oldPost.from();
      newPost.postComments = newComm;
      return newPost;
    }
  }

  Future<bool> sendPost(Post myPost) async {
    if (Constants.DEPLOYED) {
      var response = await http.post(
        Constants.backendURL + Constants.createPostEndpoint,
        headers: header,
        body: jsonEncode(<String, String>{
          'postOwnerName': currUserName,
          'postText': myPost.text == null ? "" : myPost.text,
          'postImage': myPost.image,
          'postTopic': myPost.topic,
          'postVideoURL': myPost.videoURL,
          'postGeoName': myPost.placeName.toString(),
          'postGeoID': myPost.placeGeoID.toString(),
        }),
      );
      if (response.statusCode >= 400 || response.statusCode < 100) return false;
      return true;
    } else {
      print("REQUESTS.DART: " +
          Constants.backendURL +
          Constants.createPostEndpoint);
      return true;
    }
  }

  Future<bool> editPost(Post myPost) async {
    //TODO checkimage
    if (Constants.DEPLOYED) {
      var response = await http.post(
        Constants.backendURL +
            Constants.editPostEndpoint +
            myPost.postID.toString(), //api/v1/posts/edit/postID
        headers: header,
        body: jsonEncode(<String, String>{
          'postOwnerName': currUserName,
          'postText': myPost.text == null ? "" : myPost.text,
          'postImage': myPost.image,
          'postTopic': myPost.topic,
          'postVideoURL': myPost.videoURL,
          'postGeoName': myPost.placeName.toString(),
          'postGeoID': myPost.placeGeoID.toString(),
        }),
      );
      if (response.statusCode >= 400 || response.statusCode < 100) return false;
      return true;
    } else {
      print("REQUESTS.DART: " +
          Constants.backendURL +
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
      print("REQUESTS.DART: " +
          Constants.backendURL +
          Constants.deletePostEndpoint +
          postID.toString());
      return true;
    }
  }

  Future<Map<int, Post>> getPosts(String userName, String s) async {
    if (Constants.DEPLOYED) {
      if (s == 'feed') {
        //TODO request feed of userName
      } else if (s == 'posts') {
        //TODO retrieve posts by userName
      }
      //parse the response so it looks like the static map below.
    } else {
      if (s == 'feed') {
        return new Map<int, Post>.from({
          0: new Post(
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
            },
            userDislikedIt: true,
          ),
          1: new Post(
            text: "This is another sample post under a topic.",
            postDate: DateTime.now(),
            postID: 1,
            topic: "Sample Topic",
            postLikes: 10,
            postDislikes: 0,
            postOwnerName: "hasimsait",
          ),
          2: new Post(
            text:
                "This is a post from another user. Name and image are static, don't mind them.",
            postDate: DateTime.now(),
            postID: 2,
            postLikes: 100,
            postDislikes: 10,
            postOwnerName: "aaaaaa",
            postComments: {
              "ayşe": "sample comment",
              "ĞĞĞĞĞ": "lorem ipsum...",
              'aaaaaaaaaaaa': 'aaaaaaaaaaaaaaaaaaaaaa'
            },
            userLikedIt: true,
          ),
        });
      } else if (s == 'posts') {
        User profileOwner = User(userName);
        profileOwner.getInfo();
        return new Map<int, Post>.from({
          0: new Post(
              text: "This is a sample post with an image and a location.",
              placeName: "Sample Place Name",
              postDate: DateTime.now(),
              image: Constants.sampleProfilePictureBASE64,
              postID: 0,
              postLikes: 0,
              postDislikes: 10,
              postOwnerName: userName,
              postComments: {
                "ahmet": "sample comment",
                "mehmet": "lorem ipsum..."
              }),
          1: new Post(
              text: "This is another sample post under a topic.",
              postDate: DateTime.now(),
              postID: 1,
              topic: "Sample Topic",
              postLikes: 10,
              postDislikes: 0,
              postOwnerName: userName),
          2: new Post(
              text:
                  "This is a post from another user. Name and image are static, don't mind them.",
              postDate: DateTime.now(),
              postID: 2,
              postLikes: 100,
              postDislikes: 10,
              postOwnerName: userName,
              postComments: {
                "ayşe": "sample comment",
                "ĞĞĞĞĞ": "lorem ipsum...",
                'aaaaaaaaaaaa': 'aaaaaaaaaaaaaaaaaaaaaa'
              }),
        });
      }
    }
  }

  Future<User> getUserInfo(String userName) async {
    User thisUser = User(userName);
    var response = await http.get(
        Constants.backendURL + Constants.profileEndpoint + userName,
        headers: header);
    var data = json.decode(response.body)['data'];
    print('requests.dart: getUserInfo requested info of ' +
        userName +
        ' and received: ' +
        data.toString());
    thisUser.email = data['email'];
    if (data['profilePicture'] == null)
      thisUser.myProfilePicture = Constants.sampleProfilePictureBASE64;
    else
      thisUser.myProfilePicture = data['profilePicture'];
    thisUser.active = data['active'];
    thisUser.deleted = !thisUser.active;
    thisUser.myName = userName;
    var followingUserList = data['followingNamesList'];
    //print(followingUserList.length.toString());
    var followerUserList = data['followerNamesList'];
    //print(followerUserList.length.toString());
    var subscribedTopicNamesList = data['subscribedTopicNamesList'];
    //print(subscribedTopicNamesList.length.toString());
    var subscribedLocationIdsList = data['subscribedLocationIdsList'];
    //print(subscribedLocationIdsList.length.toString());
    thisUser.followingCt = subscribedLocationIdsList.length +
        subscribedTopicNamesList.length +
        followingUserList.length;
    thisUser.followerCt = followerUserList.length;
    if (followerUserList != null && followerUserList.length != 0) {
      if (followerUserList.contains(currUserName))
        thisUser.isFollowing = true;
      else
        thisUser.isFollowing = false;
    } else
      thisUser.isFollowing = false;
    return thisUser;
  }

  Future<bool> followTopic(String topic) async {
    if (Constants.DEPLOYED) {
      //displayed under a post which is posted under topic, todo pass the postid and send request
      //body:{'subscriberUsername':currUserName,'postId':postId, 'subscribedContentType':'geo' or 'topic'}
    } else {
      return true;
    }
  }

  Future<bool> unfollowTopic(String topic) async {
    if (Constants.DEPLOYED) {
      //took a screenshot
    } else {
      return true;
    }
  }

  Future<bool> followLocation(String locationID) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> unfollowLocation(String locationID) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> followUser(String locationID) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> unfollowUser(String locationID) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> isFollowingTopic(String topic) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> isFollowingLocation(String locationID) async {
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> deleteAccount({String userName}) async {
    return true;
  }

  Future<bool> like(int postID) async {
    //postinteraction controller
    //return true if successful
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }

  Future<bool> dislike(int postID) async {
    //postinteraction controller
    //return true if successfull
    if (Constants.DEPLOYED) {
    } else {
      return true;
    }
  }
}
