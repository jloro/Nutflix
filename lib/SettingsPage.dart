import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  static const String route = '/settings';
  static const int index = 3;

  final void Function() reload;

  Settings({Key key, @required this.reload}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String defaultProfile;
  String currLang;
  String currRootFolder;

  Map<String, dynamic> mapLang;

  List<DropdownMenuItem<String>> items;
  List<DropdownMenuItem<String>> itemsRootFolder;
  List<DropdownMenuItem<String>> lang = <String>[
    "English",
    "French",
    "Spanish",
    "German",
    "Italian",
    "Danish",
    "Dutch",
    "Japanese",
    "Icelandic",
    "Chinese",
    "Russian",
    "Polish",
    "Vietnamese",
    "Swedish",
    "Norwegian",
    "Finnish",
    "Turkish",
    "Portuguese",
    "Flemish",
    "Greek",
    "Korean",
    "Hungarian",
    "Hebrew",
    "Lithuanian",
    "Czech",
    "Hindi",
    "Romanian",
    "Thai",
    "Bulgarian",
  ].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  String uhdProfile;
  List<DropdownMenuItem<String>> itemsUhd;

  SharedPreferences prefs;
  List<dynamic> profiles;

  Widget iconAdvanced = Icon(Icons.add_box);

  showAlertDialogConfirm(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Yes"),
      onPressed: () {
        _resetPlayerPrefs();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Reset"),
      content: Text("Reset settings ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogAbout(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("About"),
      content: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text:
                  "This app is intended for personal and non commercial use only.\nAll movies metadata and poster are from TMDB (",
            ),
            WidgetSpan(
                child: InkWell(
                    child: new Text(
                      ' https://www.themoviedb.org/ ',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                    onTap: () => launch('https://www.themoviedb.org/'))),
            TextSpan(
              text:
                  ") and used in agreement with their terms of use.\nAll the movies poster belongs to their respective owners.\n\nThis app doesn't allow nor promote illegal download of copyrighted content, only use it for movies for which you have rights according to your country's legislation.\n\nWe don't store any content, metadata or user information. This app is only an interface for third-parties services.",
            ),
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _resetPlayerPrefs() async {
    setState(() {
      PlayerPrefs.statsForNerds = false;
      PlayerPrefs.radarrURL = null;
      PlayerPrefs.radarrApiKey = null;
      PlayerPrefs.defaultProfile = 1;
      PlayerPrefs.uhdProfile = 5;
      PlayerPrefs.sabURL = null;
      PlayerPrefs.sabApiKey = null;
      PlayerPrefs.showAdvancedSettings = false;

      prefs.setString(PlayerPrefs.radarrURLKey, PlayerPrefs.radarrURL);
      prefs.setString(PlayerPrefs.radarrApiKeyKey, PlayerPrefs.radarrApiKey);
      prefs.setBool(PlayerPrefs.statsForNerdsKey, PlayerPrefs.statsForNerds);
      prefs.setInt(PlayerPrefs.defaultProfileKey, PlayerPrefs.defaultProfile);
      prefs.setInt(PlayerPrefs.uhdProfileKey, PlayerPrefs.uhdProfile);
      prefs.setString(PlayerPrefs.sabURLKey, PlayerPrefs.sabURL);
      prefs.setString(PlayerPrefs.sabApiKeyKey, PlayerPrefs.sabApiKey);
      prefs.setBool(PlayerPrefs.showAdvancedSettingsKey, PlayerPrefs.showAdvancedSettings);

      currLang = "English";
      iconAdvanced = Icon(Icons.add_box);
      _updateLang();
    });
  }

  _changeRadarrURL(String url) async {
    setState(() {
      PlayerPrefs.radarrURL = url;
      prefs.setString(PlayerPrefs.radarrURLKey, PlayerPrefs.radarrURL);
    });
  }

  _changeRadarrApiKey(String url) async {
    setState(() {
      PlayerPrefs.radarrApiKey = url;
      prefs.setString(PlayerPrefs.radarrApiKeyKey, PlayerPrefs.radarrApiKey);
    });
  }

  _changeSabURL(String url) async {
    setState(() {
      PlayerPrefs.sabURL = url;
      prefs.setString(PlayerPrefs.sabURLKey, PlayerPrefs.sabURL);
    });
  }

  _changeSabApiKey(String url) async {
    setState(() {
      PlayerPrefs.sabApiKey = url;
      prefs.setString(PlayerPrefs.sabApiKeyKey, PlayerPrefs.sabApiKey);
    });
  }

  _changeDefaultProfile(int profile) async {
    setState(() {
      PlayerPrefs.defaultProfile = profile;
      prefs.setInt(PlayerPrefs.defaultProfileKey, PlayerPrefs.defaultProfile);
    });
  }

  _changeUhdProfile(int profile) async {
    setState(() {
      PlayerPrefs.uhdProfile = profile;
      prefs.setInt(PlayerPrefs.uhdProfileKey, PlayerPrefs.uhdProfile);
    });
  }

  _changeStatForNerds(bool value) async {
    setState(() {
      PlayerPrefs.statsForNerds = value;
      prefs.setBool(PlayerPrefs.statsForNerdsKey, PlayerPrefs.statsForNerds);
    });
  }

  _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
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

      iconAdvanced = PlayerPrefs.showAdvancedSettings ? Icon(Icons.indeterminate_check_box) : Icon(Icons.add_box);

      if (PlayerPrefs.radarrURL == PlayerPrefs.demoKey && PlayerPrefs.radarrApiKey == PlayerPrefs.demoKey && PlayerPrefs.sabURL == PlayerPrefs.demoKey && PlayerPrefs.sabApiKey == PlayerPrefs.demoKey)
        PlayerPrefs.demo = true;
    });
  }

  _fetchNamingFormat() async {
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (PlayerPrefs.demo)
    {
      apiKey = "aaaedca659fa4206bc50153292ba6da2";
      url = "https://nutflix.fr/radarr";
    }

    var response = await http.get(
        '$url/api/v3/config/naming',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> map = json.decode(response.body);
      if (PlayerPrefs.folderNamingFormat == null ||
          PlayerPrefs.folderNamingFormat != map['movieFolderFormat'])
        PlayerPrefs.folderNamingFormat = map['movieFolderFormat'];
      await _fetchLanguage();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('ftech quality profile failed');
    }
  }

  _fetchLanguage() async {
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (PlayerPrefs.demo)
    {
      apiKey = "aaaedca659fa4206bc50153292ba6da2";
      url = "https://nutflix.fr/radarr";
    }

    var response = await http.get('$url/api/v3/config/ui',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      mapLang = json.decode(response.body);
      setState(() {
        currLang = lang[mapLang['movieInfoLanguage'] - 1].value;
      });
      await _fetchRootFolder();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('fetch language failed');
    }
  }

  _updateLang() async {
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (PlayerPrefs.demo)
    {
      apiKey = "aaaedca659fa4206bc50153292ba6da2";
      url = "https://nutflix.fr/radarr";
    }

    mapLang["movieInfoLanguage"] =
        lang.indexWhere((element) => element.value == currLang) + 1;
    var response = await http.put('$url/api/v3/config/ui',
        headers: {HttpHeaders.authorizationHeader: apiKey},
        body: json.encode(mapLang));

    if (response.statusCode == 202) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('put language failed');
    }
  }

  _fetchRootFolder() async {
    //defaultProfile = null;
    //uhdProfile = null;
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (PlayerPrefs.demo)
    {
      apiKey = "aaaedca659fa4206bc50153292ba6da2";
      url = "https://nutflix.fr/radarr";
    }

    var response = await http.get('$url/api/v3/rootfolder',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> list = json.decode(response.body);
      List<String> rootFoldersString = <String>[];
      for (dynamic folder in list)
      {
        if (folder["accessible"])
          rootFoldersString.add(folder["path"]);
      }
      itemsRootFolder =
          rootFoldersString.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis),
        );
      }).toList();

      if (PlayerPrefs.dlPath == null || PlayerPrefs.dlPath == "")
        PlayerPrefs.dlPath = rootFoldersString[0];
      currRootFolder = PlayerPrefs.dlPath;
      setState(() {});
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('fetch quality profile failed');
    }
  }

  _fetchQualityProfiles() async {
    if (prefs == null) await _loadPrefs();
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (PlayerPrefs.demo)
    {
      apiKey = "aaaedca659fa4206bc50153292ba6da2";
      url = "https://nutflix.fr/radarr";
    }
    var response = await http.get(
        '$url/api/v3/qualityprofile',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> list = json.decode(response.body);
      this.profiles = list;
      defaultProfile = list
          .where((element) => element["id"] == PlayerPrefs.defaultProfile)
          .toList()[0]["name"];

      uhdProfile = list
          .where((element) => element["id"] == PlayerPrefs.uhdProfile)
          .toList()[0]["name"];

      List<String> profiles = <String>[];
      for (dynamic profile in list) profiles.add(profile["name"]);
      items = profiles.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis),
        );
      }).toList();
      setState(() {});
      await _fetchNamingFormat();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('fetch quality profile failed');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchQualityProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () {
          setState(() {
            final scaffold = ScaffoldMessenger.of(context);
            scaffold.showSnackBar(SnackBar(
              duration: Duration(milliseconds: 500),
              content: const Text('Settings changed'),
            ));
            if (PlayerPrefs.radarrURL == PlayerPrefs.demoKey && PlayerPrefs.radarrApiKey == PlayerPrefs.demoKey && PlayerPrefs.sabURL == PlayerPrefs.demoKey && PlayerPrefs.sabApiKey == PlayerPrefs.demoKey)
              PlayerPrefs.demo = true;
            else
              PlayerPrefs.demo = false;

            this.widget.reload();
            _fetchQualityProfiles();
          });
        },
      ),
      appBar: AppBar(
          title: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Settings'),
              ),
            ),
            Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: iconAdvanced,
                      onPressed: () {
                        setState(() {
                          if (PlayerPrefs.showAdvancedSettings)
                            iconAdvanced = Icon(Icons.add_box);
                          else
                            iconAdvanced = Icon(Icons.indeterminate_check_box);
                          PlayerPrefs.showAdvancedSettings = !PlayerPrefs.showAdvancedSettings;
                          prefs.setBool(PlayerPrefs.showAdvancedSettingsKey, PlayerPrefs.showAdvancedSettings);
                        });
                      },
                    )))
          ],
        ),
      )),
      body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.only(bottom: 30),
                    child: PlayerPrefs.showAdvancedSettings ? Column(children: <Widget>[
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Stats',
                            style: TextStyle(fontSize: 30),
                          )),
                      Align(
                          alignment: Alignment.centerRight,
                          child: SwitchListTile(
                            title: Text('Stats for nerds'),
                            value: PlayerPrefs.statsForNerds,
                            onChanged: _changeStatForNerds,
                          ))
                    ]) : Container()),
                Container(
                    child: Column(children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Radarr settings',
                        style: TextStyle(fontSize: 30),
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: MyTextField(
                          onChanged: _changeRadarrApiKey,
                          autocorrect: false,
                          decoration: InputDecoration(
                              labelText: 'Api key',
                              border: OutlineInputBorder(),
                              hintText: 'Api key'),
                          text: PlayerPrefs.radarrApiKey)),
                  Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: MyTextField(
                          onChanged: _changeRadarrURL,
                          autocorrect: false,
                          decoration: InputDecoration(
                              labelText: 'Radarr URL',
                              border: OutlineInputBorder(),
                              hintText: 'Radarr URL'),
                          text: PlayerPrefs.radarrURL)),
                  Container(
                    child: PlayerPrefs.showAdvancedSettings ? Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Default profile',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: defaultProfile != null
                                        ? DropdownButton<String>(
                                      value: defaultProfile,
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(fontSize: 20),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.red,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          defaultProfile = newValue;
                                          _changeDefaultProfile(profiles
                                              .where((element) =>
                                          element["name"] == newValue)
                                              .toList()[0]["id"]);
                                        });
                                      },
                                      items: items,
                                    )
                                        : CircularProgressIndicator())
                              ])),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Ultra HD profile',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: uhdProfile != null
                                        ? DropdownButton<String>(
                                      value: uhdProfile,
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(fontSize: 20),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.red,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          uhdProfile = newValue;
                                          _changeUhdProfile(profiles
                                              .where((element) =>
                                          element["name"] == newValue)
                                              .toList()[0]["id"]);
                                        });
                                      },
                                      items: items,
                                    )
                                        : CircularProgressIndicator())
                              ])),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Movie info language',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: currLang != null
                                        ? DropdownButton<String>(
                                      value: currLang,
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(fontSize: 20),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.red,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          currLang = newValue;
                                          _updateLang();
                                        });
                                      },
                                      items: lang,
                                    )
                                        : CircularProgressIndicator())
                              ])),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Root folder',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: currRootFolder != null
                                    ? DropdownButton<String>(
                                  isExpanded: true,
                                  value: currRootFolder,
                                  icon: Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(fontSize: 20),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.red,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      currRootFolder = newValue;
                                      PlayerPrefs.dlPath = newValue;
                                    });
                                  },
                                  items: itemsRootFolder,
                                )
                                    : CircularProgressIndicator())),
                      ]
                    ) : Container()
                  ),
                ])),
                Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sabnzbd settings',
                          style: TextStyle(fontSize: 30),
                        ))),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: MyTextField(
                        onChanged: _changeSabApiKey,
                        autocorrect: false,
                        decoration: InputDecoration(
                            labelText: 'Api key',
                            border: OutlineInputBorder(),
                            hintText: 'Api key'),
                        text: PlayerPrefs.sabApiKey)),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: MyTextField(
                        onChanged: _changeSabURL,
                        autocorrect: false,
                        decoration: InputDecoration(
                            labelText: 'Sabnzbd URL',
                            border: OutlineInputBorder(),
                            hintText: 'Sabnzbd URL'),
                        text: PlayerPrefs.sabURL)),
                Padding(
                  padding: EdgeInsets.only(top: 40, right: 40, left: 40),
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    showAlertDialogAbout(context);
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          style: TextStyle(fontSize: 18),
                                          text: "about ",
                                        ),
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(Icons.info,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ))),
                        Expanded(
                            child: Container(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showAlertDialogConfirm(context);
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          style: TextStyle(fontSize: 18),
                                          text: "delete ",
                                        ),
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(Icons.delete,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                )))
                      ],
                    ),
                  ),
                ),
              ]))),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String text;
  final Function(String) onChanged;
  final bool autocorrect;
  final InputDecoration decoration;
  TextField textfield;

  TextEditingController controller;

  MyTextField({this.text, this.onChanged, this.autocorrect, this.decoration});

  @override
  Widget build(BuildContext context) {
    controller = TextEditingController(text: text);
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    textfield = TextField(
      onChanged: onChanged,
      autocorrect: autocorrect,
      decoration: decoration,
      controller: controller,
    );
    return textfield;
  }
}
