import 'package:Nutarr/AddMovie.dart';
import 'package:Nutarr/Downloads.dart';
import 'package:Nutarr/InfoMovie.dart';
import 'package:Nutarr/Search.dart';
import 'package:Nutarr/SettingsPage.dart';

import 'Movies.dart';

class Routes
{
  static const List<String> routes = <String>[movies, search, downloading, settings];
  static const String movies = Movies.route;
  static const String search = Search.route;
  static const String addMovie = AddMovie.route;
  static const String infoMovie = InfoMovie.route;
  static const String settings = Settings.route;
  static const String downloading = Downloads.route;
}