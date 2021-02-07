import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:nutflix/AppBar.dart';
import 'package:nutflix/Drawer.dart';

import 'Movie.dart';

Future<List<Movie>> fetchMovies() async {

  final response =
  await http.get('https://nutflix.fr/radarr/api/v3/movie', headers : {HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'});

  if (response.statusCode == 200) {

    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> list = json.decode(response.body);
    List<Movie> movies = List<Movie>();
    list.forEach((element) {
      movies.add(Movie(obj : element));
    });
    return movies;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}

class Movies extends StatefulWidget {
  static const String route = '/movies';
  
  Movies({ Key key }) : super(key: key);
  
  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  Future<List<Movie>> movies;

  @override
  void initState() {
    super.initState();
    movies = fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body : FutureBuilder(
          future : movies,
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
                                    color: Colors.orange,
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
                            height: 200,
                            child: Image.network(movie.GetPoster(), fit: BoxFit.cover),
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