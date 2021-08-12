import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:Nutarr/routes.dart';
import 'DisplayGrid/DisplayGridObject.dart';
import 'DisplayGrid/DisplayGrid.dart';
import 'DisplayGrid/DisplayGridStream.dart';
import 'InfoShow/InfoShow.dart';

Future<List<DisplayGridObject>> fetchSeries() async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;
  if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
    return Future.error('No sonarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
    return Future.error('No sonarr api key specified, go to settings to specified it.');

  var response = await http.get('$url/api/v3/series',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    List<dynamic> list = json.decode(response.body);
    response = await http.get('$url/api/v3/queue',
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });
    if (response.statusCode == 200) {
      List<DisplayGridObject> series = List<DisplayGridObject>();
      for (int i = 0; i < list.length; i++) {
        DisplayGridObject show = DisplayGridObject(type: Type.TVShow, obj: list[i]);
        show.status = show.GetStatus(json.decode(response.body));
        series.add(show);
      }
      series.sort((a, b) => DateTime.parse(b.GetAdded()).compareTo(DateTime.parse(a.GetAdded())));
      return series;
    } else {
      throw Exception('Failed to load queue');
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Series, check sonarr settings.');
  }
}

Future<String> GetDiskSizeLeft() async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

  if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
    return Future.error('No radarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
    return Future.error('No radarr api key specified, go to settings to specified it.');

  var response = await http.get('$url/api/v3/rootfolder',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    List<dynamic> list = json.decode(response.body);
    int spaceLeft;
    if (PlayerPrefs.sonarrDlPath == null || PlayerPrefs.sonarrDlPath == "")
      spaceLeft = list[0]['freeSpace'];
    else
      spaceLeft = list[list.indexWhere((element) => element['path'] == PlayerPrefs.sonarrDlPath)]['freeSpace'];
    return '${(spaceLeft * 0.000000001).round()} GB left';
    // If the server did return a 200 OK response,
    // then parse the JSON.
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}

class Series extends StatefulWidget {
  static const String route = '/series';
  static const int index = 1;
  //final SharedPreferences prefs;

  Series({ Key key }) : super(key: key);

  @override
  _SeriesState createState() => _SeriesState();
}

class _SeriesState extends State<Series> {
  Stream<List<DisplayGridObject>> _streamSeries;
  Stream<String> _streamSizeDisk;

  @override
  void initState() {
    _streamSeries = CustomStream<List<DisplayGridObject>>(fetchSeries).distinct(DisplayGridObject.Compare);
    _streamSizeDisk = CustomStream(GetDiskSizeLeft).distinct();
    super.initState();
  }

  Stream<List<DisplayGridObject>> onErrorFetchSeries() {
    _streamSeries = CustomStream<List<DisplayGridObject>>(fetchSeries).distinct(DisplayGridObject.Compare);
    return _streamSeries;
  }

  Stream<String> onErrorGetSizeDisk() {
    _streamSizeDisk = CustomStream(GetDiskSizeLeft).distinct();
    return _streamSizeDisk;
  }

  @override
  Widget build(BuildContext context) {
    return DisplayGridStream(
      onTap: (BuildContext context, DisplayGridObject object) {
          Navigator.pushNamed(context, Routes.infoShow, arguments: object.ToShow());
      },
      fetchObjects: _streamSeries,
      getSizeDisk: _streamSizeDisk,
      title: 'Series',
      onErrorFetchObjects: onErrorFetchSeries,
      onErrorGetSizeDisk: onErrorGetSizeDisk,
    );
  }
}