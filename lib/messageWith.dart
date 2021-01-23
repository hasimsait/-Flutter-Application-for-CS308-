//todo i could add a profile picture but i dont want to deal with it now.
import 'dart:async';
import 'package:flutter/material.dart';
import 'message.dart';
import 'helper/requests.dart';

class MessageWith extends StatefulWidget {
  final String username;
  MessageWith(this.username);
  @override
  State<StatefulWidget> createState() => _MessageWithState(username);
}

class _MessageWithState extends State<MessageWith> {
  final String username;
  _MessageWithState(this.username);
  List<Message> messages = [];
  final _postFieldController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer timer;
  void initState() {
    super.initState();
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
    const oneSec = const Duration(milliseconds: 500);
    timer = Timer.periodic(oneSec, (Timer t) => _checkUpdates());
  }

  void dispose() {
    _postFieldController.dispose();
    timer.cancel();
    super.dispose();
  }

  void _getMessages() {
    messages.clear();
    setState(() {});

    Requests().getMessages(username).then((value) {
      messages = value;
      setState(() {});
    });
  }

  void _sendMessage() {
    if (_postFieldController.text.isNotEmpty) {
      Requests().sendMessageTo(username, _postFieldController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: new Text(
          username,
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              messageList(),
              Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                        controller: _postFieldController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Start a message'),
                        autofocus: false,
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      height: 60,
                      width: 340,
                      color: Colors.white,
                      alignment: Alignment.bottomCenter,
                    ),
                    IconButton(
                        color: Colors.blue,
                        enableFeedback: true,
                        icon: Icon(Icons.send),
                        onPressed: () {
                          _sendMessage();
                        })
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
      ),
    );
  }

  Widget messageList() {
    return Container(
      child: ListView.builder(
        itemCount: messages.length,
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          return row(context, index);
        },
      ),
      height: 563,
      color: Colors.white,
    );
  }

  Widget row(context, index) {
    try {
      if (messages != null && messages.isNotEmpty)
        return Container(
          child: RaisedButton(
            onPressed: () {
              //forward etc can be here
            },
            padding: EdgeInsets.all(10),
            child: Container(
              width: 300,
              child: Flex(direction: Axis.vertical, children: <Widget>[
                Text(
                  messages[index].messageContent.toString(),
                  style: TextStyle(color: Colors.white),
                )
              ]),
            ),
            color: messages[index].messageFrom == Requests.currUserName
                ? Colors.blue[700]
                : Colors.blueGrey[700],
          ),
          width: 300,
          alignment: messages[index].messageFrom == Requests.currUserName
              ? Alignment.centerRight
              : Alignment.centerLeft,
        );
    } catch (e) {
      return SizedBox();
    }
  }

  _checkUpdates() {
    Requests().getMessages(username).then((value) {
      print('MESSAGES: ' + value.toString());
      if (messages == null || messages.isEmpty) {
        if (messages == null) messages = [];
        messages = List.from(value);
      }
      if (messages.last.messageDate != value.last.messageDate) {
        messages = List.from(value);
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
      }
      setState(() {});
    });
  }
}
