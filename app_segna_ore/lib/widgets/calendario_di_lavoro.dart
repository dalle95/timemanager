import 'dart:math';

import 'package:app_segna_ore/providers/worktimes.dart';
import 'package:app_segna_ore/widgets/statistics_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarioDiLavoro extends StatelessWidget {
  const CalendarioDiLavoro({
    Key? key,
    required this.mediaQuery,
    required DateTime mese,
  })  : _mese = mese,
        super(key: key);

  final MediaQueryData mediaQuery;
  final DateTime _mese;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: max(
        (Provider.of<WorkTimes>(context).impostaMese(_mese).length / 5 == 4.0
                    ? 4
                    : 5) *
                mediaQuery.size.width *
                0.25 +
            mediaQuery.size.width * 0.3,
        mediaQuery.size.width * 0.3,
      ),
      width: mediaQuery.size.width * 0.4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
              ),
              alignment: Alignment.center,
              child: const Text(
                'Calendario',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
              ),
              child: SizedBox(
                width: mediaQuery.size.width * 0.72,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Lu',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ma',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Me',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Gi',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ve',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: mediaQuery.size.height * 0.6,
              width: mediaQuery.size.width * 0.8,
              child: StatisticsGrid(_mese),
            ),
          ],
        ),
      ),
    );
  }
}
