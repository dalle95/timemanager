import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  LoadingIndicator(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [CircularProgressIndicator(), Text(message)],
      ),
    );
  }
}
