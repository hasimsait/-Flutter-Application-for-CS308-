import 'package:flutter/material.dart';
import 'package:teamone_social_media/dynamic_widget_list.dart';

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
  final _postFieldController = TextEditingController();
  Widget results = Text(
    'Please wait a while we retrieve your results.',
  );
  void initState() {
    //TODO check if the user is following the location/topic
    /*if (locationID != null || locationID != "") {
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
    }*/
    _postFieldController.addListener(() {
      final text = _postFieldController.text;
      _postFieldController.value = _postFieldController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    super.initState();
  }

  void dispose() {
    _postFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //appbar displays the search query
      //if the query is a topic or a location (passed as a param) display a follow button
      //a search bar with initial value topic/locationname
      //listview with the retrieved results (may be post, may be user. be careful w that)
      appBar: (query == null || query == "")
          ? AppBar(
              title: Text('Search'),
            ) //flutter may not like that
          : new AppBar(
              title: new Text(
                'Search',
                textAlign: TextAlign.center,
              ),
              /*actions: <Widget>[
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
                ]*/
            ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(3),),
            Row(
              children: <Widget>[
                SizedBox(
                  child: TextFormField(
                    controller: _postFieldController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'Enter the name of the user you want to search here.'),
                    autofocus: false,
                    maxLength: 340,
                    maxLines: 1,
                    style: TextStyle(fontSize: 25),
                  ),
                  height: 70,
                  width: 340,
                ),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      results = Text(
                        'Please wait a while we retrieve your results.',
                      );
                      if (_postFieldController != null &&
                          _postFieldController.text != null) {
                        Requests()
                            .search(_postFieldController.text)
                            .then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DynamicWidgetList(value)),
                          );
                        });
                      }
                    })
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ],
        ),
      ),
    );
    //what if we seperate them??? like twitter.
    // searchposts=feed.dart but with the results
    // search users is a listview of circle avatars
    // search location is similiar to users actually but text only.

    //or I can ask for a typeOfResult and
    // render the posts with specificPost
    // Row (CircleAvatar... Column(...)) (same thing I do above the posts)
    // Column(Text()) for place I guess?

    //I like the first way better but we will see. TODO implement search.
    //request the feed of the topic or locationID, check if user is subscribed, if not display a subscribe button,
  }
}
