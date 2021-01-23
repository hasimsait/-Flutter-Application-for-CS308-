import 'dart:async';
import 'package:flutter/material.dart';
import 'message.dart';
import 'helper/requests.dart';
import 'messageWith.dart';

class Messages extends StatefulWidget {
  const Messages();
  @override
  State<StatefulWidget> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  _MessagesState();
  List<String> people = [];
  Map<String, List<Message>> messages = {};
  GlobalKey<RefreshIndicatorState> refreshKey;
  final _postFieldController = TextEditingController();
  Timer timer;
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    _postFieldController.addListener(() {
      final text = _postFieldController.text;
      _postFieldController.value = _postFieldController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });

    _getMessages();
    const oneSec = const Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer t) => _checkUpdates());
  }

  void dispose() {
    _postFieldController.dispose();
    timer.cancel();
    //ideally you would dispose the timer here but whatever
    super.dispose();
  }

  void _getMessages() {
    messages.clear();
    setState(() {});
    _listUsers().then((value) {
      value.forEach((element) {
        Requests().getMessages(element).then((value) {
          messages[element] = value;
          print('MESSAGES: ' + value.toString());
          setState(() {});
        });
      });
    });
  }

  Future<List<String>> _listUsers() async {
    List<List<String>> response =
        await Requests().getFollowedOf(Requests.currUserName);
    List<String> following = List.from(response[0]);
    response = await Requests().getFollowersOf(Requests.currUserName);
    List<String> followers = List.from(response[0]);
    people = List.from(following);
    people.addAll(followers);
    print('MESSAGES.DART: will display the chat with ' + people.toString());
    setState(() {});
    return people;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: new Text(
          'Messages',
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              messageList(),
              Padding(
                padding: const EdgeInsets.all(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageList() {
    return Container(
      child: ListView.builder(
        itemCount: people.length,
        itemBuilder: (BuildContext context, int index) {
          return row(context, index);
        },
      ),
      height: 620,
      color: Colors.blue,
    );
  }

  Widget row(context, index) {
    try {
      if (messages != null && messages.isNotEmpty)
        return Container(
          key: Key(people[index]),
          child: Card(
            child: RaisedButton(
              onPressed: () {
                var name = people[index];
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageWith(name)),
                );
              },
              padding: EdgeInsets.all(0),
              child: ListTile(
                title: Text(
                  people[index].toString(),
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: Text(
                    messages[people[index]].last.messageContent.length > 115
                        ? messages[people[index]]
                                .last
                                .messageContent
                                .substring(0, 115) +
                            '...'
                        : messages[people[index]].last.messageContent),
              ),
              color: Colors.white,
            ),
          ),
          height: 100,
          width: 500,
        );
    } catch (e) {
      return SizedBox();
    }
  }

  _checkUpdates() {
    _listUsers().then((value) {
      //check if any updates in any chat, if there is then do this
      Map<String, List<Message>> newMessages = {};
      setState(() {});
      value.forEach((element) {
        Requests().getMessages(element).then((value) {
          newMessages[element] = value;
          //print('MESSAGES: ' + value.toString());
          if (messages == null ||
              messages.isEmpty ||
              messages[element] == null) {
            if (messages == null) messages = {};
            messages[element] = List.from(newMessages[element]);
          }
          if (messages[element].last.messageDate !=
              newMessages[element].last.messageDate)
            messages[element] = List.from(newMessages[element]);

          setState(() {});
        });
      });
    });
  }
}
