import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DownloadNotif extends StatefulWidget {

  DownloadNotif({Key key}) : super(key:key);
  @override
  DownloadNotifState createState() => DownloadNotifState();
}

class DownloadNotifState extends State<DownloadNotif> {
  int _downloads = 0;

  void updateDownloads(int val) {
    setState(() {
      _downloads = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}
