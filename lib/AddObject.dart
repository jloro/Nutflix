import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'DisplayGrid/DisplayGridObject.dart';

class AddObject extends StatefulWidget {
  final DisplayGridObject object;
  final Future<bool> Function(DisplayGridObject object) hasObject;
  final Future<bool> Function(DisplayGridObject object, bool ultrahd, BuildContext context) addObject;

  AddObject({@required this.object, @required this.hasObject, @required this.addObject});

  @override
  _AddObjectState createState() => new _AddObjectState();
}

class _AddObjectState extends State<AddObject> {
  bool addIsInactive;
  Future<bool> _hasmovie;

  @override
  void initState() {
    addIsInactive = false;
    setState(() {
      _hasmovie = this.widget.hasObject(this.widget.object);
    });
  }

  void Function(bool) addOnPressed;

  void _OnTapAdd(bool ultrahd) async {
    setState(() {
      addIsInactive = true;
      addOnPressed = null;
    });
    bool ret = await this.widget.addObject(this.widget.object, ultrahd, context);
    if (!ret)
    {
      print('error');
      setState(() {
        addIsInactive = false;
        addOnPressed = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add')),
        body: Column(children: <Widget>[
          Expanded(
              child: Container(
                  height: 200,
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: EdgeInsets.only(bottom: 20, left: 5),
                          child: Stack(
                            children: <Widget>[
                              Text(this.widget.object.GetTitle(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = Colors.black)),
                              Text(
                                this.widget.object.GetTitle(),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )
                            ],
                          ))),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(this.widget.object.GetFanart()),
                          fit: BoxFit.cover)))),
          Expanded(
              child: Container(
                height: 200,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: Image.network(this.widget.object.GetPoster()),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          this.widget.object.type == Type.Movie ? Text(new DateFormat()
                              .add_yMMMd()
                              .format(DateTime.parse(this.widget.object.movie.GetRelease())))
                          : Text('${this.widget.object.show.GetNbSeasons()} Seasons : ${this.widget.object.show.GetShowStatus()}'),
                          Flexible(
                              flex: 2,
                              child: Container(
                                height: 20,
                              )
                          ),
                          Flexible(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                final url =
                                    'https://www.imdb.com/title/${this.widget.object.GetIMDBId()}';
                                if (await canLaunch(url))
                                  await launch(url);
                                else
                                  throw "Could not launch $url";
                              },
                              child: const Text('IMDB',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 3,
                        child: FutureBuilder<bool>(
                          future: _hasmovie,
                          builder:
                              (BuildContext context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.hasData) {
                              if (!snapshot.data && addOnPressed == null && !addIsInactive) {
                                addIsInactive = false;
                                addOnPressed = _OnTapAdd;
                              } else {
                                addIsInactive = true;
                              }
                              return Column(
                                children: <Widget>[
                                  Text('Rating : ${this.widget.object.GetRating()}'),
                                  Flexible(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed:
                                      addIsInactive ? null : () { addOnPressed(false);} ,
                                      child: const Text('Add',
                                          style: TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: addIsInactive ? null : () { addOnPressed(true);},
                                      child: const Text('Add in 4k',
                                          style: TextStyle(fontSize: 20)),
                                    ),
                                  )
                                ],
                              );
                            } else {
                              return UnconstrainedBox(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ))
                  ],
                ),
              )),
          Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(this.widget.object.GetOverview()),
              ))
        ]));
  }
}
