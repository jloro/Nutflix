import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Nutarr/DownloadNotif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;

import 'BottomNavigationBar.dart';
import 'Movie.dart';
import 'PlayerPrefs.dart';
import 'dart:developer' as developer;

Future<List<dynamic>> FetchDownloads() async {
  String url = PlayerPrefs.sabURL, apiKey = PlayerPrefs.sabApiKey;

  if (PlayerPrefs.sabURL == null || PlayerPrefs.sabURL == "")
    return Future.error('No sabnzbd URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sabApiKey == null || PlayerPrefs.sabApiKey == "")
    return Future.error('No sabnzbd api key specified, go to settings to specified it.');

  dynamic response = await http.get(
      '$url/api?mode=queue&apikey=$apiKey&output=json');

  List<dynamic> ret = List<dynamic>();
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> map = json.decode(response.body);

    response = await http.get(
        '$url/api?mode=history&apikey=$apiKey&output=json');

    ret.add(map['queue']['slots']);

    if (response.statusCode == 200) {
      map = json.decode(response.body);
      List<dynamic> toAdd = List<dynamic>();
      for (dynamic movie in map['history']['slots'])
      {
        if (movie['action_line'] != "")
          toAdd.add(movie);
      }
      ret.add(toAdd);
      return ret;
    } else {
      throw Exception('Failed to load Downloads, check your sabnzbd settings.');
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Downloads, check your sabnzbd settings.');
  }
}

Future<String> FetchSpeed() async {
  String url = PlayerPrefs.sabURL, apiKey = PlayerPrefs.sabApiKey;

  if (PlayerPrefs.sabURL == null || PlayerPrefs.sabURL == "")
    return Future.error('No sabnzbd URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sabApiKey == null || PlayerPrefs.sabApiKey == "")
    return Future.error('No sabnzbd api key specified, go to settings to specified it.');

  final response = await http.get(
      '$url/api?mode=queue&apikey=$apiKey&output=json');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> map = json.decode(response.body);
    return map['queue']['speed'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}

class Downloads extends StatefulWidget {
  static const String route = '/downloading';
  static const int index = 3;
  final GlobalKey<DownloadNotifState> barKey;

  Downloads({Key key, this.barKey}) : super(key: key);

  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  Timer timer;
  Future<List<dynamic>> _fetchDownloads;
  Future<String> _fetchSpeed;
  int _length = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      setState(() {
        _fetchDownloads = FetchDownloads();
        _fetchSpeed = FetchSpeed();
        this.widget.barKey.currentState.updateDownloads(_length);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(children: <Widget>[
            Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Downloads'),
                )),
            Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FutureBuilder<String>(
                    future: _fetchSpeed,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text('${snapshot.data}bps');
                      } else {
                        return Text('');
                      }
                    },
                  ),
                )),
          ]),
        ),
        body: FutureBuilder<List<dynamic>>(
            future: FetchDownloads(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _length = snapshot.data[0].length + snapshot.data[1].length;
                if (snapshot.data[0].length > 0 || snapshot.data[1].length > 0)
                  return ListView.separated(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      separatorBuilder: (BuildContext context, int index) => Container(height: 10,),
                      itemCount: snapshot.data[0].length + snapshot.data[1].length,
                      itemBuilder: (context, i) {
                        dynamic movie;
                        String name;
                        bool queue;
                        if (i < snapshot.data[0].length) {
                          movie = snapshot.data[0][i];
                          name = movie['filename'];
                          queue = true;
                        } else {
                          movie = snapshot.data[1][i - snapshot.data[0].length];
                          name = movie['name'];
                          queue = false;
                        }
                        RegExp exp = RegExp(r"^((?:(?: ?.* )+)(?:\ ?\d+ ))(?: ?.* )*\d*p");
                        Iterable<RegExpMatch> matches = exp.allMatches(name.replaceAll('.', ' ').replaceAll(RegExp(' +'), ' '));
                        String movieName = matches.length > 0 && matches.first.groupCount > 0 ? matches.first.group(1) : name;
                        return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).bottomAppBarColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(movieName, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,)),
                              queue ? Stack(
                                children: <Widget>[
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('${movie['percentage']}%', style: TextStyle(fontWeight: FontWeight.bold, color: movie['percentage'] == "0" ? Colors.orange : Colors.blue))),
                                  LinearPercentIndicator(
                                    padding: EdgeInsets.only(left: 20),
                                    width:
                                    MediaQuery.of(context).size.width * 0.8,
                                    lineHeight: 14.0,
                                    percent: double.parse(movie['percentage']) /
                                        100.0,
                                    backgroundColor: Colors.grey,
                                    progressColor: Colors.blue,
                                  )
                                ],
                              ) : Text(movie['action_line']),
                              queue ? Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Stack(
                                    children: <Widget>[
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${(double.parse(movie['mb']) / 1000 - double.parse(movie['mbleft']) / 1000).toStringAsFixed(1)} / ${movie['size']}')),
                                      Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              'Time left: ${movie['timeleft']}'))
                                    ],
                                  )) : Container()
                            ]));
                      });
                else
                  return Text('No Downloads');
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              return CircularProgressIndicator();
            }));
  }
}
