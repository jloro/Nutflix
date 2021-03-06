import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutflix/PlayerPrefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class Settings extends StatefulWidget {
  static const String route = '/settings';
  static const int index = 3;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String defaultProfile;
  List<DropdownMenuItem<String>> items;

  String uhdProfile;
  List<DropdownMenuItem<String>> itemsUhd;

  SharedPreferences prefs;
  List<dynamic> profiles;

  showAlertDialog(BuildContext context) {
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

  _resetPlayerPrefs() async {
    setState(() {
      PlayerPrefs.statsForNerds = false;
      PlayerPrefs.radarrURL = null;
      PlayerPrefs.radarrApiKey = null;
      PlayerPrefs.defaultProfile = 1;
      PlayerPrefs.uhdProfile = 5;

      prefs.setString(PlayerPrefs.radarrURLKey, PlayerPrefs.radarrURL);
      prefs.setString(PlayerPrefs.radarrApiKeyKey, PlayerPrefs.radarrApiKey);
      prefs.setBool(PlayerPrefs.statsForNerdsKey, PlayerPrefs.statsForNerds);
      prefs.setInt(PlayerPrefs.defaultProfileKey, PlayerPrefs.defaultProfile);
      prefs.setInt(PlayerPrefs.uhdProfileKey, PlayerPrefs.uhdProfile);
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
    });
  }

  _fetchNamingFormat() async {
    var response = await http.get(
        '${PlayerPrefs.radarrURL}/api/v3/config/naming',
        headers: {HttpHeaders.authorizationHeader: PlayerPrefs.radarrApiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> map = json.decode(response.body);
      if (PlayerPrefs.folderNamingFormat == null || PlayerPrefs.folderNamingFormat != map['movieFolderFormat'])
        PlayerPrefs.folderNamingFormat = map['movieFolderFormat'];
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('ftech quality profile failed');
    }
  }

  _fetchQualityProfiles() async {
    await _loadPrefs();
    var response = await http.get(
        '${PlayerPrefs.radarrURL}/api/v3/qualityprofile',
        headers: {HttpHeaders.authorizationHeader: PlayerPrefs.radarrApiKey});

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
          child: Text(value),
        );
      }).toList();
      await _fetchNamingFormat();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('ftech quality profile failed');
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
                      icon: Icon(Icons.delete_forever),
                      onPressed: (){
                        showAlertDialog(context);
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
                child: Column(children: <Widget>[
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
                ])),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                            child: Container(
                              child: Align(
                                child: Text('Folder naming',
                                  style: TextStyle(fontSize: 20),
                                ),
                                alignment: Alignment.centerLeft,
                              )
                            )
                        ),
                        Flexible(
                            child: Container(
                              padding: EdgeInsets.only(top: 10),
                                child: Align(
                                  child: Text(PlayerPrefs.folderNamingFormat ?? "",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w100
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                )
                            )
                        )
                      ],
                    )
                  )
            ])),
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
