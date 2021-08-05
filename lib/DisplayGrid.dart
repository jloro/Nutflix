import 'package:Nutarr/DisplayGridObject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:developer' as developer;
import 'Movie.dart';

class DisplayGrid extends StatefulWidget {
  final Stream<List<DisplayGridObject>> fetchMovies;
  final Stream<String> getSizeDisk;
  final void Function(BuildContext context, DisplayGridObject object) onTap;
  final String title;

  DisplayGrid({ @required this.title, @required this.onTap, @required this.fetchMovies, @required this.getSizeDisk, Key key }) : super(key: key);

  @override
  _DisplayGridState createState() => _DisplayGridState();
}

class _DisplayGridState extends State<DisplayGrid> {
  @override
  void initState() {
    super.initState();
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
                          stream: this.widget.getSizeDisk,
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
              stream : this.widget.fetchMovies,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return  GridView.builder(
                      itemCount: snapshot.data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                          childAspectRatio: 2 / 3,
                          crossAxisCount: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height > 1 ? 5 : 3
                      ),
                      itemBuilder: (context, i) {
                        DisplayGridObject object = snapshot.data[i];
                        Color circleColor = Colors.white;
                        if (object.status == Status.Downloaded)
                          circleColor = Colors.green;
                        else if (object.status == Status.Queued)
                          circleColor = Colors.purple;
                        else if (object.status == Status.Missing)
                          circleColor = Colors.yellow;

                        return Container(
                            child : InkWell(
                              onLongPress: () {

                              },
                                onTap: () {
                                  this.widget.onTap(context, object);
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
                                              )
                                          )
                                      ),
                                      child: SizedBox(
                                          child: FadeInImage.memoryNetwork(
                                            fadeInDuration: Duration(milliseconds: 400),
                                            placeholder: kTransparentImage,
                                            fit: BoxFit.cover,
                                            image: object.GetPoster(),
                                          )
                                      )
                                  ),
                                )
                            )
                        );
                      }
                  );
                } else if (snapshot.hasError) {
                  return SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: Text("${snapshot.error}")
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