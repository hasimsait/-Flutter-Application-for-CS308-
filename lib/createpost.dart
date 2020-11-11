//TODO add create new post widget that will be displayed on top of feed
//TODO add autocomplete to the create post
//TODO user can add images and or videos, pick locations and add hashtags
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'helper/constants.dart';
import 'post.dart';

class CreatePost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _postFieldController = TextEditingController();
  PickedFile file;
  final picker = ImagePicker();

  Future<bool> _sendPost() {
    int status = 400;

    Post post = new Post();
    if (_postFieldController.text != null) {
      post.text = _postFieldController.text;
      print(post.text);
    }
    if (file != null) {
      post.image = file;
      print(post.image.path);
    }

    //TODO send the post
    status = 200; //or 302 whatever.
    if (status < 400 && status >= 200) {
      Navigator.pop(context, post);
    }
    //TODO create snackbar with "service is temporarily available."
    return null;
  }
 Future _pickLocation() async{

 }
  Future _getImage(source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        file = PickedFile(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Widget _previewImage() {
    if (file != null) {
      return new Stack(
        //It's one way to do it
        children: <Widget>[
          Container(
            width: 400.00,
            height: 300.00,
            child: Image.file(File(file.path),fit: BoxFit.fitWidth,),
            //File is deprecating, check if Image class has an alternative
            //we may crop and display a preview, currently it puts the entire image
          ),
          Positioned(
            left: -10,
            top:5,
            child:RaisedButton(
              child: Icon(Icons.cancel,size: 35,), shape: CircleBorder(), color: Colors.transparent, focusColor: Colors.black,
              onPressed: () {
              setState(() {
                file=null;
              });
            },
          ),),
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
