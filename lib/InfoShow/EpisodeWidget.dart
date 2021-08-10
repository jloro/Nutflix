import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'EpisodesObject.dart';

class EpisodeWidget extends StatefulWidget {
  Episodes episodes;
  final int season;
  final int nb;
  final Stream<Episodes> streamEpisodes;

  EpisodeWidget({Key key, this.episodes, this.season, this.nb, this.streamEpisodes}) : super(key: key);

  @override
  _EpisodeWidgetState createState() => _EpisodeWidgetState();

}

class _EpisodeWidgetState extends State<EpisodeWidget> {
  MaterialColor circleColor;
  dynamic episode;
  StreamSubscription _subscription;

  showAlertDialog(BuildContext context) {
    var date = episode['airDateUtc'] == null ? null : DateTime.tryParse(episode['airDateUtc']);
    var dateStr;
    if (date != null)
      dateStr = DateFormat('yyyy-MM-dd – kk:mm').format(date);
    else
      dateStr = date;

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        title: Text(
            'S${episode['seasonNumber']}E${episode['episodeNumber']} ${episode['title']}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${ episode['overview'] ?? '¯\\_(ツ)_/¯'}'),
          SizedBox(
            height: 10,
          ),
          Text('Aired on ${ dateStr ?? '¯\\_(ツ)_/¯'}'),
        ]));

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _Init() {
    if (episode['airDateUtc'] != null &&
        DateTime.now().compareTo(DateTime.parse(episode['airDateUtc'])) < 0)
      circleColor = Colors.blue;
    else if (!episode['monitored'])
      circleColor = Colors.yellow;
    else if (this.widget.episodes.queue.where((element) => element['episodeId'] == episode['id']).isNotEmpty)
      circleColor = Colors.purple;
    else if (episode['hasFile'])
      circleColor = Colors.green;
    else
      circleColor = Colors.yellow;
  }

  @override
  void initState() {
    _subscription = this.widget.streamEpisodes.listen((event) {
      this.widget.episodes = event;
      dynamic newEp = this.widget.episodes.GetEpisode(this.widget.season, this.widget.nb);
      if (newEp.toString() != episode.toString()) {
        episode = newEp;
        setState(() {
          _Init();
        });
      }
    });
    episode = this.widget.episodes.GetEpisode(this.widget.season, this.widget.nb);
    _Init();
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    )))
          ]),
        ));
  }
}
