import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({
    Key? key,
    required this.child,
    required this.value,
    this.color,
  }) : super(key: key);

  final Widget child;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisAlignment: Alignment.center,
      children: [
        child,
        Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(2.0),
          // color: Theme.of(context).accentColor,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: color ?? Theme.of(context).colorScheme.secondary,
          ),
          constraints: const BoxConstraints(
            minWidth: 20,
            minHeight: 20,
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
