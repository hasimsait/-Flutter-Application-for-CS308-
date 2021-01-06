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
  var client;

  void initState() {

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
    //TODO ideally this would be a global client and we would create it in main and pass it as a param from the navigator. Makes it easier to disconnect too. Do it once you get it working.
    aaaaaaaaaaaa=[Padding(padding:EdgeInsets.all(0.3) )];
    super.initState();
  }
  void onConnectCallback(StompClient client, StompFrame connectFrame) {
    print('NOTIFICATIONS.DART: connected');
    /*TODO make input fields invisible till here to ensure that user can't send messages to the outer space.*/
    client.activate();
    client.subscribe(destination: '/topic/notification', headers: {}, callback: (frame) {
      // Received a frame for this subscription
      print(frame.body);
      aaaaaaaaaaaa.add(Text(frame.body!=null ? '${frame.body}' : ''));
    });
  }
  void dispose() {
    widget.channel.sink.close();
    client.deactivate();
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
