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
  String query = 'Search';
  bool isFollowing;
  final _postFieldController = TextEditingController();
  Widget results = Text(
    'You can search users, topics and locations now!.',
  );
  void initState() {
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
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  child: TextFormField(
                    controller: _postFieldController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: query),
                    autofocus: false,
                    maxLines: 1,
                    style: TextStyle(fontSize: 25),
                    textAlignVertical: TextAlignVertical.bottom,
                  ),
                  height: 35,
                  width: 320,
                ),
                IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.search),
                    onPressed: () {
                      results = Text(
                        'Please wait a while we retrieve your results.',
                      );
                      if (_postFieldController != null &&
                          _postFieldController.text != null) {
                        Requests()
                            .searchUser(_postFieldController.text)
                            .then((value) {
                          results = DynamicWidgetList(value, noAppBar: true);
                          setState(() {});
                        });
                      }
                    })
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            ButtonBar(
                children: <Widget>[
                  FlatButton(onPressed: () {
                    results = Text(
                      'Please wait a while we retrieve your results.',
                    );
                    setState(() {});
                    if (_postFieldController != null &&
                        _postFieldController.text != null) {
                      Requests()
                          .searchUser(_postFieldController.text)
                          .then((value) {
                        results = DynamicWidgetList(value, noAppBar: true);
                        setState(() {});
                      });
                    }
                  }, child: Text("People")),
                  FlatButton(onPressed: () {
                    results = Text(
                      'Please wait a while we retrieve your results.',
                    );
                    setState(() {});
                    if (_postFieldController != null &&
                        _postFieldController.text != null) {
                      Requests()
                          .searchTopic(_postFieldController.text)
                          .then((value) {
                        results = DynamicWidgetList(value, noAppBar: true);
                        setState(() {});
                      });
                    }
                  }, child: Text("Topic")),
                  FlatButton(onPressed: () {
                    results = Text(
                      'Please wait a while we retrieve your results.',
                    );
                    setState(() {});
                    if (_postFieldController != null &&
                        _postFieldController.text != null) {
                      Requests()
                          .searchLocation(_postFieldController.text)
                          .then((value) {
                        results = DynamicWidgetList(value, noAppBar: true);
                        setState(() {});
                      });
                    }
                  }, child: Text("Location")),
                ],
                alignment: MainAxisAlignment.center,
                buttonPadding: EdgeInsets.all(0)),
            Container(
              height: 577.0,
              child: results == null ? SizedBox() : results,
            ),
          ],
        ),
      ),
    );
  }
}
