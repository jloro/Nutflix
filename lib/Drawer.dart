import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nutflix/routes.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

Future<bool> ResfreshLibrary() async
{
  var response = await http.post('https://80-119-155-24.3b345ddff28e4d97b2fbb3bff9c23164.plex.direct:25273/library/sections/1/refresh?X-Plex-Token=zj4gxyeeWyCzsPsKp3ki');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return true;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Movie');
  }
}

void ChangeRoute(BuildContext context, String route)
{
  if (ModalRoute.of(context).settings.name == route)
    return;
  Navigator.pop(context);
  Navigator.pushReplacementNamed(context, route);
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child : Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child : Align(
                          alignment: Alignment.topLeft,
                          child: Text('Menu'),
                        )
                      ),
                      Expanded(
                          child : Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                await ResfreshLibrary();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.pink)
                              ),
                              child: const Text('Refresh', style: TextStyle(fontSize: 20)),
                            ),
                          )
                      )
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Search'),
                onTap: (){
                  ChangeRoute(context, Routes.search);
                },
              ),
              ListTile(
                title: Text('Movies'),
                onTap: (){
                  ChangeRoute(context, Routes.movies);
                },
              )
            ]
        )

    );
  }

}