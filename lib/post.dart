import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class Post
{
  String text;
  PickedFile image;
  //;I'll use filepicker package for picking images, it returns File type objects
  String locationTag;
  Post( {this.text,this.image,this.locationTag});
  //dart does not allow you to overload constructors so I made them optional
  //var post = MyPost(text:"bezkoder", location: "US");
}