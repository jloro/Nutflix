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

import 'DisplayGridObject.dart';
import 'Movie.dart';

Future<List<DisplayGridObject>> FetchSearchMovie(String search) async {
  String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

  if (PlayerPrefs.radarrURL == null || PlayerPrefs.radarrURL == "")
    throw Error();
  else if (PlayerPrefs.radarrApiKey == null || PlayerPrefs.radarrApiKey == "")
    throw Error();

  final response = await http.get(
      '$url/api/v3/movie/lookup?term=$search',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> list = json.decode(response.body);
    List<DisplayGridObject> movies = List<DisplayGridObject>();
    list.forEach((element) {
      DisplayGridObject movie = DisplayGridObject(type: Type.Movie, obj: element);
      if (movie.movie.GetRelease() != 'N/A' && movie.GetOverview() != null && movie.GetPoster() != null) movies.add(movie);
    });
    return movies;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Error();
  }
}

Future<List<DisplayGridObject>> FetchSearchShow(String search) async {
  String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

  if (PlayerPrefs.sonarrURL == null || PlayerPrefs.sonarrURL == "")
    throw Error();
  else if (PlayerPrefs.sonarrApiKey == null || PlayerPrefs.sonarrApiKey == "")
    throw Error();

  final response = await http.get(
      '$url/api/v3/series/lookup?term=$search',
      headers: {
        HttpHeaders.authorizationHeader: apiKey
      });

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> list = json.decode(response.body);
    List<DisplayGridObject> series = List<DisplayGridObject>();
    list.forEach((element) {
      DisplayGridObject show = DisplayGridObject(type: Type.TVShow, obj: element);
      if (show.GetOverview() != null && show.GetPoster() != null) series.add(show);
    });
    return series;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Error();
  }
}

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    this.object,
  });

  final DisplayGridObject object;

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
                if (object.type == Type.Movie)
                  Navigator.pushNamed(context, Routes.addMovie, arguments: object.movie);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                        width: 100,
                        child:
                            Image.network(object.GetPoster(), fit: BoxFit.fill)),
                  Expanded(
                    flex: 3,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(object.GetTitle(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.0,
                                )),
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0)),
                            Text(object.GetOverview(),
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
  Future<List<DisplayGridObject>> Function(String) _futureSearch = FetchSearchMovie;
  final SearchBarController<DisplayGridObject> _searchBarController = new SearchBarController();

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
                          activeColor: ThemeData.fallback().toggleableActiveColor,
                          inactiveThumbColor: ThemeData.fallback().toggleableActiveColor,
                          inactiveTrackColor: ThemeData.fallback().toggleableActiveColor.withAlpha(127),
                          activeTrackColor: ThemeData.fallback().toggleableActiveColor.withAlpha(127),
                          value: _movie,
                          onChanged: (bool state){
                            setState(() {
                              _movie = !_movie;
                              _futureSearch = _movie ? FetchSearchMovie : FetchSearchShow;
                              _searchBarController.forceSearch(_movie ? FetchSearchMovie : FetchSearchShow);
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
              child: SearchBar<DisplayGridObject>(
                searchBarController: _searchBarController,
                textStyle: TextStyle(
                    color: Colors.white
                ),
                onError: (Error error) {
                  developer.log(error.toString());
                  if (_movie)
                    return Text('Failed to load movies, check your radarr settings.');
                  else
                    return Text('Failed to load series, check your sonarr settings.');
                },
                emptyWidget: Text('No result found'),
                minimumChars: 1,
                onSearch: _movie ? FetchSearchMovie : FetchSearchShow,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                crossAxisCount: 1,
                onItemFound: (DisplayGridObject object, int i) {
                  return CustomListItem(object: object);
                },
              ),
            )),
      ),
    );
  }
}