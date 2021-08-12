import 'dart:async';

import 'package:Nutarr/DisplayGrid/DisplayGrid.dart';
import 'package:Nutarr/DisplayGrid/DisplayGridCard.dart';
import 'package:Nutarr/DisplayGrid/DisplayGridObject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:developer' as developer;
import '../InfoMovie.dart';
import '../InfoShow/InfoShow.dart';
import '../Movie.dart';

class DisplayGridStream extends StatefulWidget {
  final Stream<List<DisplayGridObject>> fetchObjects;
  final Stream<String> getSizeDisk;
  final void Function(BuildContext context, DisplayGridObject object) onTap;
  final String title;
  final Stream<List<DisplayGridObject>> Function() onErrorFetchObjects;
  final Stream<String> Function() onErrorGetSizeDisk;

  DisplayGridStream({ @required this.title, @required this.onTap, @required this.fetchObjects, @required this.getSizeDisk, this.onErrorFetchObjects, this.onErrorGetSizeDisk, Key key }) : super(key: key);

  @override
  _DisplayGridStreamState createState() => _DisplayGridStreamState();
}

class _DisplayGridStreamState extends State<DisplayGridStream> {
  Timer timer;
  Stream<List<DisplayGridObject>> _streamObjects;
  Stream<String> _streamSizeDisk;

  @override
  void initState() {
    _streamObjects = this.widget.fetchObjects;
    _streamSizeDisk = this.widget.getSizeDisk;
    super.initState();
  }

  void retryStream() {
    setState(() {
      _streamObjects = this.widget.onErrorFetchObjects();
      _streamSizeDisk = this.widget.onErrorGetSizeDisk();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(this.widget.title),
                  ),
                ),
                Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: StreamBuilder<String>(
                        initialData: 'fetching...',
                        stream: _streamSizeDisk,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data);
                          } else {
                            return Text('');
                          }
                        },
                      ),
                    )
                )
              ],
            ),
          )
      ),
      body : StreamBuilder<List<DisplayGridObject>>(
          stream : _streamObjects,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            if (snapshot.hasData) {
              return DisplayGrid(
                snapshot: snapshot,
                onTap: this.widget.onTap,
              );
            } else if (snapshot.hasError) {
              return Container(
                  child: Column(
                      children: [
                        Text("${snapshot.error}"),
                        IconButton(onPressed: retryStream, icon: Icon(Icons.refresh))
                      ]
                  )
              );
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          }
      ),
    );
  }
}