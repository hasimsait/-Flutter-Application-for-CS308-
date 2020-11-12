//TODO add create new post widget that will be displayed on top of feed
//TODO add autocomplete to the create post
//TODO user can add images and or videos, pick locations and add hashtags
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'helper/constants.dart';
import 'post.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreatePost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _postFieldController = TextEditingController();
  PickedFile file;
  final picker = ImagePicker();
  double longitude;
  double latitude;

  Future<bool> _sendPost() async {
    Post post = new Post();
    if (_postFieldController.text != null) {
      post.text = _postFieldController.text;
      print(post.text);
    }
    if (file != null) {
      post.image = file;
      print(post.image.path);
    }
    if (latitude != null) {
      post.latitude = latitude;
      print(post.latitude);
    }
    if (longitude != null) {
      post.longitude = longitude;
      print(post.longitude);
    }
    //String topic;
    // TODO we don't have topics yet, when we do, this function will take it as a parameter and this part will be moved elsewhere to avoid copying it
    //String videoURL;I don't understand how it's supposed to work
    Navigator.pop(context, post); //TODO delete this line when deployed
    var response = await post.sendPost();
    if (response.statusCode < 400 && response.statusCode >= 200) {
      Navigator.pop(context, post);
      //return the post too so that it can be displayed at the top without refreshing the page
    }
    //TODO create snackbar with "service is temporarily available."

    return null;
  }

  Future _pickLocation() async {
    LocationResult result = await showLocationPicker(context, Constants.apiKey);
    setState(() {
      if (result.latLng != null) {
        longitude = result.latLng.longitude;
        latitude = result.latLng.latitude;
        print("+++++++++++++++++++++++++++++++++++" +
            longitude.toString() +
            " " +
            latitude.toString() +
            "++++++++++++++++++++++++++++++++++");
      } else {
        print(
            '-----------------------------------------------------GOOGLE_MAP_LOCATION_PICKER IS A GREAT PACKAGE.----------------------------------------------------');
      }
    });
  }

  Future _getImage(source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null && pickedFile.path != null) {
        file = PickedFile(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Widget _previewImage() {
    if (file != null && file.path != null) {
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
            //File is deprecating, check if Image class has an alternative
            //we may crop and display a preview, currently it puts the entire image
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
                });
              },
            ),
          ),
        ],
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      file = response.file;
    }
  }

  void initState() {
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
                    _getImage(ImageSource.gallery);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {
                    _getImage(ImageSource.camera);
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
