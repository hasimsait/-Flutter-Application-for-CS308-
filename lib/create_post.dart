//TODO add autocomplete to the create post
//TODO user can pick locations
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'helper/constants.dart';
import 'post.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:convert';
import 'package:place_picker/place_picker.dart';

class CreatePost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _postFieldController = TextEditingController();
  File file;
  bool fileType; //0 if image, 1 if video
  final picker = ImagePicker();
  Image thumbnail;
  double longitude;
  double latitude;
  String placeName;
  String placeGeoID;

  Future<bool> _sendPost() async {
    //This pops when post is sent, can't pull out of class, may put some of its features in the method
    Post post = new Post();
    if (_postFieldController.text != null) {
      post.text = _postFieldController.text;
      print(post.text);
    }
    if (_postFieldController.text == null) {
      post.text = "";
      print(post.text);
    }
    if (file != null && fileType == false) {
      post.image = base64Encode(file.readAsBytesSync());
      //print(post.image.path);
    }
    if (file != null && fileType == true) {
      post.videoURL = base64Encode(file.readAsBytesSync());
    }

    if (placeGeoID != null) {
      post.placeGeoID = placeGeoID;
      print(post.placeGeoID);
    }
    if (placeName != null) {
      post.placeName = placeName;
      print(post.placeName);
    }
    //String topic;
    // TODO we don't have topics yet, when we do, this function will take it as a parameter and this part will be moved elsewhere to avoid copying it

    if (Constants.DEPLOYED) {
      var response = await post.sendPost();
      if (response.statusCode < 400 && response.statusCode >= 200) {
        Navigator.pop(context, post);
        //TODO command the feed to reload.
      } else {
        //TODO create snackbar with "service is temporarily available.There was a good package for it, check the previous project"
      }
    } else {
      Navigator.pop(context, post);
    }
    return null;
  }

  Future _pickLocation() async {
    latitude = 0;
    longitude = 0;
    //TODO find a package that works.
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
              Constants.apiKey,
            )));
    placeName = result.name;
    placeGeoID = result.placeId;
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
    //TODO move it out of class
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
    //TODO get it out of class
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      file = File(response.file.path);
    }
  }

  void initState() {
    //this must stay here
    super.initState();
    _postFieldController.addListener(() {
      final text = _postFieldController.text;
      _postFieldController.value = _postFieldController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
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
              _sendPost();
            },
          ),
        ],
      ),
      body: new Center(
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
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
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
                  onPressed: () {
                    _pickLocation();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
