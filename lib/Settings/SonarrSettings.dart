import 'dart:convert';
import 'dart:io';

import 'package:Nutarr/Settings/TextAndDropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../PlayerPrefs.dart';
import 'MyTextField.dart';

class SonarrSettings extends StatefulWidget {
  final SharedPreferences prefs;

  SonarrSettings({Key key, this.prefs}) : super(key:key);

  Map<String, dynamic> mapLang;
  List<DropdownMenuItem<String>> lang = <String>["English","French","Spanish","German","Italian","Danish","Dutch","Japanese","Icelandic","Chinese","Russian","Polish","Vietnamese","Swedish","Norwegian","Finnish","Turkish","Portuguese","Flemish","Greek","Korean","Hungarian","Hebrew","Lithuanian","Czech","Hindi","Romanian","Thai","Bulgarian"
  ].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value, style: TextStyle(color: Colors.white)),
    );
  }).toList();
  String currLang;

  void UpdateLang() async {
    String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

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
      throw Exception('put language failed sonarr');
    }
  }

  @override
  SonarrSettingsState createState() => SonarrSettingsState();
}

class SonarrSettingsState extends State<SonarrSettings> {
  String defaultProfile;
  String currRootFolder;
  String uhdProfile;

  List<DropdownMenuItem<String>> itemsRootFolder;
  List<DropdownMenuItem<String>> items;
  bool showAdvanced;

  List<dynamic> profiles;

  void FetchQualityProfiles() async {
    String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

    if (url == null || apiKey == "")
      return;

    var response = await http.get(
        '$url/api/v3/qualityprofile',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> list = json.decode(response.body);
      this.profiles = list;
      defaultProfile = list
          .where((element) => element["id"] == PlayerPrefs.sonarrDefaultProfile)
          .toList()[0]["name"];

      uhdProfile = list
          .where((element) => element["id"] == PlayerPrefs.sonarrUhdProfile)
          .toList()[0]["name"];

      List<String> profiles = <String>[];
      for (dynamic profile in list) profiles.add(profile["name"]);
      items = profiles.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white)),
        );
      }).toList();
      setState(() {});
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('fetch quality profile sonarr failed');
    }
  }

  void FetchNamingFormat() async {
    String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

    if (url == null || apiKey == "")
      return;

    var response = await http.get(
        '$url/api/v3/config/naming',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> map = json.decode(response.body);
      if (PlayerPrefs.sonarrFolderNamingFormat == null ||
          PlayerPrefs.sonarrFolderNamingFormat != map['standardEpisodeFormat'])
        PlayerPrefs.sonarrFolderNamingFormat = map['standardEpisodeFormat'];
      setState(() {});
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('ftech quality profile failed sonarr');
    }
  }

  void FetchRootFolder() async {
    String url = PlayerPrefs.sonarrURL, apiKey = PlayerPrefs.sonarrApiKey;

    if (url == null || apiKey == "")
      return;

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
              child: Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white)),
            );
          }).toList();

      if (PlayerPrefs.sonarrDlPath == null || PlayerPrefs.sonarrDlPath == "")
        PlayerPrefs.sonarrDlPath = rootFoldersString[0];
      currRootFolder = PlayerPrefs.sonarrDlPath;
      setState(() {});
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('fetch quality profile failed sonarr');
    }
  }

  FetchAll()
  {
    FetchNamingFormat();
    FetchQualityProfiles();
    FetchRootFolder();
  }

  ChangeAdvanced()
  {
    setState(() {
      showAdvanced = !showAdvanced;
    });
  }

  @override
  void initState() {
    super.initState();
    showAdvanced = PlayerPrefs.showAdvancedSettings;
    FetchAll();
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: EdgeInsets.only(top: 20),
        child: Column(children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sonarr settings',
                style: TextStyle(fontSize: 30),
              )),
          MyTextField(
                padding: EdgeInsets.only(top: 20),
                  onChanged: (String url) {
                    setState(() {
                      PlayerPrefs.sonarrApiKey = url;
                      this.widget.prefs.setString(PlayerPrefs.sonarrApiKeyKey, PlayerPrefs.sonarrApiKey);
                    });
                  },
                  autocorrect: false,
                  decoration: InputDecoration(
                      labelText: 'Api key',
                      border: OutlineInputBorder(),
                      hintText: 'Api key'),
                  text: PlayerPrefs.sonarrApiKey),
          MyTextField(
                padding: EdgeInsets.only(top: 20),
                  onChanged: (String url) {
                    setState(() {
                      PlayerPrefs.sonarrURL = url;
                      this.widget.prefs.setString(PlayerPrefs.sonarrURLKey, PlayerPrefs.sonarrURL);
                    });
                  },
                  autocorrect: false,
                  decoration: InputDecoration(
                      labelText: 'Sonarr URL',
                      border: OutlineInputBorder(),
                      hintText: 'Sonarr URL'),
                  text: PlayerPrefs.radarrURL),
          Container(
              child: showAdvanced ? Column(
                  children: <Widget>[
                    TextAndDropdown(
                      padding: EdgeInsets.only(top: 20),
                      title: 'Default profile',
                      value: defaultProfile,
                      onChanged: (String newValue){
                        defaultProfile = newValue;
                        PlayerPrefs.sonarrDefaultProfile = profiles.where((element) => element["name"] == newValue).toList()[0]["id"];
                        this.widget.prefs.setInt(PlayerPrefs.sonarrDefaultProfileKey, PlayerPrefs.sonarrDefaultProfile);
                      },
                      items: items,
                    ),
                    TextAndDropdown(
                        padding: EdgeInsets.only(top: 20),
                        title: '4K profile',
                        value: uhdProfile,
                        onChanged: (String newValue){
                          uhdProfile = newValue;
                          PlayerPrefs.sonarrUhdProfile = profiles.where((element) => element["name"] == newValue).toList()[0]["id"];
                          this.widget.prefs.setInt(PlayerPrefs.sonarrUhdProfileKey, PlayerPrefs.sonarrUhdProfile);
                        },
                        items: items
                    ),
                    TextAndDropdown(
                        padding: EdgeInsets.only(top: 20),
                        title: 'Root folder',
                        value: currRootFolder,
                        onChanged: (String newValue){
                          currRootFolder = newValue;
                          PlayerPrefs.sonarrDlPath = newValue;
                        },
                        items: itemsRootFolder,
                      stack: false
                    ),
                  ]
              ) : Container()
          ),
        ]));
  }
}
