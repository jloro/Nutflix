// import 'dart:html';
import 'dart:math';

import 'package:Nutarr/InfoShow/InfoShow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../InfoMovie.dart';
import '../Movie.dart';
import 'DisplayGridObject.dart';

class DisplayGridCard extends StatefulWidget {
  final DisplayGridObject object;
  final void Function(BuildContext context, DisplayGridObject object) onTap;
  final bool deleting;
  final void Function(String) onDelete;
  final void Function() setState;

  DisplayGridCard(
      {this.object,
      this.onTap,
      this.onDelete,
      this.deleting,
      this.setState,
      Key key})
      : super(key: key);

  @override
  _DisplayGridCardState createState() => _DisplayGridCardState();
}

class _DisplayGridCardState extends State<DisplayGridCard> with SingleTickerProviderStateMixin {
  Color circleColor = Colors.white;
  Future<void> _futureDelete;
  String _id;
  bool _deleting;
  bool _front;
  bool _inAnim;

  @override
  void initState() {
    _id = this.widget.object.GetIMDBId();
    _deleting = this.widget.deleting;
    _front = true;
    _inAnim = false;
    super.initState();
  }

  void preBuild() {
    if (_id != this.widget.object.GetIMDBId()) {
      _id = this.widget.object.GetIMDBId();
      _deleting = this.widget.deleting;
      _front = true;
    }

    if (this.widget.deleting && !_deleting) _deleting = true;

    if (this.widget.object.type == Type.Movie && this.widget.object.status == Status.Downloaded)
      circleColor = Colors.green;
    else if (this.widget.object.type == Type.TVShow && this.widget.object.status == Status.Downloaded && this.widget.object.show.GetEnded())
      circleColor = Colors.green;
    else if (this.widget.object.type == Type.TVShow && this.widget.object.status == Status.Downloaded && !this.widget.object.show.GetEnded())
      circleColor = Colors.blue;
    else if (this.widget.object.status == Status.Queued)
      circleColor = Colors.purple;
    else if (this.widget.object.status == Status.Missing)
      circleColor = Colors.yellow;
  }

