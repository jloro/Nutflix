import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:Nutarr/AppBar.dart';
import 'package:Nutarr/Drawer.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:Nutarr/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:developer' as developer;
import 'Movie.dart';

Future<List<Movie>> fetchMovies() async {
  if (PlayerPrefs.radarrURL == null || PlayerPrefs.radarrURL == "")
    throw Exception('No radarr URL specified, go to settings to specified it.');
  else if (PlayerPrefs.radarrApiKey == null || PlayerPrefs.radarrApiKey == "")
    throw Exception('No radarr api key specified, go to settings to specified it.');

  var response = await http.get('${PlayerPrefs.radarrURL}/api/v3/movie',
      headers: {
        HttpHeaders.authorizationHeader: PlayerPrefs.radarrApiKey
      });

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> list = json.decode(response.body);
    response = await http.get('${PlayerPrefs.radarrURL}/api/v3/queue',
        headers: {
          HttpHeaders.authorizationHeader: PlayerPrefs.radarrApiKey
        });
    if (response.statusCode == 200) {
      List<Movie> movies = List<Movie>();
      for (int i = 0; i < list.length; i++) {
        Movie movie = Movie(obj: list[i]);
        movie.status = movie.GetStatus(json.decode(response.body));
        movies.add(movie);
      }
      movies.sort((a, b) => DateTime.parse(b.GetAdded()).compareTo(DateTime.parse(a.GetAdded())));
      return movies;
    } else {
      throw Exception('Failed to load queue');
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movies, check radarr settings.');
  }
}

Future<String> GetDiskSizeLeft() async
{
  var response = await http.get('${PlayerPrefs.radarrURL}/api/v3/diskspace',
      headers: {
        HttpHeaders.authorizationHeader: PlayerPrefs.radarrApiKey
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
class Movies extends StatefulWidget {
  static const String route = '/movies';
  static const int index = 0;

  Movies({ Key key }) : super(key: key);

  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  Future<List<Movie>> _fetchMovies;
  Future<String> _getSizeDisk;

  _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      PlayerPrefs.statsForNerds =
      (prefs.getBool(PlayerPrefs.statsForNerdsKey) ?? false);
      PlayerPrefs.radarrURL =
      (prefs.getString(PlayerPrefs.radarrURLKey) ?? null);
      PlayerPrefs.radarrApiKey =
      (prefs.getString(PlayerPrefs.radarrApiKeyKey) ?? null);
      _fetchMovies = fetchMovies();
      _getSizeDisk = GetDiskSizeLeft();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _refreshWidget() => Future.delayed(Duration(seconds: 1), () {
    setState(() {
      _fetchMovies = fetchMovies();
      _getSizeDisk = GetDiskSizeLeft();
    });
  });

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
                    future: _getSizeDisk,
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
      body : RefreshIndicator(
      displacement: 30,
      onRefresh: _refreshWidget,
      child : FutureBuilder<List<Movie>>(
          future : _fetchMovies,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return  GridView.builder(
                  itemCount: snapshot.data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      childAspectRatio: 2 / 3,
                      crossAxisCount: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height > 1 ? 5 : 3
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
                      child : InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.infoMovie, arguments: movie);
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
                                      image: movie.GetPoster(),
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
    ));
  }

}