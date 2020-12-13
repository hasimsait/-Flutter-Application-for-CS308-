import 'dart:io';
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
  _SpecificPostState(this.currentUserName, this.currPost);

  void initState() {
    //this must stay here
    initializePost(currPost);
    setState(() {});
    print("SPECIFICPOST.DART: " + postID.toString() + "initializing.");
    //this is the single handedly most helpful print line here. objects are not reinitialized by the post.displaypost when i load feed again.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (postComments != null)
      print('SPECIFICPOST.DART build function: ' +
          postID.toString() +
          ' last comment is: ' +
          postComments.entries.last.value);
    //TODO turn topic/location/comment button into anchors.
    if (deleted == null || deleted == true) {
      print("SPECIFICPOST.DART: This item has been deleted.");
      return SizedBox();
    } else {
      return new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: CircleAvatar(
                        radius: 25,
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
                    children: <Widget>[
                      Text(
                        owner.myName,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15),
                      ),
                      topic != null && topic != "" && topic != 'null'
                          ? Text(
                              topic,
                              textAlign: TextAlign.left,
                            )
                          : SizedBox(),
                      placeName != null &&
                              placeName != "" &&
                              placeName != 'null'
                          ? Text(
                              placeName,
                            )
                          : SizedBox(), //TODO topic and location are anchors which push a new route
                      Container(
                        child: Text(
                          postDate.toString().substring(0, 16),
                          textAlign: TextAlign.left,
                        ),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      ),
                    ],
                  ),
                ],
              ),
              (postOwnerName == currentUserName) || (isAdmin)
                  ? Row(children: <Widget>[
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
                                print("SPECIFICPOST.DART: Post:" +
                                    postID.toString() +
                                    " deleted successfully");
                                initializePost(currPost, delete: true);
                                setState(() {}); //so that the post disappears
                              } else {
                                //TODO display error message
                                print(
                                    "SPECIFICPOST.DART: Couldn't delete post:" +
                                        postID.toString());
                              }
                            });
                          })
                    ])
                  : SizedBox(),
            ],
          ),

          Text(text, style: TextStyle(fontSize: 20)),
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
                    if (value) {
                      liked = true;
                      disliked = false;
                    }
                  });
                  setState(() {});
                },
              ),
              Text(postLikes.toString()),
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
                    if (value) {
                      disliked = true;
                      liked = false;
                    }
                  });
                  setState(() {});
                },
              ),
              Text(postDislikes.toString()),
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
        ],
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
      postComments.forEach((key, value) {
        comments.add(Text(
          key + ":" + value,
          textAlign: TextAlign.left,
        ));
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
        if (currentUserName == "ADMIN")
          isAdmin = true;
        else
          print(
              "SPECIFICPOST.DART: will not display edit and delete buttons for admin, user is not admin");
        //which displays the buttons to edit and delete the posts.
      });
    }
    currPost = newPost;
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
}