  showAlertDialogDelete(BuildContext context, DisplayGridObject object) {
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
        this.widget.onDelete(object.GetIMDBId());
        if (object.GetIMDBId() == _id) {
          setState(() {
            _deleting = true;
            if (object.type == Type.TVShow)
              _futureDelete = DeleteAllShow(object.show);
            else
              _futureDelete = DeleteMovie(object.movie);
          });
        } else {
          this.widget.setState();
          if (object.type == Type.TVShow)
            DeleteAllShow(object.show);
          else
            DeleteMovie(object.movie);
        }
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Do you want to delete ${object.GetTitle()}"),
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

  Widget _buildFront(BuildContext context) {
    return Container(
        key: ValueKey(true),
        child: Stack(children: [
          InkWell(
              onLongPress: () {
                showAlertDialogDelete(context, this.widget.object);
              },
              onTap: () {
                this.widget.onTap(context, this.widget.object);
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                semanticContainer: true,
                elevation: 5,
                child: GridTile(
                    footer: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                            padding: EdgeInsets.all(5),
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
                            ))),
                    child: SizedBox(
                        child: FadeInImage.memoryNetwork(
                      fadeInDuration: Duration(milliseconds: 400),
                      placeholder: kTransparentImage,
                      fit: BoxFit.cover,
                      image: this.widget.object.GetPoster(),
                    ))),
              )),
          Visibility(
            visible: _deleting,
            child: FutureBuilder(
              future: _futureDelete,
              builder: (cxt, snapshot) {
                if (snapshot.hasError) {
                  final scaffold = ScaffoldMessenger.of(context);
                  scaffold.showSnackBar(
                    SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text('Error removing movie'),
                        backgroundColor: Colors.red),
                  );
                  return Container();
                }
                return Card(
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    semanticContainer: true,
                    elevation: 0,
                    child: GridTile(
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            color: Color.fromARGB(210, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 0,
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                                Center(child: Text('Deleting...'))
                              ],
                            ))));
              },
            ),
          ),
        ]));
  }

  String _getTime() {
    if (this.widget.object.type == Type.TVShow) {
      return '  ${this.widget.object.show.GetNbSeasons()} x ${this.widget.object.show.GetStatPerSeason(1)['totalEpisodeCount']}  ${(this.widget.object.GetRuntime() / 60).floor()}h${(this.widget.object.GetRuntime() % 60).toString().padLeft(2, '0')}';
    } else
      return '  ${(this.widget.object.GetRuntime() / 60).floor()}h${(this.widget.object.GetRuntime() % 60).toString().padLeft(2, '0')}';
  }

  String _getEpisodeFileCount() {
    int i = 0;
    for (int j in Iterable.generate(this.widget.object.show.GetNbSeasons())) {
      i += this.widget.object.show.GetStatPerSeason(j + 1)['episodeFileCount'];
    }
    return '  ${i.toString()}';
  }

  Widget _buildBack(BuildContext context) {
    return Stack(
      key: ValueKey(false),
      children: [
        Container(
            child: Card(
              clipBehavior: Clip.antiAlias,
              semanticContainer: true,
              child: GridTile(
                  footer: Container(),
                  child: SizedBox(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: FadeInImage.memoryNetwork(
                    fadeInDuration: Duration(milliseconds: 400),
                    placeholder: kTransparentImage,
                    fit: BoxFit.cover,
                    image: this.widget.object.GetPoster(),
                  ),
                      ))),
            )),
        Card(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            semanticContainer: true,
            elevation: 0,
            child: GridTile(
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    color: Color.fromARGB(210, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: FittedBox(
                          child: Container(
                            alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment:
                                        PlaceholderAlignment.middle,
                                        child: Icon(Icons.timer,
                                            color: Colors.white),
                                      ),
                                      TextSpan(text: _getTime()),
                                    ]
                                ),
                              )
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment:
                                      PlaceholderAlignment.middle,
                                      child: Icon(Icons.calendar_today,
                                          color: Colors.white),
                                    ),
                                    TextSpan(text: '  ${this.widget.object.GetYear()}'),
                                  ]
                              ),
                            )
                        ),
                      ),
                      Flexible(
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment:
                                      PlaceholderAlignment.middle,
                                      child: Icon(Icons.star,
                                          color: Colors.white),
                                    ),
                                    TextSpan(text: '  ${this.widget.object.GetRating()}'),
                                  ]
                              ),
                            )
                        ),
                      ),
                      Visibility(
                        visible: this.widget.object.type == Type.Movie,
                        child: Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                              child: FittedBox(
                                child: Text('${this.widget.object.GetGenres().join(', ')}',
                                  textAlign: TextAlign.center,
                                ),
                              )
                          ),
                        ),
                      ),
                      if (this.widget.object.type == Type.TVShow)
                        Flexible(
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment:
                                        PlaceholderAlignment.middle,
                                        child: Icon(Icons.download,
                                            color: Colors.white),
                                      ),
                                      TextSpan(text: _getEpisodeFileCount()),
                                    ]
                                ),
                              )
                          ),
                        ),
                    ]
                  )
                    )))
      ],
    );
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final end = 0.0;
    final rotateAnim = Tween(begin: pi, end: end).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(_front) != widget.key);
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        if (rotateAnim.value == end)
          _inAnim = false;
        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    preBuild();
    return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != 0 && !_inAnim) {
            setState(() {
              _inAnim = true;
              _front = !_front;
            });
          }
        },
        child: AnimatedSwitcher(
            layoutBuilder: (widget, list) => Stack(children: [widget, ...list]),
            transitionBuilder: _transitionBuilder,
            duration: Duration(milliseconds: 400),
            child: _front ? _buildFront(context) : _buildBack(context)));
  }
}