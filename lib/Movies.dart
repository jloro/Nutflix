import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:nutflix/AppBar.dart';
import 'package:nutflix/Drawer.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:developer' as developer;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'Movie.dart';

Future<List<Movie>> fetchMovies() async {
  var response = await http.get('https://nutflix.fr/radarr/api/v3/movie',
      headers: {
        HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'
      });

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> list = json.decode(response.body);
    response = await http.get('https://nutflix.fr/radarr/api/v3/queue',
        headers: {
          HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'
        });
    if (response.statusCode == 200) {
      List<Movie> movies = List<Movie>();
      for (int i = 0; i < list.length; i++) {
        Movie movie = Movie(obj: list[i]);
        movie.status = movie.GetStatus(json.decode(response.body));
        movies.add(movie);
      }
      return movies;
    } else {
      throw Exception('Failed to load queue');
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}

Future<String> GetDiskSizeLeft() async
{
  var response = await http.get('https://nutflix.fr/radarr/api/v3/diskspace',
      headers: {
        HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'
      });

  if (response.statusCode == 200) {
    List<dynamic> list = json.decode(response.body);
    int spaceLeft = list[0]['freeSpace'];
    return '${(spaceLeft * 0.000000001).round()} GB left';
    // If the server did return a 200 OK response,
    // then parse the JSON.
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }

}

class Movies extends StatelessWidget {
  static const String route = '/movies';
  
  Movies({ Key key }) : super(key: key);

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
                  child: Text('Movies'),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FutureBuilder<String>(
                    future: GetDiskSizeLeft(),
                    builder: (context, snapshot) {
                      developer.log(snapshot.error.toString());
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
      drawer: CustomDrawer(),
      body : FutureBuilder(
          future : fetchMovies(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                  itemCount: snapshot.data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      childAspectRatio: 2 / 3,
                      crossAxisCount: 3
                  ),
                  itemBuilder: (context, i) {
                    Movie movie = snapshot.data[i];
                    Color circleColor = Colors.white;
                    if (movie.status == Status.Downloaded)
                      circleColor = Colors.green;
                    else if (movie.status == Status.Queued)
                      circleColor = Colors.purple;
                    else if (movie.status == Status.Missing)
                      circleColor = Colors.yellow;

                    return Container(
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
                                      image: movie.GetPoster(),
                                    )
                              )
                          ),
                        )
                    );
                  }
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          }
      ),
    );
  }

}