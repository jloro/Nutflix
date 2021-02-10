import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Movie.dart';
import 'PlayerPrefs.dart';

void DeleteMovie(Movie movie) async {
  var response = await http.get('https://nutflix.fr/radarr/api/v3/queue',
      headers: {
        HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'
      });

  if (response.statusCode == 200) {
    if (movie.GetStatus(json.decode(response.body)) == Status.Queued) {
      List<dynamic> list = json.decode(response.body)['records'];
      if (list.length == 0) return;
      int id = list
          .firstWhere((element) => element['movieId'] == movie.GetId())['id'];
      response = await http.delete(
          'https://nutflix.fr/radarr/api/v3/queue/$id?removeFromClient=true',
          headers: {
            HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'
          });
      if (response.statusCode == 200) {
        response = await http.delete(
            'https://nutflix.fr/radarr/api/v3/movie/${movie.GetId()}?deleteFiles=true',
            headers: {
              HttpHeaders.authorizationHeader:
                  'aaaedca659fa4206bc50153292ba6da2'
            });
        developer.log(response.body);
        return;
      } else {
        throw Exception('Failed to delete movie');
      }
    } else {
      response = await http.delete(
          'https://nutflix.fr/radarr/api/v3/movie/${movie.GetId()}?deleteFiles=true',
          headers: {
            HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'
          });
      developer.log(response.body);
    }
  } else {
    throw Exception('Failed to load queue');
  }
}

class InfoMovie extends StatefulWidget {
  static const String route = '/movies/info';

  @override
  _InfoMovieState createState() => _InfoMovieState();
}

class _InfoMovieState extends State<InfoMovie> {
  bool _statsForNerdsState = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _statsForNerdsState = (prefs.getBool(PlayerPrefs.statsForNerds) ?? false);
    });
  }

  showAlertDialog(BuildContext context, Movie movie) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("no uwu"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("VI"),
      onPressed: () {
        DeleteMovie(movie);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Supprimer"),
      content: Text("T sur frr ?"),
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

  @override
  Widget build(BuildContext context) {
    final Movie movie = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(title: Text('Infos')),
        body: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                movie.GetTitle(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  movie.GetOverview(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: ElevatedButton(
                    child: Text('Supprimer'),
                    onPressed: () {
                      showAlertDialog(context, movie);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red[900]),
                    ))),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: _statsForNerdsState
                    ? Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Filename:${movie.GetMovieFileName()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Size: ${(movie.GetMovieSize() * 0.000000001).toStringAsFixed(2)} GB'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Quality: ${movie.GetQualityName()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Quality Source: ${movie.GetQualitySource()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Resolution: ${movie.GetQualityResolution().toString()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Audio Bitrate: ${(movie.GetAudioBitrate() * 0.000001).toStringAsFixed(2)} MB'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Audio channels: ${movie.GetAudioChannels().toString()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Audio codec: ${movie.GetAudioCodec()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Languages: ${movie.GetAudioLanguages()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Video Bit Depth: ${movie.GetVideoBitDepth().toString()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Video Bitrate: ${(movie.GetVideoBitrate() * 0.000001).toStringAsFixed(2)} MB'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Video codec: ${movie.GetVideoCodec()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Fps: ${movie.GetVideoFps().toString()}'),
                          )
                        ],
                      )
                    : Container())
          ],
        ));
  }
}
