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

  DisplayGridCard({this.object, this.onTap, this.onDelete, this.deleting, this.setState, Key key}) : super(key: key);

  @override
  _DisplayGridCardState createState() => _DisplayGridCardState();
}

class _DisplayGridCardState extends State<DisplayGridCard> {
  Color circleColor = Colors.white;
  Future<void> _futureDelete;
  String _id;
  bool _deleting;

  @override
  void initState() {
    _id = this.widget.object.GetIMDBId();
    _deleting = this.widget.deleting;
    super.initState();
  }

  void preBuild() {
    if (_id != this.widget.object.GetIMDBId()) {
      _id = this.widget.object.GetIMDBId();
      _deleting = this.widget.deleting;
    }

    if (this.widget.deleting && !_deleting)
      _deleting = true;

    if (this.widget.object.status == Status.Downloaded)
      circleColor = Colors.green;
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

  @override
  Widget build(BuildContext context) {
    preBuild();
    return Container(
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
            if (snapshot.hasError){
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
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            color: Color.fromARGB(210, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 0,
                                  child:
                                  CircularProgressIndicator(color: Colors.white),
                                ),
                                Center(child: Text('Deleting...'))
                              ],
                            ))));
          },
        ),
      ),
    ]));
  }
}
