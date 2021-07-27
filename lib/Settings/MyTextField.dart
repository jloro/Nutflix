import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  String text;
  final Function(String) onChanged;
  final bool autocorrect;
  final InputDecoration decoration;
  final EdgeInsetsGeometry padding;

  MyTextField({this.text, this.onChanged, this.autocorrect, this.decoration, this.padding});

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  TextEditingController controller;
  ValueNotifier<String> _notifier;

  void Refresh()
  {
    setState(() {
      controller = TextEditingController(text: this.widget.text);
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
    });
  }

  @override
  void initState() {
    _notifier = ValueNotifier<String>(this.widget.text);
    _notifier.addListener(Refresh);
    controller = TextEditingController(text: this.widget.text);
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));

    // MyTextFieldsController.instance.callbacks.add(Refresh);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _notifier.value = this.widget.text;
    return Padding(
      padding : this.widget.padding ?? EdgeInsets.zero,
      child: TextField(
        onChanged: this.widget.onChanged,
        autocorrect: this.widget.autocorrect,
        decoration: this.widget.decoration,
        controller: controller,
    ));
  }
}
