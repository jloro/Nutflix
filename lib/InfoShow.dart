import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Movie.dart';
import 'PlayerPrefs.dart';
import 'Show.dart';

void DeleteAllShow(Show show) async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

  var response = await http.get('$url/api/v3/queue',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    if (show.GetStatus(json.decode(response.body)) == Status.Queued) {
      List<dynamic> list = json.decode(response.body)['records'];
      if (list.length == 0) return;
      int id = list
          .firstWhere((element) => element['seriesId'] == show.GetId())['id'];
      response = await http.delete(
          '$url/api/v3/queue/$id?removeFromClient=true',
          headers: {
            HttpHeaders.authorizationHeader: apiKey
          });
      if (response.statusCode == 200) {
        response = await http.delete(
            '$url/api/v3/series/${show.GetId()}?deleteFiles=true',
            headers: {
              HttpHeaders.authorizationHeader: apiKey
            });
        return;
      } else {
        throw Exception('Failed to delete movie');
      }
    } else {
      response = await http.delete(
          '$url/api/v3/series/${show.GetId()}?deleteFiles=true',
          headers: {
            HttpHeaders.authorizationHeader: apiKey
          });
    }
  } else {
    throw Exception('Failed to load queue');
  }
}

class InfoShow extends StatefulWidget {
  static const String route = '/series/info';

  final Show show;

  InfoShow({Key key, this.show}) : super(key: key);

  @override
  _InfoShowState createState() => _InfoShowState();
}

class Season extends StatelessWidget {
  final int nb;
  final int sizeOnDisk;

  Season({Key key, this.nb, this.sizeOnDisk}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
          children: [Flexible(child:RichText(
            text: TextSpan(children: [
              TextSpan(text:'Season $nb',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextSpan(text:'   ${(sizeOnDisk * 0.000000001).toStringAsFixed(2)} GB',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w100)),
            ])
        )),
        Flexible(child:Align(
          alignment: Alignment.centerRight,
          child:Icon(Icons.expand_more,
            color: Colors.white,
            size: 20),))
        ])),
    );
  }

}

class _InfoShowState extends State<InfoShow> {
  MaterialColor circleColor;
  String state;
  List<Widget> seasons = new List<Widget>();

  @override
  void initState() {
    if (this.widget.show.status == Status.Downloaded) {
      circleColor = Colors.green;
      state = "Downloaded";
    } else if (this.widget.show.status == Status.Queued) {
      circleColor = Colors.purple;
      state = "Queued";
    } else if (this.widget.show.status == Status.Missing) {
      circleColor = Colors.yellow;
      state = "Missing";
    }
    for (int i in Iterable.generate(this.widget.show.GetNbSeasons())) {
      seasons.add(Season(nb: i + 1, sizeOnDisk: this.widget.show.GetStatPerSeason(i + 1)['sizeOnDisk'],));
      seasons.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(height: 1,child: Container(color: Colors.black),))
      );
    }
    super.initState();
  }

  showAlertDialog(BuildContext context, Show show) {
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
        DeleteAllShow(show);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete all episodes"),
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
                            image: NetworkImage(this.widget.show.GetFanart()),
                            fit: BoxFit.cover)))),
            Align(
              alignment: Alignment.center,
              child: Text(
                this.widget.show.GetTitle(),
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
                          'duree: ${(this.widget.show.GetRuntime() / 60).floor()}h${(this.widget.show.GetRuntime() % 60).toString().padLeft(2, '0')}',
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
                  'genres: ${this.widget.show.GetGenres().join(', ')}',
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
                  this.widget.show.GetOverview(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, ),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: ElevatedButton(
                    child: Text('Delete all episodes'),
                    onPressed: () {
                      showAlertDialog(context, this.widget.show);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red[900]),
                    ))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: seasons,)
            // Container(
            //     padding: EdgeInsets.only(right: 10, left: 10, bottom: 20),
            //     child: PlayerPrefs.statsForNerds && this.widget.movie.status == Status.Downloaded
            //         ? Column(
            //       children: <Widget>[
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text('Filename:${this.widget.movie.GetMovieFileName()}'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text(
            //               'Size: ${(this.widget.movie.GetMovieSize() * 0.000000001).toStringAsFixed(2)} GB'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text('Quality: ${this.widget.movie.GetQualityName()}'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text(
            //               'Quality Source: ${this.widget.movie.GetQualitySource()}'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text(
            //               'Resolution: ${this.widget.movie.GetQualityResolution().toString()}'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text(
            //               'Audio Bitrate: ${(this.widget.movie.GetAudioBitrate() * 0.000001).toStringAsFixed(2)} MB'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text(
            //               'Audio channels: ${this.widget.movie.GetAudioChannels().toString()}'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child:
            //           Text('Audio codec: ${this.widget.movie.GetAudioCodec()}'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child:
            //           Text('Languages: ${this.widget.movie.GetAudioLanguages()}'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text(
            //               'Video Bit Depth: ${this.widget.movie.GetVideoBitDepth().toString()}'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text(
            //               'Video Bitrate: ${(this.widget.movie.GetVideoBitrate() * 0.000001).toStringAsFixed(2)} MB'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child:
            //           Text('Video codec: ${this.widget.movie.GetVideoCodec()}'),
            //         ),
            //         Align(
            //           alignment: Alignment.centerLeft,
            //           child:
            //           Text('Fps: ${this.widget.movie.GetVideoFps().toString()}'),
            //         )
            //       ],
            //     )
            //         : Container())
          ],
        ));
  }
}
