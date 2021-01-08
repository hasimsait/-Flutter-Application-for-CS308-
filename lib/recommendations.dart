import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:teamone_social_media/profile.dart';
import 'package:teamone_social_media/user.dart';


class Recommendations extends StatefulWidget {
  final List<String> userNames;
  final List<String> commonConnectionCounts;
  Recommendations({this.userNames, this.commonConnectionCounts});
  @override
  State<StatefulWidget> createState() =>
      _RecommendationState(this.userNames, this.commonConnectionCounts);
}

class _RecommendationState extends State<Recommendations> {
  final List<String> userNames;
  final List<String> commonConnectionCounts;
  _RecommendationState(this.userNames, this.commonConnectionCounts);

  Widget listing = Text('Please wait while we retrieve recommendations');
  @override
  void initState() {
    _listUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: listing,
      ),
    );
  }

  Future<void> _listUsers() async {
    listing = Text('Please wait while we retrieve recommendations');
    setState(() {});
    List<Widget> temp = [];
    temp.insert(0,Text('Who to follow?',style: TextStyle(fontSize: 25),));
    for (int i = 0; i < userNames.length; i++) {
      try {
        var user = userNames[i];
        User thisUser = User(user);
        thisUser = await thisUser.getInfo();
        temp.insert(
            i+1,
            Row(children: <Widget>[
              IconButton(
                iconSize: 35,
                icon: CircleAvatar(
                    radius: 35,
                    backgroundImage:
                        Image.memory(base64Decode(thisUser.myProfilePicture))
                            .image),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile(user)),
                  );
                },
              ),
              Column(
                children: <Widget>[
                  Text(
                    user,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    commonConnectionCounts[i].toString()+' common connections.',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
        );
      } catch (Exception) {
        print('DYNAMIC WIDGET LIST.DART: A USER FUCKED UP WHILE LISTING');
      }
    }
    listing = Column(children: temp,crossAxisAlignment: CrossAxisAlignment.center,mainAxisSize: MainAxisSize.min);
    setState(() {});
  }
}
