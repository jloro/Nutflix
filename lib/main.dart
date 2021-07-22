import 'dart:io';

import 'package:Nutarr/InfoShow.dart';
import 'package:flutter/material.dart';
import 'package:Nutarr/AddMovie.dart';
import 'package:Nutarr/BottomNavigationBar.dart';
import 'package:Nutarr/InfoMovie.dart';
import 'package:Nutarr/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as developer;

import 'AddShow.dart';
import 'Downloads.dart';
import 'Movies.dart';
import 'PlayerPrefs.dart';
import 'Search.dart';
import 'Series.dart';
import 'SettingsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  PlayerPrefs.statsForNerds =
    (prefs.getBool(PlayerPrefs.statsForNerdsKey) ?? false);
  PlayerPrefs.radarrURL =
    (prefs.getString(PlayerPrefs.radarrURLKey) ?? null);
  PlayerPrefs.radarrApiKey =
    (prefs.getString(PlayerPrefs.radarrApiKeyKey) ?? null);
  PlayerPrefs.defaultProfile =
    (prefs.getInt(PlayerPrefs.defaultProfileKey) ?? 1);
  PlayerPrefs.uhdProfile = (prefs.getInt(PlayerPrefs.uhdProfileKey) ?? 5);
  PlayerPrefs.folderNamingFormat =
    (prefs.getString(PlayerPrefs.folderNamingFormatKey) ?? null);
  PlayerPrefs.sabURL = (prefs.getString(PlayerPrefs.sabURLKey) ?? null);
  PlayerPrefs.sabApiKey =
    (prefs.getString(PlayerPrefs.sabApiKeyKey) ?? null);
  PlayerPrefs.dlPath =
    (prefs.getString(PlayerPrefs.dlPathKey) ?? null);
  PlayerPrefs.showAdvancedSettings =
    (prefs.getBool(PlayerPrefs.showAdvancedSettingsKey) ?? false);
  PlayerPrefs.sonarrApiKey =
    (prefs.getString(PlayerPrefs.sonarrApiKeyKey) ?? null);
  PlayerPrefs.sonarrURL =
    (prefs.getString(PlayerPrefs.sonarrURLKey) ?? null);

  if (PlayerPrefs.radarrURL == PlayerPrefs.demoKey && PlayerPrefs.radarrApiKey == PlayerPrefs.demoKey && PlayerPrefs.sabURL == PlayerPrefs.demoKey && PlayerPrefs.sabApiKey == PlayerPrefs.demoKey)
    PlayerPrefs.demo = true;

  PlayerPrefs.firstLaunch = (prefs.getBool(PlayerPrefs.firstLaunchKey) ?? true);
  prefs.setBool(PlayerPrefs.firstLaunchKey, PlayerPrefs.firstLaunch);

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  MyApp({ this.prefs });
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        Routes.movies: (cxt) => Movies(),
        Routes.series: (cxt) => Series(),
        Routes.search: (cxt) => Search(),
        Routes.addMovie: (cxt) => AddMovie(movie: ModalRoute.of(cxt).settings.arguments),
        Routes.addShow: (cxt) => AddShow(show: ModalRoute.of(cxt).settings.arguments),
        Routes.infoMovie: (cxt) => InfoMovie(movie: ModalRoute.of(cxt).settings.arguments),
        Routes.infoShow: (cxt) => InfoShow(show: ModalRoute.of(cxt).settings.arguments),
        Routes.settings: (cxt) => Settings(prefs: prefs),
        Routes.downloading: (cxt) => Downloads()
      },
      title: 'Nutarr',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        brightness: Brightness.dark,
        backgroundColor: Colors.red
      ),
      home: MyHomePage(title: 'Nutflix', prefs: prefs,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final SharedPreferences prefs;

  MyHomePage({Key key, this.title, this.prefs}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final GlobalKey<MyBottomNavigationBarState> key = GlobalKey();

  UniqueKey keyMovies = UniqueKey();
  UniqueKey keySeries = UniqueKey();
  UniqueKey keyDownloads = UniqueKey();
  UniqueKey keySettings = UniqueKey();

  void _selectTab(int index) {
    if (index != _currentIndex) {
      if (_currentIndex == Search.index)
        FocusScope.of(context).unfocus();
      setState(() => _currentIndex = index);
    }
  }

  void _reload()
  {
    setState(() {
      keyMovies = UniqueKey();
      //keySettings = UniqueKey();
      keyDownloads = UniqueKey();
    });
  }

  // void _loadPref() async
  // {
  //   //SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   setState(() {
  //   });
  //
  // }

  @override
  void initState() {
    super.initState();
    setState(() {
      if (PlayerPrefs.firstLaunch) {
        _currentIndex = 3;

        this.widget.prefs.setBool(PlayerPrefs.firstLaunchKey, false);
      }
    });
    //_loadPref();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Offstage(
              offstage: _currentIndex != Movies.index,
              child: TickerMode(
                  enabled: _currentIndex == Movies.index, child: Movies(key: keyMovies))),
          Offstage(
              offstage: _currentIndex != Search.index,
              child: TickerMode(
                  enabled: _currentIndex == Search.index, child: Search())),
          Offstage(
              offstage: _currentIndex != Settings.index,
              child: TickerMode(
                  enabled: _currentIndex == Settings.index, child: Settings(reload: _reload, key:keySettings, prefs: this.widget.prefs,))),
          Offstage(
              offstage: _currentIndex != Downloads.index,
              child: TickerMode(
                  enabled: _currentIndex == Downloads.index, child: Downloads(barKey: key, key:keyDownloads))),
          Offstage(
              offstage: _currentIndex != Series.index,
              child: TickerMode(
                  enabled: _currentIndex == Series.index, child: Series(key: keyMovies))),

        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        key: key,
        currentIndex: _currentIndex,
        onSelectTab: _selectTab,
      ),
    );
  }
}
