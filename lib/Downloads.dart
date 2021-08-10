import 'dart:async';
import 'dart:convert';
import 'DownloadNotif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'PlayerPrefs.dart';
import 'DisplayGrid/DisplayGridObject.dart';
import 'DownloadObject.dart';

Future<List<DownloadObject>> fetchDownloads() async {
  String url = PlayerPrefs.sabURL, apiKey = PlayerPrefs.sabApiKey;

  if (PlayerPrefs.sabURL == null || PlayerPrefs.sabURL == "")
    return Future.error('No sabnzbd URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sabApiKey == null || PlayerPrefs.sabApiKey == "")
    return Future.error('No sabnzbd api key specified, go to settings to specified it.');

  dynamic response = await http.get(
      '$url/api?mode=queue&apikey=$apiKey&output=json');

  List<DownloadObject> ret = List<DownloadObject>.empty(growable: true);
  if (response.statusCode == 200) {
    Map<String, dynamic> map = json.decode(response.body);

    response = await http.get(
        '$url/api?mode=history&apikey=$apiKey&output=json');

    for (dynamic obj in map['queue']['slots'])
      ret.add(DownloadObject(obj: obj, inQueue: true));

    if (response.statusCode == 200) {
      map = json.decode(response.body);
      for (dynamic obj in map['history']['slots'])
      {
        if (obj['action_line'] != "" || obj['status'] == 'Queued')
          ret.add(DownloadObject(obj: obj, inQueue: false));
      }
      return ret;
    } else {
      throw Exception('Failed to load Downloads, check your sabnzbd settings.');
    }
  } else {
    throw Exception('Failed to load Downloads, check your sabnzbd settings.');
  }
}

Future<String> fetchSpeed() async {
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
  Stream<String> _streamSpeed;
  Stream<List<DownloadObject>> _streamDownloads;

  @override
  void initState() {
    super.initState();
    _streamSpeed = CustomStream<String>(fetchSpeed).distinct();
    _streamDownloads = CustomStream<List<DownloadObject>>(fetchDownloads).distinct(DownloadObject.Compare);
  }

  void retryStream() {
    setState(() {
      _streamSpeed = CustomStream<String>(fetchSpeed).distinct();
      _streamDownloads = CustomStream<List<DownloadObject>>(fetchDownloads).distinct(DownloadObject.Compare);
    });
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
                  child: StreamBuilder<String>(
                    initialData: '0 bps',
                    stream: _streamSpeed,
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
        body: StreamBuilder<List<DownloadObject>>(
            initialData: [],
            stream: _streamDownloads,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return CircularProgressIndicator();

              if (snapshot.hasData) {
                if (snapshot.data.length == 0) return Text('No Downloads');
                else {
                  // this.widget.barKey.currentState.updateDownloads(snapshot.data.length);
                  return ListView.separated(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      separatorBuilder: (BuildContext context, int index) =>
                          Container(height: 10,),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, i) {
                        DownloadObject obj = snapshot.data[i];
                        return Container(
                            decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .bottomAppBarColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(obj.GetMovienameClean(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,)),
                              obj.inQueue ? Stack(
                                children: <Widget>[
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('${obj.GetPercentage()}%',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: obj.GetPercentage() == "0"
                                                  ? Colors.orange
                                                  : Colors.blue))),
                                  LinearPercentIndicator(
                                    padding: EdgeInsets.only(left: 20),
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.8,
                                    lineHeight: 14.0,
                                    percent: double.parse(obj.GetPercentage()) /
                                        100.0,
                                    backgroundColor: Colors.grey,
                                    progressColor: Colors.blue,
                                  )
                                ],
                              ) : Text(obj.GetActionLine()),
                              obj.inQueue ? Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Stack(
                                    children: <Widget>[
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${(double.parse(obj.GetMb()) /
                                                  1000 - double.parse(
                                                  obj.GetMbLeft()) / 1000)
                                                  .toStringAsFixed(1)} / ${obj
                                                  .GetSize()}')),
                                      Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              'Time left: ${obj
                                                  .GetTimeLeft()}'))
                                    ],
                                  )) : Container()
                            ]));
                      });
                }
              } else if (snapshot.hasError) {
                return Container(
                    child: Column(
                        children: [
                          Text("${snapshot.error}"),
                          IconButton(onPressed: retryStream, icon: Icon(Icons.refresh))
                        ]
                    )
                );
              }
              // By default, show a loading spinner.
              return CircularProgressIndicator();
            }));
  }
}
