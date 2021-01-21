import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'helper/constants.dart';
import 'post.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:convert';
import 'package:place_picker/place_picker.dart';
import 'helper/requests.dart';

class CreatePost extends StatefulWidget {
  final File imageFile;
  final File videoFile;
  final String placeName;
  final String placeGeoID;
  final String text;
  final int postID;
  final String topic;
  CreatePost(
      {this.postID,
      this.text,
      this.imageFile,
      this.videoFile,
      this.placeName,
      this.placeGeoID,
      this.topic});
  @override
  State<StatefulWidget> createState() => _CreatePostState(
      postID: this.postID,
      initText: this.text,
      imageFile: this.imageFile,
      videoFile: this.videoFile,
      placeName: this.placeName,
      placeGeoID: this.placeGeoID,
      topic: this.topic);
}

class _CreatePostState extends State<CreatePost> {
  final _postFieldController = TextEditingController();
  File file;
  bool fileType; //0 if image, 1 if video
  final picker = ImagePicker();
  Image thumbnail;
  String placeName;
  String placeGeoID;
  String topic;

  bool editing;
  int postID;
  String initText = "";
  _CreatePostState(
      {this.postID,
      this.initText,
      File imageFile,
      File videoFile,
      this.placeName,
      this.placeGeoID,
      this.topic}) {
    if (this.postID != null) {
      editing = true; //not necessary but will make it look better.
    }
    if (imageFile != null) {
      this.file = imageFile;
      this.fileType = false;
    } else if (videoFile != null) {
      this.file = videoFile;
      this.fileType = true;
    }
  } //this will only be used when editing post btw, I hate it too.

  _sendPost() async {
    //This pops when post is sent, can't pull out of class, may put some of its features in the method
    var post = fillPostFields();
    bool result = await Requests().sendPost(post);
    if (result) {
      Navigator.pop(context, post);
      print("Successfully created the post.");
    } else {
      print("there is something wrong.");
      //TODO display error message
    }
    return null;
  }

  Future _pickLocation() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
              Constants.apiKey,
            )));
    placeName = result.name;
    placeGeoID = result.placeId;
    setState(() {
      //so that the location icon turns blue
    });
  }

  Future _getImage(source, isVideo) async {
    //we may make it return file and fileType instead of setState
    setState(() {
      file = null;
      fileType = null;
    });
    if (isVideo) {
      final pickedFile = await picker.getVideo(
          source: source,
          maxDuration: const Duration(seconds: Constants.maxVideoDuration));
      if (pickedFile != null && pickedFile.path != null) {
        file = File(pickedFile.path);
        fileType = true;
        /*
        var genThumb = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth:400, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );
        thumbnail=await Image.memory(genThumb);*/
        //print(thumbnail);
        setState(() {
          //thumbnail=thumbnail;
          file = file;
          fileType = true;
        });
      } else {
        print('No image selected.');
      }
      setState(() {});
    } else {
      final pickedFile = await picker.getImage(source: source);
      setState(() {
        if (pickedFile != null && pickedFile.path != null) {
          file = File(pickedFile.path);
          fileType = false;
        } else {
          print('No image selected.');
        }
      });
    }
  }

  Widget _previewImage() {
    //TODO move it out of class to helper/image_helper
    if (file != null && file.path != null && fileType == false) {
      return new Stack(
        //It's one way to do it
        children: <Widget>[
          Container(
            width: 400.00,
            height: 300.00,
            child: Image.file(
              File(file.path),
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            left: -10,
            top: 5,
            child: RaisedButton(
              child: Icon(
                Icons.cancel,
                size: 35,
              ),
              shape: CircleBorder(),
              color: Colors.transparent,
              focusColor: Colors.black,
              onPressed: () {
                setState(() {
                  file = null;
                  fileType = null;
                });
              },
            ),
          ),
        ],
      );
    } else if (file != null && file.path != null && fileType == true) {
      return new /*TODO fix it, there is something wrong with video thumbnail
        Stack(
        //It's one way to do it
        children: <Widget>[
          Container(
            width: 400.00,
            height: 300.00,
            child: thumbnail,
              //fit: BoxFit.fitWidth,
          ),*/
          Positioned(
        left: -10,
        top: 5,
        child: RaisedButton(
          child: Icon(
            Icons.cancel,
            size: 35,
          ),
          shape: CircleBorder(),
          color: Colors.transparent,
          focusColor: Colors.black,
          onPressed: () {
            setState(() {
              file = null;
              fileType = null;
              thumbnail = null;
            });
          },
        ),
      ) /*,
        ],
      )*/
          ;
    } else {
      return const Text(
        'You have not yet picked an image or a video.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    //TODO get it out of class to helper/image_helper
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      file = File(response.file.path);
    }
  }

  void initState() {
    super.initState();
    _postFieldController.text = initText;
    _postFieldController.addListener(() {
      final text = _postFieldController.text;
      _postFieldController.value = _postFieldController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    setState(() {

    });
  }

  void dispose() {
    _postFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Constants.postAppBarText),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.create),
            onPressed: () {
              if (editing == null || !editing)
                _sendPost();
              else {
                _editPost();
              }
            },
          ),
        ],
      ),
      body: new Center(
        child: new Container(
          alignment: Alignment.topCenter,
          child: new SingleChildScrollView(
            child: new Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new TextFormField(
                  controller: _postFieldController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'What\'s on your mind?'),
                  autofocus: true,
                ),
                FutureBuilder<void>(
                  future: retrieveLostData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      case ConnectionState.done:
                        return _previewImage();
                      default:
                        if (snapshot.hasError) {
                          return Text(
                            'Pick image/video error: ${snapshot.error}}',
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return const Text(
                            'You have not yet picked an image.',
                            textAlign: TextAlign.center,
                          );
                        }
                    }
                  },
                ),
                new Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () {
                        _getImage(ImageSource.gallery, false);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        _getImage(ImageSource.camera, false);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.video_collection),
                      onPressed: () {
                        _getImage(ImageSource.gallery, true);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.video_call),
                      onPressed: () {
                        _getImage(ImageSource.camera, true);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.location_on),
                      color: placeGeoID == null ? Colors.black87 : Colors.blue,
                      onPressed: () {
                        _pickLocation();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  fillPostFields() {
    Post post = new Post();
    if (_postFieldController.text != null) {
      post.text = _postFieldController.text;
      print("Post text: " + post.text);
    }
    if (_postFieldController.text == null) {
      post.text = "";
      print("Post text: " + post.text);
    }
    if (file != null && fileType == false) {
      post.image = base64Encode(file.readAsBytesSync());
      print("Post has an image attached to it.");
    }
    if (file != null && fileType == true) {
      post.videoURL = base64Encode(file.readAsBytesSync());
      print("Post has a video attached to it.");
    }

    if (placeGeoID != null) {
      post.placeGeoID = placeGeoID;
      print("Post place GeoID: " + post.placeGeoID);
    }
    if (placeName != null) {
      post.placeName = placeName;
      print("Post place name: " + post.placeName);
    }

    if (topic != null) {
      post.topic = topic;
      print("Post topic: " + post.topic);
    }
    return post;
  }

  void _editPost() async {
    Post post = fillPostFields();
    post.postID = postID;
    bool result = await Requests().editPost(post);
    if (result) {
      Navigator.pop(context, post);
      print("Successfully edited the post with postID: " + postID.toString());
    } else {
      print("there is something wrong.");
      //TODO display error message
    }
    return null;
  }
}
