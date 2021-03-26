import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;

import 'BottomNavigationBar.dart';
import 'Movie.dart';
import 'PlayerPrefs.dart';
import 'dart:developer' as developer;

Future<List<dynamic>> FetchDownloads() async {
  if (PlayerPrefs.sabURL == null || PlayerPrefs.sabURL == "")
    throw Exception('No sabnzbd URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sabApiKey == null || PlayerPrefs.sabApiKey == "")
    throw Exception('No sabnzbd api key specified, go to settings to specified it.');

  final response = await http.get(
      '${PlayerPrefs.sabURL}/api?mode=queue&apikey=${PlayerPrefs.sabApiKey}&output=json');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> map = json.decode(response.body);
    return map['queue']['slots'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Downloads, check your sabnzbd settings.');
  }
}

Future<String> FetchSpeed() async {
  final response = await http.get(
      '${PlayerPrefs.sabURL}/api?mode=queue&apikey=${PlayerPrefs.sabApiKey}&output=json');

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
  static const int index = 2;
  final GlobalKey<MyBottomNavigationBarState> barKey;

  Downloads({this.barKey});

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
                    return Text('${snapshot.data}/s');
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
                _length = snapshot.data.length;
                if (snapshot.data.length > 0)
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, i) {
                        dynamic movie = snapshot.data[i];
                        RegExp exp = RegExp(r"^((?:(?: ?.* )+)(?:\ ?\d+ ))(?: ?.* )*\d*p");
                        Iterable<RegExpMatch> matches = exp.allMatches(movie['filename'].toString().replaceAll('.', ' ').replaceAll(RegExp(' +'), ' '));
                        String movieName = matches.length > 0 && matches.first.groupCount > 0 ? matches.first.group(1) : movie['filename'];
                        // developer.log();
                        return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(movieName)),
                              Stack(
                                children: <Widget>[
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('${movie['percentage']}%')),
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
                              ),
                              Stack(
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
                              )
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
