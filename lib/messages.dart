import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


import 'package:stomp_dart_client/parser.dart';
import 'package:stomp_dart_client/sock_js/sock_js_parser.dart';
import 'package:stomp_dart_client/sock_js/sock_js_utils.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import 'package:stomp_dart_client/stomp_parser.dart';
import 'helper/constants.dart';
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
  Widget prewMessages=Padding(padding: EdgeInsets.all(0.3));
  List<Widget> aaaaaaaaaaaa=[Padding(padding:EdgeInsets.all(0.3) )];
  final _postFieldController = TextEditingController();
  final _receiverFieldController = TextEditingController();
  StompClient client;
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
    _receiverFieldController.addListener(() {
      final text = _receiverFieldController.text;
      _receiverFieldController.value = _receiverFieldController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    aaaaaaaaaaaa=[Padding(padding:EdgeInsets.all(0.3) )];
    client = StompClient(
        config: StompConfig.SockJS(
            url: Constants.socketUrL,
            onConnect: onConnectCallback,
            webSocketConnectHeaders: Requests.header,
            stompConnectHeaders: Requests.header,
            onWebSocketError: (frame) => print(frame.toString()),
            onStompError: (frame) => print(frame.toString())
        )
    );
    super.initState();
  }
  void onConnectCallback(StompClient client, StompFrame connectFrame) {
    print('MESSAGES.DART: connected');
    /*TODO make input fields invisible till here to ensure that user can't send messages to the outer space.*/
    client.activate();
    client.subscribe(destination: '/chat/topic/messages/'+Requests.currUserName, headers: {}, callback: (frame) {
      // Received a frame for this subscription
      print(frame.body);
      aaaaaaaaaaaa.add(Text(frame.body!=null ? '${frame.body}' : ''));
    });
  }

  void dispose() {
    widget.channel.sink.close();
    _postFieldController.dispose();
    _receiverFieldController.dispose();
    client.deactivate();
    super.dispose();
  }

  void _sendMessage() {
    if (_postFieldController.text.isNotEmpty && _receiverFieldController.text.isNotEmpty) {
      client.send(destination: '/app/chat/'+_receiverFieldController.text, body: {'fromLogin':Requests.currUserName,'message':_postFieldController.text}.toString(), headers: {});
      //TODO this will not work, test it
      //WebSocketChannel sendTo=IOWebSocketChannel.connect('ws://echo.websocket.org');
      var sendTo=channel;
      print('MESSAGES.DART: connected to socket');
      sendTo.sink.add(_postFieldController.text);
      print('MESSAGES.DART: connected and added to sink');
      //sendTo.sink.close();
      //print('MESSAGES.DART: sink closed');
      aaaaaaaaaaaa.add(Text( '"'+ _postFieldController.text+'"'+ ' to: '+ _receiverFieldController.text));
    }
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar:  AppBar(
              title: new Text(
                'Messages',
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
            Padding(
              padding: const EdgeInsets.all(3),
            ),
            SizedBox(
              child: TextFormField(
                controller: _receiverFieldController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText:
                    'Enter the receiver\'s name here.'),
                autofocus: false,
                maxLength: 340,
                maxLines: 1,
                style: TextStyle(fontSize: 25),
              ),
              height: 70,
              width: 340,
            ),

            Row(
              children: <Widget>[
                SizedBox(
                  child: TextFormField(
                    controller: _postFieldController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'Enter your message here.'),
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
