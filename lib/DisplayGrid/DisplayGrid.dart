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
            itemCount: this.widget.snapshot.data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                childAspectRatio: 2 / 3,
                crossAxisCount: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height > 1 ? 5 : 3
            ),
            itemBuilder: (context, i) {
                return DisplayGridCard(
                object: this.widget.snapshot.data[i],
                onTap: this.widget.onTap,
                onDelete: onDelete,
                deleting: _ids.contains(this.widget.snapshot.data[i].GetIMDBId()),
                setState: setStateForChildren,
              );
            }
        ),
        Container(
          padding : EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      alignment:
                      PlaceholderAlignment.middle,
                      child: Icon(Icons.delete,
                          color: Colors.white),
                    ),
                    TextSpan(text: '  Hold to delete'),
                  ]
                ),
              ),
              RichText(
                text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment:
                        PlaceholderAlignment.middle,
                        child: Icon(Icons.info,
                            color: Colors.white),
                      ),
                      TextSpan(text: '  Tap to show info'),
                    ]
                ),
              ),
              RichText(
                text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment:
                        PlaceholderAlignment.middle,
                        child: Icon(Icons.info,
                            color: Colors.white),
                      ),
                      TextSpan(text: '  Slide to show quick info'),
                    ]
                ),
              ),
            ]
          )
        )
      ],
    );
  }
}
