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
  static bool isAdmin = false;
  static List<String> followedTopics;
  static List<String> followedLocations;
  static List<String> followerUsers;
  static List<String> followedUsers;
  //this may cause fuck-ups in certain edge cases but I do not want it to send another getInfo tbh.

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
          'username': data.username,
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
      currUserName = data.username;
      var authority = jsonDecode(response.body)['data']['authorities'];
      for (int i = 0; i < authority.length; i++) {
        if (authority[i]['authority'].toString() == 'ROLE_ADMIN')
          isAdmin = true;
        else
          isAdmin = false;
      }
      return null;
    } else {
      Session sessionToken =
          Session(id: 0, data: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
      await FlutterSession().set('sessionToken', sessionToken);
      Session userName = Session(id: 1, data: data.username);
      await FlutterSession().set('userName', userName);
      token = "MYSTATICTOKEN";
      header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token,
        'Accept': 'application/json',
      };
      currUserName = data.username;
      return null;
    }
  }

  Future<String> signupUser(LoginData data) {
    //TODO send email username pwwd
    /*honestly I want to launch a webview or create a new route here and be done with it but we will see what I end up doing, I mentioned it in retro too*/
    return null; //
  }

  Future<String> recoverPassword(String name) {
    //this feature hasn't been implemented yet, also not in acceptance criteria
    return null;
  }

  Future<bool> updateUserInfo(String newName, File newPP) async {
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
      currUser = await currUser.getInfo();
      email = currUser.email;
      existingPP = currUser.myProfilePicture;
      if (newPP != null) {
        String imageAsString = base64Encode(newPP.readAsBytesSync());
        existingPP = imageAsString;
      }
      if (newName != null && newName != "") {
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
      var response = await http.get(
          Constants.backendURL +
              Constants.feedEndpoint +
              currUserName +
              '/' +
              postID.toString(),
          headers: header);
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print(jsonDecode(response.body).toString());
      } else {
        //THIS RETURNS A FEED DTO RATHER THAN POST, DUNNO WHY
        var data = jsonDecode(response.body)['data'];
        var text = data['postText'];
        var image = data['postImage'];
        var topic = data['postTopic'];
        var videoURL = data['postVideoURL'];
        var placeName = data['postGeoName'];
        var postID = data['postId'];
        var postDate = data['postDate'];
        var postLikes = data['totalPostLike'];
        var postDislikes = data['totalPostDislike'];
        var postComments = data['postCommentDto']; //this may fuck up test it
        //this.image,    this.topic,    this.videoURL,    this.placeName,    this.placeGeoID,    this.postID,    this.postOwnerName,    this.postDate,    this.postLikes,    this.postDislikes,    this.postComments,    this.userLikedIt,    this.userDislikedIt
        Post thisPost = Post().from(
            text: text,
            image: image,
            topic: topic,
            videoURL: videoURL,
            placeName: placeName,
            postID: postID,
            postOwnerName: data['postOwnerName'],
            postDate: postDate,
            postLikes: postLikes,
            postDislikes: postDislikes);
        thisPost.userDislikedIt = data['userDislikedIt'] == 'true';
        thisPost.userLikedIt = data['userLikedIt'] == 'true';
        try {
          Map<String, String> comments = {};
          for (int i = 0; i < postComments.length; i++) {
            comments[i.toString() +
                postComments[i]['commentatorName'].toString()] = postComments[i]
                    ['postComment']
                .toString(); //otherwise a user could only comment once
          }
          thisPost.postComments = comments;
        } catch (Exception) {
          print('REQUESTS.DART: comments fucked up');
          thisPost.postComments = null;
        }

        return thisPost;
      }
    } else {
      var newComm;
      if (oldPost.postComments != null) {
        newComm = Map<String, String>.from(oldPost.postComments);
        newComm.addAll({"reload the feed": "to see your comment"});
      } else
        newComm = {"reload the feed": "to see your comment"};
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
          'postVideoURL': myPost.videoURL,
          'postGeoName': myPost.placeName.toString(),
          'postGeoId': myPost.placeGeoID.toString(),
        }),
      );
      if (response.statusCode >= 400 || response.statusCode < 100) return false;
      print(myPost.placeGeoID);
      return true;
    } else {
      print("REQUESTS.DART: " +
          Constants.backendURL +
          Constants.createPostEndpoint);
      return true;
    }
  }

  Future<bool> editPost(Post myPost) async {
    if (Constants.DEPLOYED) {
      var response = await http.put(
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
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print(jsonDecode(response.body)['message']);
        return false;
      }
      print('REQUESTS.DART: succesfully edited the post');
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
      var response = await http.delete(
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

  Future<Map<int, Post>> getPosts() async {
    if (Constants.DEPLOYED) {
      var response = await http.get(
          Constants.backendURL + Constants.feedEndpoint + currUserName,
          headers: header);
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print('error');
        print(jsonDecode(response.body));
      }
      var data = json.decode(response.body)['data'];
      if (data==null){
        return null;
      }
      Map<int, Post> posts = {};
      for (int i = 0; i < data.length; i++) {
        var text = data[i]['postText'];
        var image = data[i]['postImage'];
        var topic = data[i]['postTopic'];
        var videoURL = data[i]['postVideoURL'];
        var placeName = data[i]['postGeoName'];
        var postID = data[i]['postId'];
        var postDate = data[i]['postDate'];
        var postLikes = data[i]['totalPostLike'];
        var postDislikes = data[i]['totalPostDislike'];
        var postComments = data[i]['postCommentDto'];
        Post thisPost = Post().from(
            text: text,
            image: image,
            topic: topic,
            videoURL: videoURL,
            placeName: placeName,
            postID: postID,
            postOwnerName: data[i]['postOwnerName'],
            postDate: postDate,
            postLikes: postLikes,
            postDislikes: postDislikes);
        thisPost.userDislikedIt = data[i]['userDislikedIt'] == 'true' ||
            data[i]['userDislikedIt'] == true;
        thisPost.userLikedIt =
            data[i]['userLikedIt'] == 'true' || data[i]['userLikedIt'] == true;
        try {
          Map<String, String> comments = {};
          for (int i = 0; i < postComments.length; i++) {
            comments[i.toString() +
                postComments[i]['commentatorName'].toString()] = postComments[i]
                    ['postComment']
                .toString(); //otherwise a user could only comment once
          }
          thisPost.postComments = comments;
        } catch (Exception) {
          print('REQUESTS.DART: comments fucked up');
          thisPost.postComments = null;
        }
        posts[i] = thisPost;
      }
      return posts;
      //parse the response so it looks like the static map below.
    } else {
      return new Map<int, Post>.from({
        0: new Post(
          text: "This is a sample post with an image and a location.",
          placeName: "Sample Place Name",
          postDate: DateTime.now().toString(),
          image: Constants.sampleProfilePictureBASE64,
          postID: 0,
          postLikes: 0,
          postDislikes: 10,
          postOwnerName: "hasimsait",
          postComments: {"ahmet": "sample comment", "mehmet": "lorem ipsum..."},
          userDislikedIt: true,
        ),
        1: new Post(
          text: "This is another sample post under a topic.",
          postDate: DateTime.now().toString(),
          postID: 1,
          topic: "Sample Topic",
          postLikes: 10,
          postDislikes: 0,
          postOwnerName: "hasimsait",
        ),
        2: new Post(
          text:
              "This is a post from another user. Name and image are static, don't mind them.",
          postDate: DateTime.now().toString(),
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
    }
  }

  Future<User> getUserInfo(String userName) async {
    User thisUser = User(userName);
    print('REQUESTS.DART: getUserInfo requested info of ' +
        userName);
    var response = await http.get(
        Constants.backendURL + Constants.profileEndpoint + userName,
        headers: header);
    if (response.statusCode >= 400 || response.statusCode < 100) {
      print('REQUESTS.DART: ERROR: '+jsonDecode(response.body).toString());
      return thisUser;
    }
    var data = json.decode(response.body)['data'];
    print(json.decode(response.body).toString());
    if (data == null) {
      return thisUser;
    }
    print('REQUESTS.DART: getUserInfo requested info of ' +
        userName +
        ' and received: ' +
        json.decode(response.body).toString());
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
    if (userName == currUserName) {
      followedTopics = [];
      followedLocations = [];
      followerUsers = [];
      followedUsers = [];
      // so that whenever we getUserInfo (we do it a lot), we get user's followed stuff updated (otherwise it would be a waste)
      for (int i = 0; i < subscribedLocationIdsList.length; i++) {
        followedLocations.add(subscribedLocationIdsList[i].toString());
      }
      for (int i = 0; i < subscribedTopicNamesList.length; i++) {
        followedTopics.add(subscribedTopicNamesList[i].toString());
      }
      for (int i = 0; i < followingUserList.length; i++) {
        followedUsers.add(followingUserList[i].toString());
      }
      for (int i = 0; i < followerUserList.length; i++) {
        followerUsers.add(followerUserList[i].toString());
      }
    }
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
    List<Post> posts = [];
    for (int i = 0; i < data['userPostsList'].length; i++) {
      var text = data['userPostsList'][i]['postText'];
      var image = data['userPostsList'][i]['postImage'];
      var topic = data['userPostsList'][i]['postTopic'];
      var videoURL = data['userPostsList'][i]['postVideoURL'];
      var placeName = data['userPostsList'][i]['postGeoName'];
      var postID = data['userPostsList'][i]['postId'];
      var postDate = data['userPostsList'][i]['postDate'];
      var postLikes = data['userPostsList'][i]['totalPostLike'];
      var postDislikes = data['userPostsList'][i]['totalPostDislike'];
      var postComments = data['userPostsList'][i]['postCommentDto'];
      Post thisPost = Post().from(
          text: text,
          image: image,
          topic: topic,
          videoURL: videoURL,
          placeName: placeName,
          postID: postID,
          postOwnerName: userName,
          postDate: postDate,
          postLikes: postLikes,
          postDislikes: postDislikes);
      thisPost.userDislikedIt =
          data['userPostsList'][i]['userDislikedIt'] == 'true' ||
              data['userPostsList'][i]['userDislikedIt'] == true;
      thisPost.userLikedIt =
          data['userPostsList'][i]['userLikedIt'] == 'true' ||
              data['userPostsList'][i]['userLikedIt'] == true;
      try {
        Map<String, String> comments = {};
        for (int i = 0; i < postComments.length; i++) {
          comments[i.toString() +
              postComments[i]['commentatorName'].toString()] = postComments[i]
                  ['postComment']
              .toString(); //otherwise a user could only comment once
        }
        thisPost.postComments = comments;
      } catch (Exception) {
        print('REQUESTS.DART: comments fucked up');
        thisPost.postComments = null;
      }
      posts.add(thisPost);
    }
    thisUser.posts = posts;
    return thisUser;
  }

  Future<bool> like(int postID) async {
    if (Constants.DEPLOYED) {
      print('REQUESTS.DART: ' +
          currUserName +
          " attempts to like post: " +
          postID.toString());
      var response = await http.post(
          Constants.backendURL + Constants.interactWithPostEndpoint,
          headers: header,
          body: jsonEncode(<String, dynamic>{
            'postId': postID.toString(),
            'postLike': 1,
            'postDislike': 0,
            'commentatorName': currUserName,
          }));
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print(jsonDecode(response.body));
        return false;
      }
      print('REQUEST.DART: LIKE SUCCESSFUL');
      return true;
    } else {
      return true;
    }
  }

  Future<bool> dislike(int postID) async {
    if (Constants.DEPLOYED) {
      print('REQUESTS.DART: ' +
          currUserName +
          " attempts to dislike post: " +
          postID.toString());
      var response = await http.post(
          Constants.backendURL + Constants.interactWithPostEndpoint,
          headers: header,
          body: jsonEncode(<String, dynamic>{
            'postId': postID.toString(),
            'postLike': 0,
            'postDislike': 1,
            'commentatorName': currUserName,
          }));
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print(jsonDecode(response.body)['message']);
        return false;
      }
      print('REQUEST.DART: DISLIKE SUCCESSFUL');
      return true;
    } else {
      return true;
    }
  }

  Future<bool> followTopic(int postID) async {
    if (Constants.DEPLOYED) {
      //displayed under a post which is posted under topic,
      //body:{'subscriberUsername':currUserName,'postId':postId, 'subscribedContentType':'geo' or 'topic'}
      print('REQUESTS.DART: ' +
          currUserName +
          " attempts to follow to the topic of post: " +
          postID.toString());
      var response =
          await http.post(Constants.backendURL + Constants.subscribeEndpoint,
              headers: header,
              body: jsonEncode(<String, dynamic>{
                'subscriberUsername': currUserName,
                'postId': postID,
                'subscribedContentType': 'topic',
              }));
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print(jsonDecode(response.body).toString());
        return false;
      }
      print('REQUEST.DART: FOLLOW SUCCESSFUL');
      return true;
    } else {
      //followedTopics.add(topic);
      return true;
    }
  }

  Future<bool> followLocation(int postID) async {
    if (Constants.DEPLOYED) {
      print('REQUESTS.DART: ' +
          currUserName +
          " attempts to follow to the location of post: " +
          postID.toString());
      var response =
          await http.post(Constants.backendURL + Constants.subscribeEndpoint,
              headers: header,
              body: jsonEncode(<String, dynamic>{
                'subscriberUsername': currUserName,
                'postId': postID,
                'subscribedContentType': 'geo',
              }));
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print(jsonDecode(response.body).toString());
        return false;
      }
      print('REQUEST.DART: FOLLOW SUCCESSFUL');
      return true;
    } else {
      //followedLocations.add(locationID)
      return true;
    }
  }

  Future<bool> unfollowTopic(String topicName) async {
    if (Constants.DEPLOYED) {
      var response = await http.delete(
        Constants.backendURL +
            Constants.profileEndpoint +
            currUserName +
            '/unsubscribeTopic/' +
            topicName.replaceAll('#', ''),
        headers: header,
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to unfollow " +
            topicName +
            'has succeeded.');
        return true;
      } else {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to unfollow " +
            topicName +
            'has failed.');
        print('REQUESTS.DART: ' + jsonDecode(response.body).toString());
        followedTopics.remove(topicName);
        return false;
      }
    } else {
      //followedTopics.remove(topic);
      return true;
    }
  }

  Future<bool> unfollowLocation(String locationId) async {
    if (Constants.DEPLOYED) {
      var response = await http.delete(
        Constants.backendURL +
            Constants.profileEndpoint +
            currUserName +
            '/unsubscribeLocation/' +
            locationId,
        headers: header,
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to unfollow " +
            locationId +
            'has succeeded.');
        return true;
      } else {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to unfollow " +
            locationId +
            'has failed.');
        print('REQUESTS.DART: ' + jsonDecode(response.body).toString());
        followedTopics.remove(locationId);
        return false;
      }
    } else {
      //followedLocations.remove(locationID);
      return true;
    }
  }

  Future<bool> followUser(String userName) async {
    if (Constants.DEPLOYED) {
      var response = await http.post(
        Constants.backendURL + 'connections/follow',
        headers: header,
        body: jsonEncode(<String, String>{
          'followerName': currUserName,
          'followingName': userName,
        }),
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to follow " +
            userName +
            'has succeeded.');
        return true;
      } else {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to follow " +
            userName +
            'has failed.');
        print('REQUESTS.DART: ' + jsonDecode(response.body).toString());
        return false;
      }
    } else {
      return true;
    }
  }

  Future<bool> unfollowUser(String userName) async {
    if (Constants.DEPLOYED) {
      var response = await http.delete(
        Constants.backendURL +
            Constants.profileEndpoint +
            currUserName +
            '/removeConnection/' +
            userName,
        headers: header,
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to unfollow " +
            userName +
            'has succeeded.');
        return true;
      } else {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to unfollow " +
            userName +
            'has failed.');
        print('REQUESTS.DART: ' + jsonDecode(response.body).toString());
        return false;
      }
    } else {
      return true;
    }
  }

  Future<bool> isFollowingTopic(String topic) async {
    if (Constants.DEPLOYED) {
      if (followedTopics != null && followedTopics.contains(topic)) return true;
      return false;
    } else {
      return true;
    }
  }

  Future<bool> isFollowingLocation(String locationID) async {
    if (Constants.DEPLOYED) {
      if (followedLocations != null && followedLocations.contains(locationID))
        return true;
      return false;
    } else {
      return true;
    }
  }

  Future<bool> reportPost(int postID) async {
    if (Constants.DEPLOYED) {
      var response = await http.post(
        Constants.backendURL +
            Constants.feedEndpoint +
            currUserName +
            '/report/' +
            postID.toString(),
        headers: header,
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to report " +
            postID.toString() +
            'has succeeded.');
        return true;
      } else {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to report " +
            postID.toString() +
            'has failed.');
        print('REQUESTS.DART: ' + jsonDecode(response.body).toString());
        return false;
      }
    } else {
      return true;
    }
  }

  Future<bool> reportUser(String userName) async {
    if (Constants.DEPLOYED) {
      var response = await http.post(
        Constants.backendURL +
            'search/' +
            userName +
            '/profile/report/' +
            currUserName,
        headers: header,
      );
      if (response.statusCode < 400 && response.statusCode >= 200) {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to report " +
            userName +
            ' has succeeded.');
        return true;
      } else {
        print('REQUESTS.DART: ' +
            currUserName +
            "'s request to report " +
            userName +
            ' has failed.');
        print('REQUESTS.DART: ' + jsonDecode(response.body).toString());
        return false;
      }
    } else {
      return true;
    }
  }

  List<List<String>> getFollowedOfCurrentUser() {
    List<List<String>> ans = [];
    ans.add(followedUsers);
    ans.add(followedTopics);
    ans.add(followedLocations);
    return ans;
  }

  List<List<String>> getFollowersOfCurrentUser() {
    List<List<String>> ans = [];
    ans.add(followerUsers);
    ans.add([]);
    ans.add([]);
    return ans;
  }

  Future<List<List<String>>> getFollowedOf(String userName) async {
    if (userName == currUserName) return getFollowedOfCurrentUser();
    User thisUser = User(userName);
    var response = await http.get(
        Constants.backendURL + Constants.profileEndpoint + userName,
        headers: header);
    if (response.statusCode >= 400 || response.statusCode < 100) {
      print(jsonDecode(response.body).toString());
    }
    var data = json.decode(response.body)['data'];
    print('REQUESTS.DART: getUserInfo requested info of ' +
        userName +
        ' for listing its followed and received: ' +
        data.toString());
    var followingUserList = data['followingNamesList'];
    //print(followingUserList.length.toString());
    var followerUserList = data['followerNamesList'];
    //print(followerUserList.length.toString());
    var subscribedTopicNamesList = data['subscribedTopicNamesList'];
    //print(subscribedTopicNamesList.length.toString());
    var subscribedLocationIdsList = data['subscribedLocationIdsList'];
    //print(subscribedLocationIdsList.length.toString());
    List<String> afollowedTopics = [];
    List<String> afollowedLocations = [];
    List<String> afollowedUsers = [];
    // so that whenever we getUserInfo (we do it a lot), we get user's followed stuff updated (otherwise it would be a waste)
    for (int i = 0; i < subscribedLocationIdsList.length; i++) {
      afollowedLocations.add(subscribedLocationIdsList[i].toString());
    }
    for (int i = 0; i < subscribedTopicNamesList.length; i++) {
      afollowedTopics.add(subscribedTopicNamesList[i].toString());
    }
    for (int i = 0; i < followingUserList.length; i++) {
      afollowedUsers.add(followingUserList[i].toString());
    }
    List<List<String>> a = [];
    a.add(afollowedUsers);
    a.add(afollowedTopics);
    a.add(afollowedLocations);
    return a;
  }

  Future<List<List<String>>> getFollowersOf(String userName) async {
    if (userName == currUserName) return getFollowersOfCurrentUser();
    User thisUser = User(userName);
    var response = await http.get(
        Constants.backendURL + Constants.profileEndpoint + userName,
        headers: header);
    if (response.statusCode >= 400 || response.statusCode < 100) {
      print(jsonDecode(response.body).toString());
    }
    var data = json.decode(response.body)['data'];
    print('REQUESTS.DART: getUserInfo requested info of ' +
        userName +
        ' for listing its followers and received: ' +
        data.toString());
    var followerUserList = data['followerNamesList'];
    List<String> afollowerUsers = [];
    for (int i = 0; i < followerUserList.length; i++) {
      afollowerUsers.add(followerUserList[i].toString());
    }
    List<List<String>> a = [];
    a.add(afollowerUsers);
    a.add([]);
    a.add([]);
    return a;
  }

  Future<bool> deleteAccount(String userName) async {
    if (Constants.DEPLOYED) {
      print('REQUESTS.DART ATTEMPTING TO DELETE USER ' + userName + '.');
      /*print('REQUESTS.DART: deleteAccount starts');
      var response = await http.delete(
          Constants.backendURL + 'admin/'+'waitingReportedPosts/delete/'+,
          headers: header);
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print(jsonDecode(response.body).toString());
      }
      var data = json.decode(response.body)['data'];
      print('REQUESTS.DART: deleteAccount received'+data.toString());
       */
      print('REQUESTS.DART: deleteAccount not implemented yet');
      return false;
    } else {
      return true;
    }
  }

  Future<bool> timeOutAccount(String userName, int daysOfSuspension) async {
    if (Constants.DEPLOYED) {
      print('REQUESTS.DART ATTEMPTING TO TIMEOUT USER ' +
          userName +
          ' for ' +
          daysOfSuspension.toString() +
          ' days.');
      var response = await http.post(
        Constants.backendURL +
            'admin/' +
            'waitingReportedUsers/suspend/' +
            userName +
            '?suspendedDaysAmount=' +
            daysOfSuspension.toString(),
        headers: header,
      );
      if (response.statusCode >= 400 || response.statusCode < 100) {
        print(response.body.toString());
      }
      var data = json.decode(response.body)['data'];
      print(
          'REQUESTS.DART: getWaitingReportedPosts received' + data.toString());
      return true;
    } else {
      return true;
    }
  }

  Future<Map<int, Post>> getWaitingReportedPosts() async {
    print('REQUESTS.DART: getWaitingReportedPosts starts');
    var response = await http.get(
        Constants.backendURL + 'admin/' + 'waitingReportedPosts',
        headers: header);
    if (response.statusCode >= 400 || response.statusCode < 100) {
      print(jsonDecode(response.body).toString());
    }
    var data = json.decode(response.body)['data'];
    print('REQUESTS.DART: getWaitingReportedPosts received' + data.toString());
    //[{id: 8, postOwnerName: admin, postText: my post #topic, postTopic: #topic, postGeoName: null}]
    Map<int, Post> posts = {};
    for (int i = 0; i < data.length; i++) {
      var text = data[i]['postText'];
      var image = data[i]['postImage'];
      var topic = data[i]['postTopic'];
      var videoURL = data[i]['postVideoURL'];
      var placeName = data[i]['postGeoName'];
      Post thisPost = Post().from(
        text: text,
        image: image,
        topic: topic,
        videoURL: videoURL,
        placeName: placeName,
        postOwnerName: data[i]['postOwnerName'],
      );
      thisPost.userDislikedIt = data[i]['userDislikedIt'] == 'true' ||
          data[i]['userDislikedIt'] == true;
      thisPost.userLikedIt =
          data[i]['userLikedIt'] == 'true' || data[i]['userLikedIt'] == true;
      posts[i] = thisPost;
    }
    return posts;
  }

  Future<List<List<String>>> getWaitingReportedUsers() async {
    print('REQUESTS.DART: getWaitingReportedUsers starts');
    var response = await http.get(
        Constants.backendURL + 'admin/' + 'waitingReportedUsers',
        headers: header);
    if (response.statusCode >= 400 || response.statusCode < 100) {
      print(jsonDecode(response.body).toString());
    }
    var data = json.decode(response.body)['data'];
    print('REQUESTS.DART: getWaitingReportedUsers received' + data.toString());
    //[{userId: 1, username: admin}]
    List<String> reportedUsers = [];
    for (int i = 0; i < data.length; i++) {
      reportedUsers.add(data[i]['username'].toString());
    }
    List<List<String>> a = [];
    a.add(reportedUsers);
    a.add([]);
    a.add([]);
    return a;
  }

  Future<List<List<String>>> search(String text) async {
    print('REQUESTS.DART: search starts');
    String url;
    if (isAdmin)
      url = Constants.backendURL + 'admin/search/' + text;
    else
      url = Constants.backendURL + 'search/' + text;
    var response = await http.get(url, headers: header);
    if (response.statusCode >= 400 || response.statusCode < 100) {
      print(jsonDecode(response.body).toString());
    }
    var data = json.decode(response.body)['data'];
    //[{userId: 1, username: admin}]
    List<String> resultUsers = [];
    //it throws an error here when query is null but i think it works properly with that, may need to change
    for (int i = 0; i < data.length; i++) {
      resultUsers.add(data[i]['username'].toString());
    }
    List<List<String>> a = [];
    a.add(resultUsers);
    a.add([]);
    a.add([]);
    return a;
  }
}
