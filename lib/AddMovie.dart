import 'dart:convert';
import 'dart:io';

import 'package:Nutarr/AddObject.dart';
import 'package:Nutarr/DisplayGridObject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Movie.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:Nutarr/routes.dart';

Future<bool> AddRadarrMovie(DisplayGridObject movie, bool ultrahd, BuildContext context) async {
  String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

  var response = await http.post('$url/api/v3/movie',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      },
      body: movie.movie.ToJson(ultrahd));

  if (response.statusCode == 201) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> obj = json.decode(response.body);
    response = await http.post('$url/api/v3/command',
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        },
        body: json.encode({
          'name': 'MoviesSearch',
          'movieIds': [obj['id']]
        }));
    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to start movie');
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    String msg = "Failed to load movie";
    if (json.decode(response.body)[0]["errorMessage"] == "Invalid Path")
      msg = "Invalid Path, check your settings";
    else
      msg = json.decode(response.body)[0]["errorMessage"];
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
          duration: Duration(seconds: 1),
          content: Text(msg),
          backgroundColor: Colors.red),
    );
    return false;
  }
}

Future<bool> HasMovie(DisplayGridObject movie) async {
  String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

  final response = await http.get('$url/api/v3/movie',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> list = json.decode(response.body);
    for (int i = 0; i < list.length; i++) {
      Movie tmp = Movie(obj: list[i]);
      if (tmp.GetIMDBId() == movie.GetIMDBId()) return true;
    }
    return false;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}

class AddMovie extends StatefulWidget {
  static const String route = '/search/addmovie';
  //final SharedPreferences prefs;
  final DisplayGridObject movie;

  AddMovie({ Key key , this.movie}) : super(key: key);

  @override
  _AddMovieState createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  @override
  Widget build(BuildContext context) {
    return AddObject(object: this.widget.movie, hasObject: HasMovie, addObject: AddRadarrMovie);
  }
}