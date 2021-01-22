import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'create_post.dart';
import 'post.dart';
import 'user.dart';
import 'profile.dart';
import 'dart:convert';
import 'create_comment.dart';
import 'helper/constants.dart';
import 'helper/requests.dart';

class SpecificPost extends StatefulWidget {
  final String currentUserName;
  final Post currPost;
  SpecificPost({this.currentUserName, this.currPost});
  @override
  State<StatefulWidget> createState() =>
      _SpecificPostState(this.currentUserName, this.currPost);
}

class _SpecificPostState extends State<SpecificPost> {
  String currentUserName;
  Post currPost;
  User owner;
  var postOwnerName = "";
  var topic;
  var placeName;
  var text = "";
  var postDate = DateTime.now().toString();
  var image;
  var videoURL;
  var postLikes = 0;
  var postDislikes = 0;
  var postID = 0;
  var postComments;
  var placeGeoID;
  bool isAdmin = false;
  bool liked = false;
  bool disliked = false;
  bool deleted = false;
  Widget followOptions = SizedBox();
  _SpecificPostState(this.currentUserName, this.currPost);

  void initState() {
    //this must stay here
    initializePost(currPost);
    _followOptions();
    setState(() {});
    print("SPECIFICPOST.DART: " + postID.toString() + "initializing.");
    //this is the single handedly most helpful print line here. objects are not reinitialized by the post.displaypost when i load feed again.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO turn topic/location/comment button into anchors.
    if (deleted == null || deleted == true) {
      print("SPECIFICPOST.DART: This item has been deleted.");
      return SizedBox();
    } else {
      return Card(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              Image.memory(base64Decode(owner.myProfilePicture))
                                  .image),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile(postOwnerName)),
                        );
                      },
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          owner.myName,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 20),
                        ),
                        topic != null && topic != "" && topic != 'null'
                            ? Container(
                                child: Flex(
                                  children: <Widget>[
                                    Text(
                                      topic,
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                  direction: Axis.vertical,
                                ),
                                width: 150,
                                alignment: Alignment.centerLeft,
                              )
                            : SizedBox(),
                        placeName != null &&
                                placeName != "" &&
                                placeName != 'null'
                            ? Container(
                                child: Flex(
                                  children: <Widget>[
                                    Text(
                                      placeName,
                                    ),
                                  ],
                                  direction: Axis.vertical,
                                ),
                                width: 150,
                                alignment: Alignment.centerLeft,
                              )
                            : SizedBox(), //TODO topic and location are anchors which push a new route
                        postDate != null
                            ? Container(
                                child: Text(
                                  postDate
                                      .toString()
                                      .substring(0, 16)
                                      .replaceAll('T', ' '),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 12),
                                ),
                                alignment: Alignment.centerLeft,
                              )
                            : SizedBox(),
                      ],
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                (postOwnerName == currentUserName) || (Requests.isAdmin)
                    ? Row(
                        children: <Widget>[
                          followOptions,
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                editPost(context);
                              }),
                          IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                Requests().deletePost(postID).then((value) {
                                  if (value) {
                                    //if post is deleted successfully
                                    Flushbar(
                                      title: "Success!",
                                      message: "Post deleted successfully!",
                                      duration: Duration(seconds: 3),
                                    )..show(context);
                                    print("SPECIFICPOST.DART: Post:" +
                                        postID.toString() +
                                        " deleted successfully");
                                    initializePost(currPost, delete: true);
                                    setState(
                                        () {}); //so that the post disappears
                                  } else {
                                    Flushbar(
                                      title: "Something went wrong.",
                                      message:
                                          "Post could not be deleted, please try again later.",
                                      duration: Duration(seconds: 3),
                                    )..show(context);
                                    print(
                                        "SPECIFICPOST.DART: Couldn't delete post:" +
                                            postID.toString());
                                  }
                                });
                              }),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      )
                    : Row(
                        children: <Widget>[
                          followOptions,
                          Padding(padding: EdgeInsets.all(25)),
                          IconButton(
                              icon: Icon(Icons.report),
                              onPressed: () {
                                Requests().reportPost(postID).then((value) {
                                  if (value.status) {
                                    Flushbar(
                                      title: "Success.",
                                      message: "Post successfully reported!.",
                                      duration: Duration(seconds: 3),
                                    )..show(context);
                                    setState(
                                        () {}); //so that the post disappears
                                  } else {
                                    Flushbar(
                                      title: "Something went wrong",
                                      message: value.message == null ||
                                              value.message == 'null'
                                          ? 'Please try again later'
                                          : value.message,
                                      duration: Duration(seconds: 3),
                                    )..show(context);
                                    print(
                                        "SPECIFICPOST.DART: Couldn't report post:" +
                                            postID.toString());
                                  }
                                });
                              }),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Padding(padding: EdgeInsets.all(5)),
            Text(text, style: TextStyle(fontSize: 20)),
            Padding(padding: EdgeInsets.all(5)),
            image != null && image != ""
                ? Image.memory(base64Decode(image))
                : _displayVideo(videoURL),
            //A post can't have both video and image and displaying video is messy.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color:
                        (liked != null && liked) ? Colors.blue : Colors.black38,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    Requests().like(postID).then((value) {
                      if (value.status) {
                        liked = true;
                        disliked = false;
                        Flushbar(
                          title: "Success!",
                          message: "Post liked successfully!",
                          duration: Duration(seconds: 1),
                        )..show(context);
                        Requests()
                            .reloadPost(postID, oldPost: currPost)
                            .then((value) {
                          currPost = value;
                          initializePost(value);
                        });
                        setState(() {});
                      } else {
                        Flushbar(
                          title: "Something went wrong",
                          message: value.message == null ||
                                  value.message == 'null'
                              ? "Post could not be liked, please try again later."
                              : value.message,
                          duration: Duration(seconds: 3),
                        )..show(context);
                      }
                    });
                    setState(() {});
                  },
                ),
                postLikes != null ? Text(postLikes.toString()) : SizedBox(),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                ),
                IconButton(
                  icon: Icon(
                    Icons.thumb_down,
                    color: (disliked != null && disliked)
                        ? Colors.blue
                        : Colors.black38,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    Requests().dislike(postID).then((value) {
                      if (value.status) {
                        disliked = true;
                        liked = false;
                        Flushbar(
                          title: "Success!",
                          message: "Post successfully disliked!",
                          duration: Duration(seconds: 1),
                        )..show(context);
                        Requests()
                            .reloadPost(postID, oldPost: currPost)
                            .then((value) {
                          currPost = value;
                          initializePost(value);
                        });
                        setState(() {});
                      } else {
                        Flushbar(
                          title: "Something went wrong",
                          message: value.message == null ||
                                  value.message == 'null'
                              ? "Post could not be disliked, please try again later."
                              : value.message,
                          duration: Duration(seconds: 3),
                        )..show(context);
                      }
                    });
                    setState(() {});
                  },
                ),
                postLikes != null ? Text(postDislikes.toString()) : SizedBox(),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_comment,
                    color: Colors.black38,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CreateComment(postID, currentUserName)),
                    ).then((value) {
                      if (value) {
                        Flushbar(
                          title: "Success!",
                          message:
                              "Comment posted successfully, reloading the post for you!",
                          duration: Duration(seconds: 1),
                        )..show(context);
                      }
                      Requests()
                          .reloadPost(postID, oldPost: currPost)
                          .then((value) {
                        currPost = value;
                        initializePost(value);
                      });
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
            _displayComments(postComments),
            Padding(padding: EdgeInsets.all(2))
          ],
        ),
        elevation: 5,
        shadowColor: Colors.blue,
      );
    }
  }

  Widget _displayVideo(String videoURL) {
    if (videoURL != null && videoURL != "")
      return SizedBox();
    //TODO display video
    else {
      return SizedBox();
    }
  }

  Widget _displayComments(Map<String, String> postComments) {
    if (postComments == null || postComments.length == 0) {
      return Text(
          "Currently there are no comments on this post. Be the first!");
    } else {
      List<Widget> comments = [];
      int i = 0;
      postComments.forEach((key, value) {
        comments.add(Text(
          key.replaceFirst(i.toString(), '') + " : " + value,
          textAlign: TextAlign.left,
        ));
        i += 1;
      });
      print('SPECIFICPOST.DART: ' +
          postID.toString() +
          ' has ' +
          comments.length.toString() +
          'comments');
      print('SPECIFICPOST.DART: ' +
          postID.toString() +
          ' last comment is: ' +
          postComments.entries.last.value);
      return Column(
        children: comments,
      );
    }
  }

  initializePost(Post newPost, {bool delete}) {
    if (delete != null && delete) {
      //FUCK FLUTTER., SPENT 2 HOURS BC IT WOULDNT TELL ME THIS IS WAS THE NULL. When shit fucks up, you get no info.
      print("SPECIFICPOST.DART: deleting the post");
      deleted = true;
      setState(() {});
    } else {
      owner = User(newPost.postOwnerName);
      owner.getInfo().then((value) {
        owner = value;
        setState(() {});
      });
      print('updating the post');
      setState(() {
        postOwnerName = newPost.postOwnerName;
        topic = newPost.topic;
        placeName = newPost.placeName;
        text = newPost.text;
        postDate = newPost.postDate;
        image = newPost.image;
        videoURL = newPost.videoURL;
        postLikes = newPost.postLikes;
        postDislikes = newPost.postDislikes;
        postID = newPost.postID;
        postComments = newPost.postComments;
        placeGeoID = newPost.placeGeoID;
        liked = newPost.userLikedIt == null ? false : newPost.userLikedIt;
        disliked =
            newPost.userDislikedIt == null ? false : newPost.userDislikedIt;
        if (Requests.isAdmin)
          isAdmin = true;
        else
          print(
              "SPECIFICPOST.DART: will not display edit and delete buttons for admin, user is not admin");
        //which displays the buttons to edit and delete the posts.
      });
    }
    currPost = newPost;
    _followOptions();
    setState(() {});
  }

  void editPost(context) {
    if (this.image != null) {
      //if the post has an image file attached to it
      _localFile().then((value) {
        File(value.path).writeAsBytesSync(base64Decode(this.image));
        return value;
      }).then((value) {
        print("SPECIFICPOST.DART: We got the picture");
        navigateToEditPostRoute(context, value);
      });
      //file =  File(tempFile)(base64Decode(this.image));
    } else if (this.videoURL != null) {
      _localFile().then((value) {
        File(value.path).writeAsBytesSync(base64Decode(this.videoURL));
        return value;
      }).then((value) {
        print("SPECIFICPOST.DART: We got the video");
        navigateToEditPostRoute(context, value);
      });
    } else {
      navigateToEditPostRoute(context, null);
    }
  }

  void navigateToEditPostRoute(context, file) {
    print("SPECIFICPOST.DART sends this post to editPost: " + this.text);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreatePost(
                postID: this.postID,
                text: this.text,
                placeName: this.placeName,
                placeGeoID: this.placeGeoID,
                topic: this.topic,
                videoFile: this.videoURL == null ? null : file,
                imageFile: this.image == null ? null : file,
              )),
    ).then((value) {
      Requests().reloadPost(postID, oldPost: currPost).then((value) {
        currPost = value;
        initializePost(currPost);
      });
      setState(() {});
    });
  }

  Future<File> _localFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/tempFile');
  }

  _followOptions() {
    if (placeName != null && placeName != '' && placeName != 'null') {
      Requests().isFollowingLocation(placeGeoID).then((value) {
        if (value) {
          followOptions = RaisedButton(
              padding: EdgeInsets.all(0),
              child: Container(
                width: 55,
                child: Text('unfollow location'),
                padding: EdgeInsets.all(0),
              ),
              onPressed: () {
                Requests().unfollowLocation(placeGeoID).then((value) {
                  if (value.status) {
                    Flushbar(
                      title: "Success!",
                      message: "Post's location unfollowed successfully",
                      duration: Duration(seconds: 1),
                    )..show(context);
                  } else {
                    Flushbar(
                      title: "Something went wrong",
                      message: value.message == null || value.message == 'null'
                          ? 'Please try again later'
                          : value.message,
                      duration: Duration(seconds: 3),
                    )..show(context);
                  }
                  setState(() {});
                });
              });
        } else {
          followOptions = RaisedButton(
              padding: EdgeInsets.all(0),
              child: Container(
                width: 55,
                child: Text('follow location'),
                padding: EdgeInsets.all(0),
              ),
              onPressed: () {
                Requests().followLocation(postID).then((value) {
                  print('_______________' +
                      value.toString() +
                      '_______________________');
                  if (value.status) {
                    Flushbar(
                      title: "Success!",
                      message: "Post's location followed successfully",
                      duration: Duration(seconds: 1),
                    )..show(context);
                  } else {
                    Flushbar(
                      title: "Something went wrong",
                      message: value.message == null || value.message == 'null'
                          ? 'Please try again later'
                          : value.message,
                      duration: Duration(seconds: 3),
                    )..show(context);
                  }
                  setState(() {});
                });
              });
        }
        setState(() {});
      });
    } else if (topic != null && topic != '' && topic != 'null') {
      Requests().isFollowingTopic(topic).then((value) {
        if (value) {
          followOptions = RaisedButton(
              padding: EdgeInsets.all(0),
              child: Container(
                width: 55,
                child: Text('unfollow topic'),
                padding: EdgeInsets.all(0),
              ),
              onPressed: () {
                Requests().unfollowTopic(topic).then((value) {
                  if (value.status) {
                    Flushbar(
                      title: "Success!",
                      message: "Post's topic unfollowed successfully",
                      duration: Duration(seconds: 1),
                    )..show(context);
                  } else {
                    Flushbar(
                      title: "Something went wrong",
                      message: value.message == null || value.message == 'null'
                          ? 'Please try again later'
                          : value.message,
                      duration: Duration(seconds: 3),
                    )..show(context);
                  }
                  setState(() {});
                });
              });
        } else {
          followOptions = RaisedButton(
              padding: EdgeInsets.all(0),
              child: Text('follow topic'),
              onPressed: () {
                Requests().followTopic(postID).then((value) {
                  if (value.status) {
                    Flushbar(
                      title: "Success!",
                      message: "Post's topic followed successfully",
                      duration: Duration(seconds: 1),
                    )..show(context);
                  } else {
                    Flushbar(
                      title: "Something went wrong",
                      message: value.message == null || value.message == 'null'
                          ? 'Please try again later'
                          : value.message,
                      duration: Duration(seconds: 3),
                    )..show(context);
                  }
                  setState(() {});
                });
              });
        }
        setState(() {});
      });
    } else {
      followOptions = SizedBox();
      setState(() {});
    }
  }
}
