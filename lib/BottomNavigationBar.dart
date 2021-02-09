import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  MyBottomNavigationBar(
      {@required this.currentIndex, @required this.onSelectTab});

  final int currentIndex;

  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.movie),
          label: 'Movies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.amber[800],
      onTap: onSelectTab,
    );
  }
}
