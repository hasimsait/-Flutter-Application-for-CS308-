import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';

class Session {
  final int id;
  final String data;

  Session({this.data, this.id});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["id"] = id;
    data["data"] = this.data;
    return data;
  }
  //usage
  //Data mappedData = Data(id: 1, data: "Lorem ipsum something, something...");
  //await FlutterSession().set('mappedData', mappedData);
}