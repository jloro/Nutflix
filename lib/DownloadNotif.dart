import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'DisplayGrid/DisplayGridObject.dart';
import 'PlayerPrefs.dart';

Future<int> fetchDownloads() async {
  String url = PlayerPrefs.sabURL, apiKey = PlayerPrefs.sabApiKey;

  if (PlayerPrefs.sabURL == null || PlayerPrefs.sabURL == "")
    return Future.error('No sabnzbd URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sabApiKey == null || PlayerPrefs.sabApiKey == "")
    return Future.error('No sabnzbd api key specified, go to settings to specified it.');

  dynamic response = await http.get(
      '$url/api?mode=queue&apikey=$apiKey&output=json');

  int ret = 0;
  if (response.statusCode == 200) {
    Map<String, dynamic> map = json.decode(response.body);

    response = await http.get(
        '$url/api?mode=history&apikey=$apiKey&output=json');

    ret += map['queue']['slots'].length;

    if (response.statusCode == 200) {
      map = json.decode(response.body);
      for (dynamic obj in map['history']['slots'])
      {
        if (obj['action_line'] != ""|| obj['status'] == 'Queued')
          ret++;
      }
      return ret;
    } else {
      throw Exception('Failed to load Downloads, check your sabnzbd settings.');
    }
  } else {
    throw Exception('Failed to load Downloads, check your sabnzbd settings.');
  }
}

class DownloadNotif extends StatefulWidget {

  DownloadNotif({Key key}) : super(key:key);
  @override
  DownloadNotifState createState() => DownloadNotifState();
}

class DownloadNotifState extends State<DownloadNotif> {

  Stream<int> _streamNotif;

  @override
  void initState() {
    _streamNotif = CustomStream<int>(fetchDownloads).distinct();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _streamNotif,
      initialData: 0,
      builder: (cxt, snapshot) {
        int downloads = 0;
        if (snapshot.hasData) {
          downloads = snapshot.data;
        }
        return Stack(
          children: <Widget>[
            Icon(Icons.get_app),
            downloads == 0
                ? UnconstrainedBox()
                : Positioned(
              right: 0,
              child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child:Text(
                    '$downloads',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  )
              ),
            )
          ],
        );
      },
    );
  }
}
