import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../PlayerPrefs.dart';

class TextAndDropdown extends StatefulWidget {
  final String title;
  final EdgeInsetsGeometry padding;
  String value;
  final void Function(String newValue) onChanged;
  final List<DropdownMenuItem<String>> items;
  final bool stack;

  TextAndDropdown(
      {Key key,
      this.title,
      this.padding,
      this.value,
      this.onChanged,
      this.items,
      this.stack = true})
      : super(key: key);

  @override
  _TextAndDropdownState createState() => _TextAndDropdownState();
}

class _TextAndDropdownState extends State<TextAndDropdown> {
  @override
  Widget build(BuildContext context) {
    return this.widget.stack ?
    Padding(
      padding: this.widget.padding ?? EdgeInsets.zero,
      child: Align(
          alignment: Alignment.centerRight,
          child: Stack(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  this.widget.title,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: this.widget.value != null
                    ? DropdownButton<String>(
                        value: this.widget.value,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(fontSize: 20),
                        underline: Container(
                          height: 2,
                          color: Colors.red,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            this.widget.value = newValue;
                            setState(() {
                              this.widget.onChanged(newValue);
                            });
                          });
                        },
                        items: this.widget.items,
                      )
                    : CircularProgressIndicator())
          ])),
    ) :
    Column(
      children: [
        Padding(
          padding: this.widget.padding ?? EdgeInsets.zero,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              this.widget.title,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 10),
            child: Align(
                alignment: Alignment.centerRight,
                child: this.widget.value != null
                    ? DropdownButton<String>(
                  isExpanded: true,
                  value: this.widget.value,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(fontSize: 20),
                  underline: Container(
                    height: 2,
                    color: Colors.red,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      this.widget.value = newValue;
                      setState(() {
                        this.widget.onChanged(newValue);
                      });
                    });
                  },
                  items: this.widget.items,
                )
                    : CircularProgressIndicator())),
      ]
    );
  }
}
