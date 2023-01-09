import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class StatisticsItem extends StatelessWidget {
  final String giorno;
  final String oreSegnate;

  StatisticsItem(
    this.giorno,
    this.oreSegnate,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border.all(color: Colors.blueAccent),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              color: giorno != ""
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Center(
                child: Text(
              giorno,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ),
          Container(
            width: double.infinity,
            height: 58,
            child: Center(child: Text(oreSegnate)),
          ),
        ],
      ),
    );
  }
}
