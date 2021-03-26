import 'dart:convert';
import 'dart:io';

import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:Nutarr/AppBar.dart';
import 'package:Nutarr/BottomNavigationBar.dart';
import 'package:Nutarr/Drawer.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:Nutarr/routes.dart';
import 'dart:developer' as developer;

import 'Movie.dart';

Future<List<Movie>> FetchSearch(String search) async {
  final response = await http.get(
      '${PlayerPrefs.radarrURL}/api/v3/movie/lookup?term=$search',
      headers: {
        HttpHeaders.authorizationHeader: PlayerPrefs.radarrApiKey
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
    throw Exception('Failed to load Movie');
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
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                        width: 100,
                        child:
                            Image.network(movie.GetPoster(), fit: BoxFit.fill)),
                  ),
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
                                maxLines: 14,
                                overflow: TextOverflow.ellipsis),
                          ],
                        )),
                  ),
                ],
              )),
        ));
  }
}

class Search extends StatelessWidget {
  static const String route = '/search';
  static const int index = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SearchBar<Movie>(
          textStyle: TextStyle(
            color: Colors.white
          ),
          emptyWidget: Text('No result found'),
          minimumChars: 0,
          onSearch: FetchSearch,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          crossAxisCount: 1,
          onItemFound: (Movie movie, int i) {
            return CustomListItem(movie: movie);
          },
        ),
      )),
    );
  }
}

// class _SearchState extends State<Search> {
//   Future<List<Movie>> movies;
//
//   }
//
// }
