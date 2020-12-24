//TODO Clicking a location or hashtag or searching anything opens this route. Display a subscribe button on top if it is a topic
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'helper/requests.dart';

class Messages extends StatefulWidget {
  final WebSocketChannel channel;

  const Messages({Key key, this.channel}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MessagesState(this.channel);
}

class _MessagesState extends State<Messages> {
  final WebSocketChannel channel;
  _MessagesState(this.channel);
  String query = "";
  Widget prewMessages=Padding(padding: EdgeInsets.all(0.3));
  List<Widget> aaaaaaaaaaaa=[Padding(padding:EdgeInsets.all(0.3) )];
  final _postFieldController = TextEditingController();

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
    aaaaaaaaaaaa=[Padding(padding:EdgeInsets.all(0.3) )];
    super.initState();
  }

  void dispose() {
    widget.channel.sink.close();
    _postFieldController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_postFieldController.text.isNotEmpty) {
      widget.channel.sink.add(_postFieldController.text);
      aaaaaaaaaaaa.add(Text(_postFieldController.text));
    }
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
        child: SingleChildScrollView(child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                aaaaaaaaaaaa.add(Text(snapshot.hasData ? '${snapshot.data}' : ''));
                return _displayMessages(aaaaaaaaaaaa);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(3),
            ),
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
                    icon: Icon(Icons.send),
                    onPressed: () {
                      _sendMessage();
                    })
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ],
        ),),
      ),
    );
  }

  Widget _displayMessages(List<Widget> aaaaaaaaaaaa) {
    return Column( children: aaaaaaaaaaaa
    );
  }
}
