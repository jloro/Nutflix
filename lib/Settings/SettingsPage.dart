import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:Nutarr/Settings/RadarrSettings.dart';
import 'package:Nutarr/Settings/SabSettings.dart';
import 'package:Nutarr/Settings/SonarrSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Nutarr/PlayerPrefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'MyTextField.dart';

class Settings extends StatefulWidget {
  static const String route = '/settings';
  static const int index = 4;

  final SharedPreferences prefs;
  final void Function() reload;

  Settings({Key key, @required this.reload, @required this.prefs}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  RadarrSettings _radarrSettings;
  GlobalKey<RadarrSettingsState> _keyRadarr = GlobalKey<RadarrSettingsState>();
  SonarrSettings _sonarrSettings;
  GlobalKey<SonarrSettingsState> _keySonarr = GlobalKey<SonarrSettingsState>();

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
              text: "This app is intended for personal and non commercial use only.\nAll movies metadata and poster are from TMDB (",
              style: TextStyle(color: Colors.white)
            ),
            WidgetSpan(
                child: InkWell(
                    child: new Text(
                      ' https://www.themoviedb.org/ ',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                    onTap: () => launch('https://www.themoviedb.org/'))),
            TextSpan(
              style: TextStyle(color: Colors.white),
              text: ") and used in agreement with their terms of use.\nAll the movies poster belongs to their respective owners.\n\nThis app doesn't allow nor promote illegal download of copyrighted content, only use it for movies for which you have rights according to your country's legislation.\n\nWe don't store any content, metadata or user information. This app is only an interface for third-parties services.",
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
      PlayerPrefs.Reset(this.widget.prefs);

      iconAdvanced = Icon(Icons.add_box);
      _radarrSettings.currLang = "English";
      _radarrSettings.UpdateLang();
    });
  }

  @override
  void initState() {
    super.initState();
    _radarrSettings = RadarrSettings(prefs: this.widget.prefs, key: _keyRadarr);
    _sonarrSettings = SonarrSettings(prefs: this.widget.prefs, key: _keySonarr);

    setState(() {
      iconAdvanced = PlayerPrefs.showAdvancedSettings ? Icon(Icons.indeterminate_check_box) : Icon(Icons.add_box);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          onPressed: () {
            setState(() {
              FocusScope.of(context).requestFocus(new FocusNode());
              final scaffold = ScaffoldMessenger.of(context);
              scaffold.showSnackBar(SnackBar(
                duration: Duration(milliseconds: 500),
                content: const Text('Settings changed'),
              ));

              this.widget.reload();
              _keyRadarr.currentState.FetchAll();
              _keySonarr.currentState.FetchAll();
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
                                this.widget.prefs.setBool(PlayerPrefs.showAdvancedSettingsKey, PlayerPrefs.showAdvancedSettings);
                                _keyRadarr.currentState.ChangeAdvanced();
                                _keySonarr.currentState.ChangeAdvanced();
                              });
                            },
                          )))
                ],
              ),
            )),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: PlayerPrefs.showAdvancedSettings ? 20 : 0, horizontal: 10),
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
                              onChanged: (bool newValue) {
                                setState(() {
                                  PlayerPrefs.statsForNerds = newValue;
                                  this.widget.prefs.setBool(PlayerPrefs.statsForNerdsKey, PlayerPrefs.statsForNerds);
                                });
                              },
                            ))
                      ]) : Container()),
                  _radarrSettings,
                  SabSettings(prefs: this.widget.prefs),
                  _sonarrSettings
                  // Padding(
                  //     padding: EdgeInsets.only(top: 40),
                  //     child: Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Text(
                  //           'Sonarr settings',
                  //           style: TextStyle(fontSize: 30),
                  //         ))),
                  // Padding(
                  //     padding: EdgeInsets.only(top: 20),
                  //     child: MyTextField(
                  //         onChanged: (String url) {
                  //           setState(() {
                  //             PlayerPrefs.sonarrApiKey = url;
                  //             this.widget.prefs.setString(PlayerPrefs.sonarrApiKeyKey, PlayerPrefs.sonarrApiKey);
                  //           });
                  //         },
                  //         autocorrect: false,
                  //         decoration: InputDecoration(
                  //             labelText: 'Api key',
                  //             border: OutlineInputBorder(),
                  //             hintText: 'Api key'),
                  //         text: PlayerPrefs.sonarrApiKey)),
                  // Padding(
                  //     padding: EdgeInsets.only(top: 20),
                  //     child: MyTextField(
                  //         onChanged: (String url) {
                  //           setState(() {
                  //             PlayerPrefs.sonarrURL = url;
                  //             this.widget.prefs.setString(PlayerPrefs.sonarrURLKey, PlayerPrefs.sonarrURL);
                  //           });
                  //         },
                  //         autocorrect: false,
                  //         decoration: InputDecoration(
                  //             labelText: 'Sonarr URL',
                  //             border: OutlineInputBorder(),
                  //             hintText: 'Sonarr URL'),
                  //         text: PlayerPrefs.sonarrURL)),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 40, right: 40, left: 40),
                  //   child: Container(
                  //     child: Row(
                  //       children: <Widget>[
                  //         Expanded(
                  //             child: Container(
                  //                 alignment: Alignment.centerLeft,
                  //                 child: TextButton(
                  //                   onPressed: () {
                  //                     showAlertDialogAbout(context);
                  //                   },
                  //                   child: RichText(
                  //                     text: TextSpan(
                  //                       children: [
                  //                         TextSpan(
                  //                           style: TextStyle(fontSize: 18, color: Colors.white),
                  //                           text: "about ",
                  //                         ),
                  //                         WidgetSpan(
                  //                           alignment:
                  //                           PlaceholderAlignment.middle,
                  //                           child: Icon(Icons.info,
                  //                               color: Colors.white),
                  //                         )
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ))),
                  //         Expanded(
                  //             child: Container(
                  //                 alignment: Alignment.centerRight,
                  //                 child: ElevatedButton(
                  //                   onPressed: () {
                  //                     showAlertDialogConfirm(context);
                  //                   },
                  //                   child: RichText(
                  //                     text: TextSpan(
                  //                       children: [
                  //                         TextSpan(
                  //                           style: TextStyle(fontSize: 18, color: Colors.white),
                  //                           text: "delete ",
                  //                         ),
                  //                         WidgetSpan(
                  //                           alignment:
                  //                           PlaceholderAlignment.middle,
                  //                           child: Icon(Icons.delete,
                  //                               color: Colors.white),
                  //                         )
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 )))
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ]))),
      ),
    );
  }
}