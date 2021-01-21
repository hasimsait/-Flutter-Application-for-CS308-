import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
    for (int i = 0; i < userNames.length; i++) {
      try {
        var user = userNames[i];
        User thisUser = User(user);
        thisUser = await thisUser.getInfo();
        temp.insert(
          i,
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile(user)),
              );
            },
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            color: Colors.transparent,
            child: Card(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          Image.memory(base64Decode(thisUser.myProfilePicture))
                              .image),
                  Column(
                    children: <Widget>[
                      Text(
                        user,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 20,),
                      ),
                      Text(
                        commonConnectionCounts[i].toString() +
                            ' common connections',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 12.4,),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  Padding(padding: EdgeInsets.all(1.75))
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              elevation: 0,
            ),
          ),
        );
      } catch (e) {
        print('RECOMMENDATIONS.DART: A USER FUCKED UP WHILE LISTING');
      }
    }
    listing = Container(
        child: ListView(
          children: temp,
          scrollDirection: Axis.horizontal,
        ),
        color: Colors.blue);
    setState(() {});
  }
}
