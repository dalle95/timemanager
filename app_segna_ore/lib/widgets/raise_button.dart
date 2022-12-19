import 'package:flutter/material.dart';

class RaiseButton extends StatelessWidget {
  final Function handler;
  final Widget child;
  final Color onPrimary;
  final Color primary;

  RaiseButton(@required this.handler, @required this.child,
      [this.primary, this.onPrimary]);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      onPrimary: onPrimary,
      primary: primary,
      minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );
    return ElevatedButton(
      style: raisedButtonStyle,
      onPressed: handler,
      child: child,
    );
  }
}
