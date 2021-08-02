import 'dart:convert';
import 'dart:io';

import 'package:Nutarr/Settings/TextAndDropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../PlayerPrefs.dart';
import 'MyTextField.dart';

class RadarrSettings extends StatefulWidget {
  final SharedPreferences prefs;

  RadarrSettings({Key key, this.prefs}) : super(key:key);

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
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (url == null || apiKey == "")
      return;

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

  @override
  RadarrSettingsState createState() => RadarrSettingsState();
}

class RadarrSettingsState extends State<RadarrSettings> {
  String defaultProfile;
  String currRootFolder;
  String uhdProfile;

  List<DropdownMenuItem<String>> itemsRootFolder;
  List<DropdownMenuItem<String>> items;
  bool showAdvanced;

  List<dynamic> profiles;

  void FetchQualityProfiles() async {
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (PlayerPrefs.radarrURL == null || PlayerPrefs.radarrURL == "")
      return;
    else if (PlayerPrefs.radarrApiKey == null || PlayerPrefs.radarrApiKey == "")
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
          .where((element) => element["id"] == PlayerPrefs.radarrDefaultProfile)
          .toList()[0]["name"];

      uhdProfile = list
          .where((element) => element["id"] == PlayerPrefs.radarrUhdProfile)
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
      throw Exception('fetch quality profile failed');
    }
  }
  void FetchNamingFormat() async {
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (PlayerPrefs.radarrURL == null || PlayerPrefs.radarrURL == "")
      return;
    else if (PlayerPrefs.radarrApiKey == null || PlayerPrefs.radarrApiKey == "")
      return;

    var response = await http.get(
        '$url/api/v3/config/naming',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> map = json.decode(response.body);
      if (PlayerPrefs.radarrFolderNamingFormat == null ||
          PlayerPrefs.radarrFolderNamingFormat != map['movieFolderFormat'])
        PlayerPrefs.radarrFolderNamingFormat = map['movieFolderFormat'];
      setState(() {});
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('ftech quality profile failed');
    }
  }
  void FetchLanguage() async {
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (PlayerPrefs.radarrURL == null || PlayerPrefs.radarrURL == "")
      return;
    else if (PlayerPrefs.radarrApiKey == null || PlayerPrefs.radarrApiKey == "")
      return;

    var response = await http.get('$url/api/v3/config/ui',
        headers: {HttpHeaders.authorizationHeader: apiKey});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      this.widget.mapLang = json.decode(response.body);
      this.widget.currLang = this.widget.lang[this.widget.mapLang['movieInfoLanguage'] - 1].value;
      setState(() {});
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('fetch language failed');
    }
  }
  void FetchRootFolder() async {
    String url = PlayerPrefs.radarrURL, apiKey = PlayerPrefs.radarrApiKey;

    if (PlayerPrefs.radarrURL == null || PlayerPrefs.radarrURL == "")
      return;
    else if (PlayerPrefs.radarrApiKey == null || PlayerPrefs.radarrApiKey == "")
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

      if (PlayerPrefs.radarrDlPath == null || PlayerPrefs.radarrDlPath == "")
        PlayerPrefs.radarrDlPath = rootFoldersString[0];
      currRootFolder = PlayerPrefs.radarrDlPath;
      setState(() {});
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('fetch quality profile failed');
    }
  }

  FetchAll()
  {
      FetchLanguage();
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
        child: Column(children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Radarr settings',
                style: TextStyle(fontSize: 30),
              )),
          MyTextField(
                padding: EdgeInsets.only(top: 20),
                  onChanged: (String url) {
                    setState(() {
                      PlayerPrefs.radarrApiKey = url;
                      this.widget.prefs.setString(PlayerPrefs.radarrApiKeyKey, PlayerPrefs.radarrApiKey);
                    });
                  },
                  autocorrect: false,
                  decoration: InputDecoration(
                      labelText: 'Api key',
                      border: OutlineInputBorder(),
                      hintText: 'Api key'),
                  text: PlayerPrefs.radarrApiKey),
          MyTextField(
                padding: EdgeInsets.only(top: 20),
                  onChanged: (String url) {
                    setState(() {
                      PlayerPrefs.radarrURL = url;
                      this.widget.prefs.setString(PlayerPrefs.radarrURLKey, PlayerPrefs.radarrURL);
                    });
                  },
                  autocorrect: false,
                  decoration: InputDecoration(
                      labelText: 'Radarr URL',
                      border: OutlineInputBorder(),
                      hintText: 'Radarr URL'),
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
                        PlayerPrefs.radarrDefaultProfile = profiles.where((element) => element["name"] == newValue).toList()[0]["id"];
                        this.widget.prefs.setInt(PlayerPrefs.radarrDefaultProfileKey, PlayerPrefs.radarrDefaultProfile);
                      },
                      items: items,
                    ),
                    TextAndDropdown(
                        padding: EdgeInsets.only(top: 20),
                        title: '4K profile',
                        value: uhdProfile,
                        onChanged: (String newValue){
                          uhdProfile = newValue;
                          PlayerPrefs.radarrUhdProfile = profiles.where((element) => element["name"] == newValue).toList()[0]["id"];
                          this.widget.prefs.setInt(PlayerPrefs.radarrUhdProfileKey, PlayerPrefs.radarrUhdProfile);
                        },
                        items: items
                    ),
                    TextAndDropdown(
                        padding: EdgeInsets.only(top: 20),
                        title: 'Movie info language',
                        value: this.widget.currLang,
                        onChanged: (String newValue){
                          this.widget.currLang = newValue;
                          this.widget.UpdateLang();
                        },
                        items: this.widget.lang
                    ),
                    TextAndDropdown(
                        padding: EdgeInsets.only(top: 20),
                        title: 'Root folder',
                        value: currRootFolder,
                        onChanged: (String newValue){
                          currRootFolder = newValue;
                          PlayerPrefs.radarrDlPath = newValue;
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
