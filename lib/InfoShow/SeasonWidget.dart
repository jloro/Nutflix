import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../EpisodesObject.dart';
import '../PlayerPrefs.dart';
import '../Show.dart';
import 'EpisodeWidget.dart';
import 'package:http/http.dart' as http;

void DeleteSeason(Episodes episodes, int nb, BuildContext cxt) async {
  String baseUrl = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

  final url = Uri.parse(baseUrl + "/api/v3/episodeFile/bulk");
  final request = http.Request("DELETE", url);
  request.headers
      .addAll(<String, String>{HttpHeaders.authorizationHeader: apiKey});

  request.body = jsonEncode({
    "episodeFileIds": episodes.obj
        .where((element) =>
    element['seasonNumber'] == nb && element['episodeFileId'] != 0)
        .map<int>((e) => e['episodeFileId'] as int)
        .toList()
  });
  final response = await request.send();
  if (response.statusCode != 200) {
    String txt = (await response.stream.bytesToString()).substring(0, 20);
    final scaffold = ScaffoldMessenger.of(cxt);
    scaffold.showSnackBar(
      SnackBar(
          duration: Duration(seconds: 1),
          content: Text('${response.reasonPhrase} : $txt'),
          backgroundColor: Colors.red),
    );
  }
}

Future<void> MonitorSeason(Show show, int nb, bool state) async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;
  if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
    return Future.error(
        'No sonarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
    return Future.error(
        'No sonarr api key specified, go to settings to specified it.');

  List<dynamic> seasons = show.obj['seasons'];
  for (int i = 0; i < seasons.length; i++)
    if (seasons[i]['seasonNumber'] == nb)
      show.obj['seasons'][i]['monitored'] = state;

  var response = await http.put('$url/api/v3/series/${show.GetId()}',
      headers: {HttpHeaders.authorizationHeader: apiKey}, body: jsonEncode(show.obj));

  if (response.statusCode == 202) {
    if (state) {
      response = await http.post('$url/api/v3/command',
          headers: {HttpHeaders.authorizationHeader: apiKey},
          body:
          json.encode({'name': 'SeriesSearch', 'seriesId': show.GetId()}));
    }
    return;
  } else {
    throw Exception('Failed to load Series, check sonarr settings.');
  }
}

class SeasonWidget extends StatefulWidget {
  final int nb;
  Show show;
  Episodes episodes;
  final Stream<Show> streamShow;
  final Stream<Episodes> streamEpisodes;

  SeasonWidget({Key key, this.nb, this.show, this.episodes, this.streamShow, this.streamEpisodes}) : super(key: key);

  @override
  _SeasonState createState() => _SeasonState();
}

class _SeasonState extends State<SeasonWidget> {
  bool _expanded = false;
  StreamSubscription _subscriptionStreamShow;
  StreamSubscription _subscriptionStreamEpisodes;
  List<Widget> episodes = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _subscriptionStreamShow = this.widget.streamShow.listen((event) {
      setState(() {
        this.widget.show = event;
      });
    });
    _subscriptionStreamEpisodes = this.widget.streamEpisodes.listen((event) {
      episodes.clear();

      this.widget.episodes = event;

      for (int i = 0; i < this.widget.show.GetStatPerSeason(this.widget.nb)['totalEpisodeCount']; i++) {
        episodes.add(EpisodeWidget(episodes: this.widget.episodes, season: this.widget.nb, nb: i + 1, streamEpisodes: this.widget.streamEpisodes,));
      }
    });
    for (int i = 0; i < this.widget.show.GetStatPerSeason(this.widget.nb)['totalEpisodeCount']; i++) {
      episodes.add(EpisodeWidget(episodes: this.widget.episodes, season: this.widget.nb, nb: i + 1, streamEpisodes: this.widget.streamEpisodes,));
    }
  }

  @override
  void dispose() {
    _subscriptionStreamShow?.cancel();
    _subscriptionStreamEpisodes?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Season ${this.widget.nb}',
                            style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextSpan(
                            text:
                            '  ${this.widget.show.GetStatPerSeason(this.widget.nb)['episodeFileCount']} / ${this.widget.show.GetStatPerSeason(this.widget.nb)['episodeCount']}',
                            style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
                        TextSpan(
                            text:
                            '   ${(this.widget.show.GetStatPerSeason(this.widget.nb)['sizeOnDisk'] * 0.000000001).toStringAsFixed(2)} GB',
                            style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.w100)),
                      ])),
                  Container(
                      child: Row(children: [
                        IconButton(
                            onPressed: () {
                              MonitorSeason(this.widget.show, this.widget.nb, !this.widget.show.GetIfSeasonMonitored(this.widget.nb));
                            },
                            icon: Icon(
                                this
                                    .widget
                                    .show
                                    .GetIfSeasonMonitored(this.widget.nb)
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
                                color: Colors.white,
                                size: 20)),
                        IconButton(
                            onPressed: this.widget.show.GetStatPerSeason(this.widget.nb)['episodeFileCount'] == 0 ? null
                            : () { DeleteSeason(this.widget.episodes, this.widget.nb, context); },
                            icon: Icon(Icons.delete, color: Colors.white, size: 20)),
                        Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.white, size: 20),
                      ])),
                ]),
                Visibility(
                  visible: _expanded,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: episodes)))
              ]),
            )));
  }
}