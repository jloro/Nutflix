import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutflix/AppBar.dart';
import 'package:nutflix/Drawer.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Movie.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

Future<bool> AddRadarrMovie(Movie movie) async
{
  var response = await http.post('https://nutflix.fr/radarr/api/v3/movie', headers : {HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'}, body: movie.ToJson());

  if (response.statusCode == 201) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> obj = json.decode(response.body);
    response = await http.post('https://nutflix.fr/radarr/api/v3/command', headers : {HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'}, body : json.encode({'name': 'MoviesSearch', 'movieIds': [obj['id']]}));
    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to load Movie');
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}

Future<bool> HasMovie(Movie movie) async
{
  final response = await http.get('https://nutflix.fr/radarr/api/v3/movie', headers : {HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'});

  if (response.statusCode == 200) {

    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> list = json.decode(response.body);
    for (int i = 0; i < list.length; i++)
    {
      Movie tmp = Movie(obj : list[i]);
      if (tmp.GetIMDBId() == movie.GetIMDBId())
        return true;
    }
    return false;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}

class AddMovie extends StatefulWidget {
  static const String route = '/search/addmovie';


  @override
  _AddMovieState createState() => new _AddMovieState();
}

class _AddMovieState extends State<AddMovie>
{
  bool addIsInactive;

  @override
  void initState() {
    addIsInactive = false;
  }

  @override
  Widget build(BuildContext context) {
    final Movie movie = ModalRoute.of(context).settings.arguments;
    void Function() addOnPressed;
    void Function() plexOnPressed;


    return Scaffold(
        appBar: CustomAppBar(),
        body: Column(
            children: <Widget>[
              Container(
                  height: 200,
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: EdgeInsets.only(bottom: 20, left: 5),
                          child: Stack(
                            children: <Widget>[
                              Text(
                                  movie.GetTitle(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = Colors.black
                                  )
                              ),
                              Text(
                                movie.GetTitle(),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white
                                ),
                              )
                            ],
                          )
                      )
                  ),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(movie.GetFanart()),
                          fit: BoxFit.cover
                      )
                  )
              ),
              Container(
                height: 200,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: Image.network(movie.GetPoster()),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(new DateFormat().add_yMMMd().format(DateTime.parse(movie.GetRelease()))
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Movies', style: TextStyle(fontSize: 20)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final url = 'https://www.imdb.com/title/${movie.GetIMDBId()}';
                              if (await canLaunch(url))
                                await launch(url);
                              else
                                throw "Could not launch $url";
                            },
                            child: const Text('IMDB', style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: FutureBuilder<bool>(
                          future: HasMovie(movie),
                          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                            developer.log(snapshot.hasData.toString());

                            if (snapshot.hasData)
                            {
                              if (!snapshot.data)
                              {
                                addOnPressed = () async {
                                  setState(() {
                                    addIsInactive = true;
                                    addOnPressed = null;
                                    plexOnPressed = () {};
                                  });

                                  await AddRadarrMovie(movie);
                                };
                                plexOnPressed = null;
                              } else {
                                addOnPressed = null;
                                plexOnPressed = () {};
                              }

                              return Column(
                                children: <Widget>[
                                  Text('Rating : ${movie.GetRating()}'
                                  ),
                                  ElevatedButton(
                                    onPressed: addIsInactive ? null : addOnPressed,
                                    child: const Text('Add', style: TextStyle(fontSize: 20)),
                                  ),
                                  ElevatedButton(
                                    onPressed: plexOnPressed,
                                    child: const Text('View on plex', style: TextStyle(fontSize: 20)),
                                  ),
                                ],
                              );
                            } else{
                              return UnconstrainedBox(
                                  child : CircularProgressIndicator()
                              );
                            }
                          },
                        )
                    )
                  ],
                ),
              )
            ]
        )
    );
  }

}