import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:Nutarr/InfoShow/SeasonWidget.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'EpisodesObject.dart';
import '../Movie.dart';
import '../PlayerPrefs.dart';
import '../Show.dart';
import '../DisplayGrid/DisplayGridObject.dart';
import 'EpisodeWidget.dart';

Stream<Status> streamStatus(int id) async* {
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    Status ret = await fetchStatus(id);
    yield ret;
  }
}

Future<Status> fetchStatus(int seriesId) async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;
  if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
    return Future.error('No sonarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
    return Future.error('No sonarr api key specified, go to settings to specified it.');

  var response = await http.get('$url/api/v3/series/$seriesId',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });
  Map<String, dynamic> obj = json.decode(response.body);

  if (response.statusCode == 200) {
    DisplayGridObject show = DisplayGridObject(type: Type.TVShow, obj: obj);
    response = await http.get('$url/api/v3/queue',
        headers: {
          HttpHeaders.authorizationHeader: apiKey
        });
    if (response.statusCode == 200) {
      return show.GetStatus(json.decode(response.body));
    }
  } else {
    throw Exception('Failed to load Series, check sonarr settings.');
  }
}

Future<void> DeleteAllShow(Show show) async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

  var response = await http.get('$url/api/v3/queue',
      headers: {HttpHeaders.authorizationHeader: apiKey});

  if (response.statusCode == 200) {
    if (show.GetStatus(json.decode(response.body)) == Status.Queued) {
      List<dynamic> list = json.decode(response.body)['records'];
      if (list.length == 0) return;
      int id = list
          .firstWhere((element) => element['seriesId'] == show.GetId())['id'];
      response = await http.delete(
          '$url/api/v3/queue/$id?removeFromClient=true',
          headers: {HttpHeaders.authorizationHeader: apiKey});
      if (response.statusCode == 200) {
        response = await http.delete(
            '$url/api/v3/series/${show.GetId()}?deleteFiles=true',
            headers: {HttpHeaders.authorizationHeader: apiKey});
        return;
      } else {
        throw Exception('Failed to delete movie');
      }
    } else {
      response = await http.delete(
          '$url/api/v3/series/${show.GetId()}?deleteFiles=true',
          headers: {HttpHeaders.authorizationHeader: apiKey});
    }
  } else {
    throw Exception('Failed to load queue');
  }
}

class InfoShow extends StatefulWidget {
  static const String route = '/series/info';

  Show show;

  InfoShow({Key key, this.show}) : super(key: key);

  @override
  _InfoShowState createState() => _InfoShowState();
}

class _InfoShowState extends State<InfoShow> {
  Stream<Status> _streamStatus;
  Stream<Episodes> _streamEpisodes;
  Stream<Show> _streamShow;

  @override
  void initState() {
    _streamStatus = streamStatus(this.widget.show.GetId()).distinct().asBroadcastStream();
    _streamEpisodes = CustomStream<Episodes>(fetchEpisodes).distinct().asBroadcastStream();
    _streamShow = CustomStream<Show>(fetchShow).distinct().asBroadcastStream();
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

  Future<Show> fetchShow() async {
    String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;
    if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
      return Future.error(
          'No sonarr URL specified, go to settings to specified it.');
    else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
      return Future.error(
          'No sonarr api key specified, go to settings to specified it.');

    var response = await http.get(
        '$url/api/v3/series/${this.widget.show.GetId()}',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      Map<String, dynamic> obj = json.decode(response.body);
      return Show(obj: obj);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Series, check sonarr settings.');
    }
  }

  Future<Episodes> fetchEpisodes() async {
    String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;
    if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
      return Future.error(
          'No sonarr URL specified, go to settings to specified it.');
    else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
      return Future.error(
          'No sonarr api key specified, go to settings to specified it.');

    var response = await http.get(
        '$url/api/v3/episode?seriesId=${this.widget.show.GetId()}',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      dynamic eps = json.decode(response.body);
      response = await http.get(
          '$url/api/v3/queue?pageSize=50',
          headers: {HttpHeaders.authorizationHeader: apiKey});

      if (response.statusCode == 200){
        Episodes ret = Episodes(obj: eps, queue: json.decode(response.body)['records']);
        return ret;
      }else{
        throw Exception('Failed to load queue sonarr, check sonarr settings.');
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Series, check sonarr settings.');
    }
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
                                image:
                                    NetworkImage(this.widget.show.GetFanart()),
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
                    child: Stack(children: <Widget>[
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
                        child: StreamBuilder<Status>(
                          initialData: this.widget.show.status,
                          stream: _streamStatus,
                          builder: (cxt, snapshot){
                            Status state = Status.Missing;
                            String stateStr;
                            MaterialColor circleColor;
                            if (snapshot.hasData){
                              state = snapshot.data;
                            }
                            if (state == Status.Downloaded && this.widget.show.GetEnded()) {
                              circleColor = Colors.green;
                              stateStr = "Downloaded";
                            }else if (state == Status.Downloaded && !this.widget.show.GetEnded()){
                              circleColor = Colors.blue;
                              stateStr = "Airing";
                            } else if (state == Status.Queued) {
                              circleColor = Colors.purple;
                              stateStr = "Queued";
                            } else if (state == Status.Missing) {
                              circleColor = Colors.yellow;
                              stateStr = "Missing";
                            }

                            return RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                    text: '$stateStr ',
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
                                      ))
                                ],
                              ),
                            );
                          },
                        )
                      ),
                    ])),
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
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                // Padding(
                //     padding: EdgeInsets.only(top: 20, bottom: 20),
                //     child: ElevatedButton(
                //         child: Text('Delete all episodes'),
                //         onPressed: () {
                //           showAlertDialog(context, this.widget.show);
                //         },
                //         style: ButtonStyle(
                //           backgroundColor:
                //               MaterialStateProperty.all<Color>(Colors.red[900]),
                //         ))),
                FutureBuilder<Episodes>(
                    future: fetchEpisodes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Widget> seasons = List.empty(growable: true);
                        for (int i in Iterable.generate(this.widget.show.GetNbSeasons())) {
                          seasons.add(SeasonWidget(
                              nb: i + 1,
                              show: this.widget.show,
                              episodes: snapshot.data,
                          streamShow: _streamShow,
                          streamEpisodes: _streamEpisodes,));
                          seasons.add(Padding(
                              padding: EdgeInsets.symmetric(vertical: 0),
                              child: SizedBox(
                                height: 1,
                                child: Container(color: Colors.black),
                              )));
                        }
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: seasons);
                      } else if (snapshot.hasError) {
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            child: Text("${snapshot.error}"));
                      }
                      return CircularProgressIndicator();
                    })
              ],
            ));
  }
}
