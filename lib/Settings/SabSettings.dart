import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../PlayerPrefs.dart';
import 'MyTextField.dart';

class SabSettings extends StatefulWidget {
  final SharedPreferences prefs;

  SabSettings({Key key, this.prefs}) : super(key: key);

  @override
  _SabSettingsState createState() => _SabSettingsState();
}

class _SabSettingsState extends State<SabSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 40),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sabnzbd settings',
                style: TextStyle(fontSize: 30),
              ))),
      MyTextField(
          padding: EdgeInsets.only(top: 20),
          onChanged: (String url) {
            setState(() {
              PlayerPrefs.sabApiKey = url;
              this
                  .widget
                  .prefs
                  .setString(PlayerPrefs.sabApiKeyKey, PlayerPrefs.sabApiKey);
            });
          },
          autocorrect: false,
          decoration: InputDecoration(
              labelText: 'Api key',
              border: OutlineInputBorder(),
              hintText: 'Api key'),
          text: PlayerPrefs.sabApiKey),
      MyTextField(
          padding: EdgeInsets.only(top: 20),
          onChanged: (String url) {
            setState(() {
              PlayerPrefs.sabURL = url;
              this
                  .widget
                  .prefs
                  .setString(PlayerPrefs.sabURLKey, PlayerPrefs.sabURL);
            });
          },
          autocorrect: false,
          decoration: InputDecoration(
              labelText: 'Sabnzbd URL',
              border: OutlineInputBorder(),
              hintText: 'Sabnzbd URL'),
          text: PlayerPrefs.sabURL),
    ]);
  }
}
