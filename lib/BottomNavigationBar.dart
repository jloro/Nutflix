import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;


class MyBottomNavigationBar extends StatefulWidget {
  MyBottomNavigationBar(
      {Key key, @required this.currentIndex, @required this.onSelectTab})
      : super(key: key);

  final int currentIndex;

  final ValueChanged<int> onSelectTab;

  @override
  MyBottomNavigationBarState createState() => MyBottomNavigationBarState();
}

class MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _downloads = 0;

  void updateDownloads(int val) {
    setState(() {
      _downloads = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
			height: kIsWeb ? 75 : null,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
      //backgroundColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.movie),
          label: 'Movies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.theaters),
          label: 'Series',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: <Widget>[
              Icon(Icons.get_app),
              _downloads == 0
                  ? UnconstrainedBox()
                  : Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$_downloads',
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
            ],
          ),
          label: 'Downloads',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: this.widget.currentIndex,
      selectedItemColor: Colors.amber[800],
      onTap: this.widget.onSelectTab,
    ));
  }
}
