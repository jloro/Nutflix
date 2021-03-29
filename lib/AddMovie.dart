import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Nutarr/Drawer.dart';
import 'package:intl/intl.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Movie.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

Future<bool> AddRadarrMovie(Movie movie, bool ultrahd, BuildContext context) async {
  var response = await http.post('${PlayerPrefs.radarrURL}/api/v3/movie',
      headers: {
        HttpHeaders.authorizationHeader: PlayerPrefs.radarrApiKey
      },
      body: movie.ToJson(ultrahd));

  if (response.statusCode == 201) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> obj = json.decode(response.body);
    response = await http.post('${PlayerPrefs.radarrURL}/api/v3/command',
        headers: {
          HttpHeaders.authorizationHeader: PlayerPrefs.radarrApiKey
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
    developer.log(response.body.toString());
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

Future<bool> HasMovie(Movie movie) async {
  final response = await http.get('${PlayerPrefs.radarrURL}/api/v3/movie',
      headers: {
        HttpHeaders.authorizationHeader: PlayerPrefs.radarrApiKey
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
  final Movie movie;

  AddMovie({@required this.movie});

  @override
  _AddMovieState createState() => new _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  bool addIsInactive;
  Future<bool> _hasmovie;

  @override
  void initState() {
    addIsInactive = false;
    _hasmovie = HasMovie(this.widget.movie);
  }

  void Function(bool) addOnPressed;

  void _OnTapAdd(bool ultrahd) async {
    setState(() {
      addIsInactive = true;
      addOnPressed = null;
    });
    bool ret = await AddRadarrMovie(this.widget.movie, ultrahd, context);
    if (!ret)
    {
      developer.log('error');
      setState(() {
        addIsInactive = false;
        addOnPressed = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add')),
        body: Column(children: <Widget>[
          Expanded(
              child: Container(
                  height: 200,
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: EdgeInsets.only(bottom: 20, left: 5),
                          child: Stack(
                            children: <Widget>[
                              Text(this.widget.movie.GetTitle(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = Colors.black)),
                              Text(
                                this.widget.movie.GetTitle(),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )
                            ],
                          ))),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(this.widget.movie.GetFanart()),
                          fit: BoxFit.cover)))),
          Expanded(
              child: Container(
            height: 200,
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: 200,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Image.network(this.widget.movie.GetPoster()),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: <Widget>[
                      Text(new DateFormat()
                          .add_yMMMd()
                          .format(DateTime.parse(this.widget.movie.GetRelease()))),
                      Flexible(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Movies',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final url =
                                'https://www.imdb.com/title/${this.widget.movie.GetIMDBId()}';
                            if (await canLaunch(url))
                              await launch(url);
                            else
                              throw "Could not launch $url";
                          },
                          child: const Text('IMDB',
                              style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: FutureBuilder<bool>(
                      future: _hasmovie,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.hasData) {
                          developer.log('${snapshot.data} $addOnPressed');
                          if (!snapshot.data && addOnPressed == null && !addIsInactive) {
                            addIsInactive = false;
                            addOnPressed = _OnTapAdd;
                          } else {
                            addIsInactive = true;
                          }
                          return Column(
                            children: <Widget>[
                              Text('Rating : ${this.widget.movie.GetRating()}'),
                              Flexible(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed:
                                      addIsInactive ? null : () { addOnPressed(false);} ,
                                  child: const Text('Add',
                                      style: TextStyle(fontSize: 20)),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: addIsInactive ? null : () { addOnPressed(true);},
                                  child: const Text('Add in 4k',
                                      style: TextStyle(fontSize: 20)),
                                ),
                              )
                            ],
                          );
                        } else {
                          return UnconstrainedBox(
                              child: CircularProgressIndicator());
                        }
                      },
                    ))
              ],
            ),
          )),
          Expanded(
              flex: 3,
              child: Container(
                child: Text(this.widget.movie.GetOverview()),
              ))
        ]));
  }
}
