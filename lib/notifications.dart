import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'helper/constants.dart';
import 'helper/requests.dart';

class Notifications extends StatefulWidget {
  final WebSocketChannel channel;

  const Notifications({Key key, this.channel}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _NotificationsState(this.channel);
}

class _NotificationsState extends State<Notifications> {
  final WebSocketChannel channel;
  _NotificationsState(this.channel);
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

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar:  AppBar(
        title: new Text(
          'Notifications',
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
                print(snapshot.toString());
                return _displayMessages(aaaaaaaaaaaa);
              },
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
