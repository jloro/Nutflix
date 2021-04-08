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
  String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

  if (PlayerPrefs.demo)
  {
    apiKey = "aaaedca659fa4206bc50153292ba6da2";
    url = "https://nutflix.fr/radarr";
  }

  var response = await http.get('$url/api/v3/queue',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    if (movie.GetStatus(json.decode(response.body)) == Status.Queued) {
      List<dynamic> list = json.decode(response.body)['records'];
      if (list.length == 0) return;
      int id = list
          .firstWhere((element) => element['movieId'] == movie.GetId())['id'];
      response = await http.delete(
          '$url/api/v3/queue/$id?removeFromClient=true',
          headers: {
            HttpHeaders.authorizationHeader: apiKey
          });
      if (response.statusCode == 200) {
        response = await http.delete(
            '$url/api/v3/movie/${movie.GetId()}?deleteFiles=true',
            headers: {
              HttpHeaders.authorizationHeader: apiKey
            });
        return;
      } else {
        throw Exception('Failed to delete movie');
      }
    } else {
      response = await http.delete(
          '$url/api/v3/movie/${movie.GetId()}?deleteFiles=true',
          headers: {
            HttpHeaders.authorizationHeader: apiKey
          });
    }
  } else {
    throw Exception('Failed to load queue');
  }
}

class InfoMovie extends StatefulWidget {
  static const String route = '/movies/info';

  final Movie movie;

  InfoMovie({Key key, this.movie}) : super(key: key);

  @override
  _InfoMovieState createState() => _InfoMovieState();
}

class _InfoMovieState extends State<InfoMovie> {
  MaterialColor circleColor;
  String state;

  @override
  void initState() {
    if (this.widget.movie.status == Status.Downloaded) {
      circleColor = Colors.green;
      state = "Downloaded";
    } else if (this.widget.movie.status == Status.Queued) {
      circleColor = Colors.purple;
      state = "Queued";
    } else if (this.widget.movie.status == Status.Missing) {
      circleColor = Colors.yellow;
      state = "Missing";
    }
    super.initState();
  }

  showAlertDialog(BuildContext context, Movie movie) {
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
        DeleteMovie(movie);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Are you sure ?"),
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
    return Scaffold(
        appBar: AppBar(title: Text('Infos')),
        body: ListView(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(this.widget.movie.GetFanart()),
                            fit: BoxFit.cover)))),
            Align(
              alignment: Alignment.center,
              child: Text(
                this.widget.movie.GetTitle(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Stack(
              children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'duree: ${(this.widget.movie.GetRuntime() / 60).floor()}h${(this.widget.movie.GetRuntime() % 60).toString().padLeft(2, '0')}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: TextStyle(fontSize: 15, color: Colors.white),
                          text: '$state ',
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Stack(
                            children: [
                              Icon(
                                Icons.circle,
                                color: circleColor,
                                size: 16,
                              ),
                            Icon(
                              Icons.panorama_fish_eye_outlined,
                              color: Colors.black,
                              size: 16,
                              ),
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                ),
              ])
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'genres: ${this.widget.movie.GetGenres().join(', ')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  this.widget.movie.GetOverview(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, ),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: ElevatedButton(
                    child: Text('Delete'),
                    onPressed: () {
                      showAlertDialog(context, this.widget.movie);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red[900]),
                    ))),
            Container(
                padding: EdgeInsets.only(right: 10, left: 10, bottom: 20),
                child: PlayerPrefs.statsForNerds && this.widget.movie.status == Status.Downloaded
                    ? Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Filename:${this.widget.movie.GetMovieFileName()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Size: ${(this.widget.movie.GetMovieSize() * 0.000000001).toStringAsFixed(2)} GB'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Quality: ${this.widget.movie.GetQualityName()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Quality Source: ${this.widget.movie.GetQualitySource()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Resolution: ${this.widget.movie.GetQualityResolution().toString()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Audio Bitrate: ${(this.widget.movie.GetAudioBitrate() * 0.000001).toStringAsFixed(2)} MB'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Audio channels: ${this.widget.movie.GetAudioChannels().toString()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Audio codec: ${this.widget.movie.GetAudioCodec()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Languages: ${this.widget.movie.GetAudioLanguages()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Video Bit Depth: ${this.widget.movie.GetVideoBitDepth().toString()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Video Bitrate: ${(this.widget.movie.GetVideoBitrate() * 0.000001).toStringAsFixed(2)} MB'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Video codec: ${this.widget.movie.GetVideoCodec()}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Fps: ${this.widget.movie.GetVideoFps().toString()}'),
                          )
                        ],
                      )
                    : Container())
          ],
        ));
  }
}
