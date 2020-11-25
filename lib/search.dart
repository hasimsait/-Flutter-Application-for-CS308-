//TODO Clicking a location or hashtag or searching anything opens this route. Display a subscribe button on top if it is a topic
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  String topic = "";
  String locationID = "";
  String locationName = "";
  Search({this.topic, this.locationID, this.locationName});
  @override
  State<StatefulWidget> createState() =>
      _SearchState(this.topic, this.locationID, this.locationName);
}

class _SearchState extends State<Search> {
  String topic = "";
  String locationID = "";
  String locationName = "";
  _SearchState(this.topic, this.locationID, this.locationName);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
    //request the feed of the topic or locationID, check if user is subscribed, if not display a subscribe button,
  }
}
