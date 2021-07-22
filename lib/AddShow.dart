import 'dart:convert';
import 'dart:io';

import 'package:Nutarr/AddObject.dart';
import 'package:Nutarr/DisplayGridObject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Nutarr/Drawer.dart';
import 'package:intl/intl.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Movie.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:Nutarr/routes.dart';

import 'Show.dart';

Future<bool> AddSonarrShow(DisplayGridObject show, bool ultrahd, BuildContext context) async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

  List<dynamic> seasons = List<dynamic>();
  for (int i in Iterable.generate(show.show.GetNbSeasons()))
    seasons.add({'seasonNumber': i + 1, 'monitored': false});

  var response = await http.post('$url/api/v3/series',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      },
      body: jsonEncode({'tvdbId': show.show.GetTVDBId(), 'title': show.GetTitle(), 'QualityProfileId' : 1,
        'titleSlug' : show.show.GetTitleSlug(), 'images': show.obj['images'], 'seasons': seasons,
        'LanguageProfileId': 1, 'Path': '/home/jules/Videos/${show.GetTitle()}', 'monitored': true}));

  if (response.statusCode == 201) {
    return true;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    String msg = "Failed to load show";
    print(response.body);
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

Future<bool> HasShow(DisplayGridObject show) async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

  final response = await http.get('$url/api/v3/series',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> list = json.decode(response.body);
    for (int i = 0; i < list.length; i++) {
      Show tmp = Show(obj: list[i]);
      if (tmp.GetIMDBId() == show.GetIMDBId()) return true;
    }
    return false;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}

class AddShow extends StatefulWidget {
  static const String route = '/search/addshow';
  //final SharedPreferences prefs;
  final DisplayGridObject show;

  AddShow({ Key key , this.show}) : super(key: key);

  @override
  _AddShowState createState() => _AddShowState();
}

class _AddShowState extends State<AddShow> {
  @override
  Widget build(BuildContext context) {
    return AddObject(object: this.widget.show, hasObject: HasShow, addObject: AddSonarrShow);
  }
}