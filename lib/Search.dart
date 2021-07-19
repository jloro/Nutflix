import 'dart:convert';
import 'dart:io';

import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:Nutarr/BottomNavigationBar.dart';
import 'package:Nutarr/Drawer.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:Nutarr/routes.dart';
import 'dart:developer' as developer;

import 'Movie.dart';

Future<List<Movie>> FetchSearch(String search) async {
  String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

  if (PlayerPrefs.radarrURL == null || PlayerPrefs.radarrURL == "")
    throw Error();
  else if (PlayerPrefs.radarrApiKey == null || PlayerPrefs.radarrApiKey == "")
    throw Error();
  else if (PlayerPrefs.demo)
  {
    apiKey = "aaaedca659fa4206bc50153292ba6da2";
    url = "https://nutflix.fr/radarr";
  }

  final response = await http.get(
      '$url/api/v3/movie/lookup?term=$search',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> list = json.decode(response.body);
    List<Movie> movies = List<Movie>();
    list.forEach((element) {
      Movie movie = Movie(obj: element);
      if (movie.GetRelease() != 'N/A') movies.add(movie);
    });
    return movies;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Error();
  }
}

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          semanticContainer: true,
          elevation: 5,
          child: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.pushNamed(context, Routes.addMovie, arguments: movie);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                        width: 100,
                        child:
                            Image.network(movie.GetPoster(), fit: BoxFit.fill)),
                  Expanded(
                    flex: 3,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(movie.GetTitle(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.0,
                                )),
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0)),
                            Text(movie.GetOverview(),
                                style: const TextStyle(fontSize: 10.0),
                                maxLines: 9,
                                overflow: TextOverflow.ellipsis),
                          ],
                        )),
                  ),
                ],
              )),
        ));
  }
}

class Search extends StatefulWidget {
  static const String route = '/search';
  static const int index = 2;

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool _movie = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Text('Search')
              ),
              Expanded(
                  child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                      children: [
                        Text('Series', style: TextStyle(fontSize: 15)),
                        Switch(
                          value: _movie,
                          onChanged: (bool state){
                            setState(() {
                              _movie = !_movie;
                            });
                          },
                        ),
                        Text('Movies', style: TextStyle(fontSize: 15)),
                      ]

                  ))
              )
            ]
          )
        ),
        body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SearchBar<Movie>(
                textStyle: TextStyle(
                    color: Colors.white
                ),
                onError: (Error error) {
                  developer.log(error.toString());
                  return Text('Failed to load movies, check your radarr settings.');
                },
                emptyWidget: Text('No result found'),
                minimumChars: 1,
                onSearch: FetchSearch,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                crossAxisCount: 1,
                onItemFound: (Movie movie, int i) {
                  return CustomListItem(movie: movie);
                },
              ),
            )),
      ),
    );
  }
}