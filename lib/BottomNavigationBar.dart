import 'package:Nutarr/DownloadNotif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;


class MyBottomNavigationBar extends StatefulWidget {
  final GlobalKey<DownloadNotifState> dlNotifKey;

  MyBottomNavigationBar(
      {Key key, @required this.currentIndex, @required this.onSelectTab, @required this.dlNotifKey})
      : super(key: key);

  final int currentIndex;

  final ValueChanged<int> onSelectTab;

  @override
  MyBottomNavigationBarState createState() => MyBottomNavigationBarState();
}

class MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
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
          icon: DownloadNotif(key: this.widget.dlNotifKey),
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
