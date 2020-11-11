import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class MyPost
{
  String text;
  List<PlatformFile> images;
  //;I'll use filepicker package for picking images, it returns File type objects
  String locationTag;
  MyPost( {this.text,this.images,this.locationTag});
  //dart does not allow you to overload constructors so I made them optional
  //var post = MyPost(text:"bezkoder", location: "US");
}