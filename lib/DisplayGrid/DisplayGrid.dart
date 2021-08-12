import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DisplayGridCard.dart';
import 'DisplayGridObject.dart';

class DisplayGrid extends StatefulWidget {
  final AsyncSnapshot<List<DisplayGridObject>> snapshot;
  final void Function(BuildContext context, DisplayGridObject object) onTap;

  DisplayGrid({this.snapshot, this.onTap, Key key}) : super(key:key);
  @override
  _DisplayGridState createState() => _DisplayGridState();
}

class _DisplayGridState extends State<DisplayGrid> {
  List<String> _ids;

  void onDelete(String value) {
    _ids.add(value);
  }

  void setStateForChildren() {
    setState(() {

    });
  }

  ScrollController _scrollController;

  @override
  void initState() {
    _ids = List.empty(growable: true);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> toRemove = List.empty(growable: true);
    for (String id in _ids) {
      if (this.widget.snapshot.data.indexWhere((element) => element.GetIMDBId() == id) == -1)
        toRemove.add(id);
    }
    _ids.removeWhere((element) => toRemove.contains(element));

    return ListView(
      controller: _scrollController,
      children: [
        GridView.builder(
          controller: _scrollController,
            shrinkWrap: true,
            // primary: true,
            itemCount: this.widget.snapshot.data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                childAspectRatio: 2 / 3,
                crossAxisCount: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height > 1 ? 5 : 3
            ),
            itemBuilder: (context, i) {
              // if (i < this.widget.snapshot.data.length)
                return DisplayGridCard(
                object: this.widget.snapshot.data[i],
                onTap: this.widget.onTap,
                onDelete: onDelete,
                deleting: _ids.contains(this.widget.snapshot.data[i].GetIMDBId()),
                setState: setStateForChildren,
              );
              // else
              //   return Container(
              //     child: Card(
              //       clipBehavior: Clip.antiAlias,
              //       semanticContainer: true,
              //       elevation: 5,
              //       child: GridTile(
              //           // child: Column(
              //           //   children: [
              //           //     Text('Hold to remove'),
              //           //     Text('Tap to show info'),
              //           //     Text('Slide to quick info'),
              //           //   ]
              //           // )
              //     )
              //   ));
            }
        ),
        Container(
          child: Column(
            children: [
              Text('Hold to delete'),
              Text('Tap to show info'),
              Text('Slide to show quick info'),
            ]
          )
        )
      ],
    );
  }
}
