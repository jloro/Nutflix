import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutflix/PlayerPrefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  static const String route = '/settings';
  static const int index = 2;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _statsForNerdsState = false;

  _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _statsForNerdsState = (prefs.getBool(PlayerPrefs.statsForNerds) ?? false);
    });
  }

  _changeStatForNerds(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _statsForNerdsState = value;
      prefs.setBool(PlayerPrefs.statsForNerds, _statsForNerdsState);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Container(
          child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(children: <Widget>[
                Expanded(
                    child: Container(
                        child: Column(children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Stats',
                        style: TextStyle(fontSize: 30),
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: SwitchListTile(
                            title: Text('Stats for nerds'),
                            value: _statsForNerdsState,
                            onChanged: _changeStatForNerds,
                          )))
                ]))),
              ]))),
    );
  }
}
