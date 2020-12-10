//TODO Clicking a location or hashtag or searching anything opens this route. Display a subscribe button on top if it is a topic
import 'package:flutter/material.dart';

import 'helper/requests.dart';

class Search extends StatefulWidget {
  final String topic;
  final String locationID;
  final String locationName;
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
  String query = "";
  bool isFollowing;

  void initState() {
    super.initState();
    //TODO check if the user is following the location/topic
    if (locationID != null || locationID != "") {
      if (locationName != null || locationName != "") {
        query = locationName;
        Requests().isFollowingLocation(locationID).then((value) {
          isFollowing = value;
          setState(() {});
        });
      }
    } else {
      print(
          "SEARCH.DART: YOU FORGOT TO PASS THE LOCATION NAME ALONG WITH THE LOCATION ID :))))");
    }
    if (topic != null || topic != "") {
      query = topic;
      Requests().isFollowingTopic(topic).then((value) {
        isFollowing = value;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //appbar displays the search query
      //if the query is a topic or a location (passed as a param) display a follow button
      //a search bar with initial value topic/locationname
      //listview with the retrieved results (may be post, may be user. be careful w that)
      appBar: (query == null || query == "")
          ? null //flutter may not like that
          : new AppBar(
              title: new Text(
                query,
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                  isFollowing
                      ? RaisedButton(
                          onPressed: () {
                            if (topic != null || topic != "")
                              Requests().followTopic(topic).then((value) {
                                isFollowing = value;
                                setState(() {});
                              });
                            else if (locationID != null || locationID != "")
                              Requests()
                                  .followLocation(locationID)
                                  .then((value) {
                                isFollowing = value;
                                setState(() {});
                              });
                            else {
                              //display nothing, it's usual search
                            }
                          },
                          child: Text("UNFOLLOW"),
                        )
                      : RaisedButton(
                          onPressed: () {
                            if (topic != null || topic != "")
                              Requests().unfollowTopic(topic).then((value) {
                                isFollowing = !value;
                                setState(() {});
                              });
                            else if (locationID != null || locationID != "")
                              Requests()
                                  .unfollowLocation(locationID)
                                  .then((value) {
                                isFollowing = !value;
                                setState(() {});
                              });
                            else {
                              //display nothing, it's usual search
                            }
                          },
                          child: Text("FOLLOW"),
                        ),
                ]),
      body: new ListView(
        children: <Widget>[
          //TODO add the search bar here
          Text(
            'Please wait a while we retrieve your results.',
          ),
        ],
      ),
      //what if we seperate them??? like twitter.
      // searchposts=feed.dart but with the results
      // search users is a listview of circle avatars
      // search location is similiar to users actually but text only.

      //or I can ask for a typeOfResult and
      // render the posts with specificPost
      // Row (CircleAvatar... Column(...)) (same thing I do above the posts)
      // Column(Text()) for place I guess?

      //I like the first way better but we will see. TODO implement search.
    );
    //request the feed of the topic or locationID, check if user is subscribed, if not display a subscribe button,
  }
}
