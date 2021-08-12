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
import 'InfoMovie.dart';

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
      // print('return movies');
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
  } else {
    throw Exception('Failed to load Movie');
  }
}
class Movies extends StatefulWidget {
  static const String route = '/movies';
  static const int index = 0;

  Movies({ Key key }) : super(key: key);

  @override
  _MoviesState createState() => _MoviesState();
}

showAlertDialog(BuildContext context, DisplayGridObject movie) {
  // set up the buttons
  Widget cancelButton = ElevatedButton(
    child: Text("No"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = ElevatedButton(
    child: Text("Yes"),
    onPressed: () {
      DeleteMovie(movie.movie);
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text('Do you want to delete ${movie.GetTitle()}'),
    // content: Text('Do you want to delete ${movie.GetTitle()}'),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class _MoviesState extends State<Movies> {

  Stream<List<DisplayGridObject>> _streamMovies;
  Stream<String> _streamSizeDisk;

  @override
  void initState() {
    _streamMovies = CustomStream<List<DisplayGridObject>>(fetchMovies).distinct(DisplayGridObject.Compare);
    _streamSizeDisk = CustomStream(GetDiskSizeLeft).distinct();
    super.initState();
  }

  Stream<List<DisplayGridObject>> onErrorFetchMovies() {
    _streamMovies = CustomStream<List<DisplayGridObject>>(fetchMovies).distinct(DisplayGridObject.Compare);
    return _streamMovies;
  }

  Stream<String> onErrorGetSizeDisk() {
    _streamSizeDisk = CustomStream(GetDiskSizeLeft).distinct();
    return _streamSizeDisk;
  }

  @override
  Widget build(BuildContext context) {
    return DisplayGridStream(
      onTap: (BuildContext context, DisplayGridObject object) {
        if (object.type == Type.Movie)
          Navigator.pushNamed(context, Routes.infoMovie, arguments: object.ToMovie());
      },
      fetchObjects: _streamMovies,
      getSizeDisk: _streamSizeDisk,
      title: 'Movies',
      onErrorFetchObjects: onErrorFetchMovies,
      onErrorGetSizeDisk: onErrorGetSizeDisk,
    );
  }

}