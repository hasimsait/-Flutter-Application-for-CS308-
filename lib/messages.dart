//TODO Clicking a location or hashtag or searching anything opens this route. Display a subscribe button on top if it is a topic
import 'package:flutter/material.dart';
import 'package:teamone_social_media/dynamic_widget_list.dart';

import 'helper/requests.dart';

class Messages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      _MessagesState();
}

class _MessagesState extends State<Messages> {

  _MessagesState();
  String query = "";
  bool isFollowing;
  final _postFieldController = TextEditingController();
  Widget results = Text(
    'Please wait a while we retrieve your results.',
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
      appBar: (query == null || query == "")
          ? AppBar(
        title: Text('Search'),
      ) //flutter may not like that
          : new AppBar(
        title: new Text(
          'Search',
          textAlign: TextAlign.center,
        ),
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

  }
}
