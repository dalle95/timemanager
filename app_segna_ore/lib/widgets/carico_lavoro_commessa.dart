import 'dart:math';

import 'package:app_segna_ore/providers/worktimes.dart';
import 'package:app_segna_ore/widgets/lists/statistics_carico_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CaricoLavoroPerCommessa extends StatelessWidget {
  const CaricoLavoroPerCommessa({
    Key? key,
    required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: max(
        Provider.of<WorkTimes>(context).calcolaCarichi().length * 60.0 + 60.0,
        120,
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
          left: 15,
          right: 15,
          top: 20,
        ),
        child: Column(
          children: [
            const Text(
              'Carico di lavoro per commessa:',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: StatisticsCaricoList(),
            ),
          ],
        ),
      ),
    );
  }
}
