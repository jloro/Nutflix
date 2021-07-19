import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Movie.dart';
import 'PlayerPrefs.dart';
import 'Show.dart';

Future<void> MonitorSeason(Show show, int nb, bool state) async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;
  if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
    return Future.error(
        'No sonarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
    return Future.error(
        'No sonarr api key specified, go to settings to specified it.');

  show.obj['seasons'][nb]['monitored'] = state;
  var response = await http.put('$url/api/v3/series/${show.GetId()}',
      headers: {HttpHeaders.authorizationHeader: apiKey},
      body: show.ToJson());

  if (response.statusCode == 202) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    if (state) {
      response = await http.post('$url/api/v3/command',
          headers: {HttpHeaders.authorizationHeader: apiKey},
          body: json.encode({
            'name': 'SeriesSearch',
            'seriesId': show.GetId()
          }));
    }
    return;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Series, check sonarr settings.');
  }
}

void DeleteAllShow(Show show) async {
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

class Episode extends StatelessWidget {
  final dynamic episode;
  MaterialColor circleColor;

  showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        title: Text(
            'S${episode['seasonNumber']}E${episode['episodeNumber']} ${episode['title']}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${episode['overview']}'),
          SizedBox(
            height: 10,
          ),
          Text('Aired on ${episode['airDateUtc']}'),
        ]));

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Episode({Key key, this.episode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (episode['airDateUtc'] != null && DateTime.now().compareTo(DateTime.parse(episode['airDateUtc'])) < 0)
      circleColor = Colors.blue;
    else if (!episode['monitored'])
      circleColor = Colors.yellow;
    else if (!episode['hasFile'])
      circleColor = Colors.purple;
    else
      circleColor = Colors.green;
    return InkWell(
        onTap: () {
          showAlertDialog(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Expanded(
              child: Text('${episode['episodeNumber']}.  ${episode['title']}'),
            ),
            Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
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
            )
          ]),
        ));
  }
}

class Season extends StatefulWidget {
  final int nb;
  final int sizeOnDisk;
  final Show show;

  Season({Key key, this.nb, this.sizeOnDisk, this.show}) : super(key: key);

  @override
  _SeasonState createState() => _SeasonState();
}

class _SeasonState extends State<Season> {
  bool _expanded = false;
  List<Widget> episodes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    episodes = List<Widget>();
    for (int i = 0; i < this.widget.show.GetStatPerSeason(this.widget.nb)['totalEpisodeCount']; i++) {
      episodes.add(
          Episode(episode: this.widget.show.GetEpisode(this.widget.nb, i + 1)));
    }
    return InkWell(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
        child: Container(
            child: Padding(
          padding: EdgeInsets.only(left: 10, top: 20, bottom: 20, right: 10),
          child: Column(children: [
            Row(children: [
              Flexible(
                  flex: 3,
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: 'Season ${this.widget.nb}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            '  ${this.widget.show.GetStatPerSeason(this.widget.nb)['episodeFileCount']} / ${this.widget.show.GetStatPerSeason(this.widget.nb)['episodeCount']}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w200)),
                    TextSpan(
                        text:
                            '   ${(this.widget.sizeOnDisk * 0.000000001).toStringAsFixed(2)} GB',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w100)),
                  ]))),
              Flexible(
                  child: Align(
                alignment: Alignment.center,
                child: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white, size: 20),
              )),
              Flexible(
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: (){
                        MonitorSeason(this.widget.show, this.widget.nb, !this.widget.show.GetIfSeasonMonitored(this.widget.nb));
                      },
                        icon: Icon(this.widget.show.GetIfSeasonMonitored(this.widget.nb) ? Icons.bookmark : Icons.bookmark_outline,
                        color: Colors.white, size: 20)),
                  ))
            ]),
            _expanded
                ? Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: episodes))
                : Container()
          ]),
        )));
  }
}

class _InfoShowState extends State<InfoShow> {
  MaterialColor circleColor;
  String state;
  Future<List<Widget>> _fetchEpisodes;

  @override
  void initState() {
    _fetchEpisodes = fetchEpisodes();
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

  Future<void> fetchShow() async {
    String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;
    if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
      return Future.error(
          'No sonarr URL specified, go to settings to specified it.');
    else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
      return Future.error(
          'No sonarr api key specified, go to settings to specified it.');

    var response = await http.get('$url/api/v3/series/${this.widget.show.GetId()}',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      Map<String, dynamic> obj = json.decode(response.body);
      this.widget.show = Show(obj: obj);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Series, check sonarr settings.');
    }
  }

  Future<List<Widget>> fetchEpisodes() async {
    String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;
    if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
      return Future.error(
          'No sonarr URL specified, go to settings to specified it.');
    else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
      return Future.error(
          'No sonarr api key specified, go to settings to specified it.');

    var response = await http.get('$url/api/v3/episode?seriesId=${this.widget.show.GetId()}',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      List<dynamic> list = json.decode(response.body);
      List<Widget> seasons = List<Widget>();
      this.widget.show.episodes = list;
      this.widget.show.hasFetchedEpisodes = true;
      for (int i in Iterable.generate(this.widget.show.GetNbSeasons())) {
        seasons.add(Season(
            nb: i + 1,
            sizeOnDisk: this.widget.show.GetStatPerSeason(i + 1)['sizeOnDisk'],
            show: this.widget.show));
        seasons.add(Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: SizedBox(
              height: 1,
              child: Container(color: Colors.black),
            )));
      }
      return seasons;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Series, check sonarr settings.');
    }
  }

  Future<void> _refreshWidget() => Future.delayed(Duration(seconds: 1), () async {
    await fetchShow();
    setState(() {
      _fetchEpisodes = fetchEpisodes();
    });
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Infos')),
        body: RefreshIndicator(
          displacement: 30,
          onRefresh:_refreshWidget,
            child: ListView(
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
                              ))
                        ],
                      ),
                    ),
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
            FutureBuilder<List<Widget>>(
                future: _fetchEpisodes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: snapshot.data);
                  } else if (snapshot.hasError) {
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        child: Text("${snapshot.error}"));
                  }
                  return CircularProgressIndicator();
                })
          ],
        )));
  }
}
