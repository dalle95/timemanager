import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final Function handler;
  final Widget child;
  final Color backgroundColor;

  FlatButton(@required this.handler, @required this.child,
      [this.backgroundColor]);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      foregroundColor: Colors.black87,
      backgroundColor: backgroundColor ?? Colors.grey[300],
      minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(2.0),
        ),
      ),
    );

    return TextButton(
      style: flatButtonStyle,
      onPressed: handler,
      child: child,
    );
  }
}
