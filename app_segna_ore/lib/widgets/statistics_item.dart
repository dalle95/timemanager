import 'package:flutter/material.dart';

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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
          Container(
            width: double.infinity,
            height: 58,
            // decoration: BoxDecoration(
            //   color: oreSegnate != ''
            //       ? double.parse(oreSegnate) != 8.0
            //           ? Colors.red[400]
            //           : Colors.green[400]
            //       : Colors.white,
            //   borderRadius: const BorderRadius.only(
            //     bottomLeft: Radius.circular(10),
            //     bottomRight: Radius.circular(10),
            //   ),
            // ),
            child: Center(
              child: Text(
                oreSegnate != ''
                    ? double.parse(oreSegnate)
                        .toStringAsFixed(1)
                        .replaceFirst(RegExp(r'\.?0*$'), '')
                    : '',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: oreSegnate != ''
                      ? double.parse(oreSegnate) == 0
                          ? Colors.red[400]
                          : double.parse(oreSegnate) == 8.0
                              ? Colors.green[400]
                              : Colors.orange
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
