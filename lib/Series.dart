import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:Nutarr/Drawer.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:Nutarr/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:developer' as developer;
import 'DisplayGridObject.dart';
import 'Movie.dart';
import 'DisplayGrid.dart';

Future<List<DisplayGridObject>> fetchSeries() async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;
  if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
    return Future.error('No sonarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
    return Future.error('No sonarr api key specified, go to settings to specified it.');
  else if (PlayerPrefs.demo)
  {
    apiKey = "aaaedca659fa4206bc50153292ba6da2";
    url = "https://nutflix.fr/radarr";
  }

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

Future<String> GetDiskSizeLeft() async
{
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

  if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
    return Future.error('No radarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
    return Future.error('No radarr api key specified, go to settings to specified it.');
  else if (PlayerPrefs.demo)
  {
    apiKey = "aaaedca659fa4206bc50153292ba6da2";
    url = "https://nutflix.fr/radarr";
  }

  var response = await http.get('$url/api/v3/rootfolder',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    List<dynamic> list = json.decode(response.body);
    int spaceLeft;
    if (PlayerPrefs.dlPath == null || PlayerPrefs.dlPath == "")
      spaceLeft = list[0]['freeSpace'];
    else
      spaceLeft = list[list.indexWhere((element) => element['path'] == PlayerPrefs.dlPath)]['freeSpace'];
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
  @override
  Widget build(BuildContext context) {
    return DisplayGrid(
        onTap: (BuildContext context, DisplayGridObject object) {
            Navigator.pushNamed(context, Routes.infoShow, arguments: object.ToShow());
        }, fetchMovies: fetchSeries, getSizeDisk: GetDiskSizeLeft, title: 'Series');
  }

}