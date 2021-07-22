import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:Nutarr/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:developer' as developer;
import 'DisplayGridObject.dart';
import 'Movie.dart';
import 'DisplayGrid.dart';

Future<List<DisplayGridObject>> fetchMovies() async {
  String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;
  if (PlayerPrefs.radarrURL == null || PlayerPrefs.radarrURL == "")
    return Future.error('No radarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.radarrApiKey == null || PlayerPrefs.radarrApiKey == "")
    return Future.error('No radarr api key specified, go to settings to specified it.');

  var response = await http.get('$url/api/v3/movie',
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
      List<DisplayGridObject> movies = List<DisplayGridObject>();
      for (int i = 0; i < list.length; i++) {
        DisplayGridObject movie = DisplayGridObject(type: Type.Movie, obj: list[i]);
        movie.status = movie.GetStatus(json.decode(response.body));
        movies.add(movie);
      }
      movies.sort((a, b) => DateTime.parse(b.GetAdded()).compareTo(DateTime.parse(a.GetAdded())));
      return movies;
    } else {
      throw Exception('Failed to load queue');
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movies, check radarr settings.');
  }
}

Future<String> GetDiskSizeLeft() async
{
  String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

  if (PlayerPrefs.radarrURL == null || PlayerPrefs.radarrURL == "")
    return Future.error('No radarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.radarrApiKey == null || PlayerPrefs.radarrApiKey == "")
    return Future.error('No radarr api key specified, go to settings to specified it.');

  var response = await http.get('$url/api/v3/rootfolder',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    List<dynamic> list = json.decode(response.body);
    int spaceLeft;
    if (PlayerPrefs.radarrDlPath == null || PlayerPrefs.radarrDlPath == "")
      spaceLeft = list[0]['freeSpace'];
    else
      spaceLeft = list[list.indexWhere((element) => element['path'] == PlayerPrefs.radarrDlPath)]['freeSpace'];
    return '${(spaceLeft * 0.000000001).round()} GB left';
    // If the server did return a 200 OK response,
    // then parse the JSON.
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}
class Movies extends StatefulWidget {
  static const String route = '/movies';
  static const int index = 0;
  //final SharedPreferences prefs;

  Movies({ Key key }) : super(key: key);

  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  @override
  Widget build(BuildContext context) {
    return DisplayGrid(
        onTap: (BuildContext context, DisplayGridObject object) {
          if (object.type == Type.Movie)
            Navigator.pushNamed(context, Routes.infoMovie, arguments: object.ToMovie());
    }, fetchMovies: fetchMovies, getSizeDisk: GetDiskSizeLeft, title: 'Movies',);
  }

}