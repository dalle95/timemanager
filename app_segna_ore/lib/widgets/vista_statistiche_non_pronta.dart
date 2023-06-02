import 'package:flutter/material.dart';

class VistaStatisticheNonPronta extends StatelessWidget {
  const VistaStatisticheNonPronta({
    Key? key,
    required this.mediaQuery,
    required this.message,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  final message;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          alignment: Alignment.center,
          height: mediaQuery.size.height * 0.70,
          width: mediaQuery.size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Text(message),
          ),
        ),
      ),
    );
  }
}
