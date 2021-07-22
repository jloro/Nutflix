import 'package:Nutarr/AddMovie.dart';
import 'package:Nutarr/Downloads.dart';
import 'package:Nutarr/InfoMovie.dart';
import 'package:Nutarr/InfoShow.dart';
import 'package:Nutarr/Search.dart';
import 'package:Nutarr/Settings/SettingsPage.dart';

import 'AddShow.dart';
import 'Movies.dart';
import 'Series.dart';

class Routes
{
  static const List<String> routes = <String>[movies, series, search, downloading, settings];
  static const String movies = Movies.route;
  static const String series = Series.route;
  static const String search = Search.route;
  static const String addMovie = AddMovie.route;
  static const String addShow = AddShow.route;
  static const String infoMovie = InfoMovie.route;
  static const String infoShow = InfoShow.route;
  static const String settings = Settings.route;
  static const String downloading = Downloads.route;
}