import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutflix/PlayerPrefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class Settings extends StatefulWidget {
  static const String route = '/settings';
  static const int index = 2;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  _resetPlayerPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      PlayerPrefs.statsForNerds = false;
      PlayerPrefs.radarrURL = null;
      PlayerPrefs.radarrApiKey = null;
      prefs.setString(PlayerPrefs.radarrURLKey, PlayerPrefs.radarrURL);
      prefs.setString(PlayerPrefs.radarrApiKeyKey, PlayerPrefs.radarrApiKey);
      prefs.setBool(PlayerPrefs.statsForNerdsKey, PlayerPrefs.statsForNerds);
    });
  }

  _changeRadarrURL(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      PlayerPrefs.radarrURL = url;
      prefs.setString(PlayerPrefs.radarrURLKey, PlayerPrefs.radarrURL);
    });
  }

  _changeRadarrApiKey(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      PlayerPrefs.radarrApiKey = url;
      prefs.setString(PlayerPrefs.radarrApiKeyKey, PlayerPrefs.radarrApiKey);
    });
  }

  _changeStatForNerds(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      PlayerPrefs.statsForNerds = value;
      prefs.setBool(PlayerPrefs.statsForNerdsKey, PlayerPrefs.statsForNerds);
    });
  }

  @override
  void initState() {
    super.initState();
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
                      icon: Icon(Icons.loop),
                      onPressed: _resetPlayerPrefs,
                    )))
          ],
        ),
      )),
      body: Container(
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
            ])),
          ])),
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
