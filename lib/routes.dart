import 'package:nutflix/AddMovie.dart';
import 'package:nutflix/InfoMovie.dart';
import 'package:nutflix/Search.dart';

import 'Movies.dart';

class Routes
{
  static const List<String> routes = <String>[movies, search, null];
  static const String movies = Movies.route;
  static const String search = Search.route;
  static const String addMovie = AddMovie.route;
  static const String infoMovie = InfoMovie.route;
}