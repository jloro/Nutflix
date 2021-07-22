import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String text;
  final Function(String) onChanged;
  final bool autocorrect;
  final InputDecoration decoration;
  final EdgeInsetsGeometry padding;
  TextField textfield;

  TextEditingController controller;

  MyTextField({this.text, this.onChanged, this.autocorrect, this.decoration, this.padding});

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {

  @override
  void initState() {
    this.widget.controller = TextEditingController(text: this.widget.text);
    this.widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: this.widget.controller.text.length));

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding : this.widget.padding ?? EdgeInsets.zero,
      child: TextField(
        onChanged: this.widget.onChanged,
        autocorrect: this.widget.autocorrect,
        decoration: this.widget.decoration,
        controller: this.widget.controller,
    ));
  }
}
