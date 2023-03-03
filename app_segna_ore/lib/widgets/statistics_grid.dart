import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/worktimes.dart';
import '../widgets/statistics_item.dart';

class StatisticsGrid extends StatelessWidget {
  final DateTime mese;

  StatisticsGrid(this.mese);

  @override
  Widget build(BuildContext context) {
    List<Map> impostaMese(DateTime mese) {
      List<Map> giorniLavorativi = [];
      DateTime indexDay = DateTime(mese.year, mese.month, 1);
      if (indexDay.weekday != 1 && indexDay.weekday < 6) {
        giorniLavorativi = List.generate(
            indexDay.weekday - 1,
            (index) => {
                  "numeroGiorno": "",
                  "oreRegistrate": "",
                });
      }

      for (indexDay;
          indexDay.month == mese.month;
          indexDay = indexDay.add(const Duration(days: 1))) {
        if (indexDay.weekday < 6) {
          giorniLavorativi.add({
            "numeroGiorno": indexDay.toIso8601String(),
            "oreRegistrate":
                Provider.of<WorkTimes>(context).oreSegnate(indexDay).toString(),
          });
        }
      }
      return giorniLavorativi;
    }

    final List<Map> giorniLavorativi = impostaMese(mese);

    return GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisExtent: 80,
          maxCrossAxisExtent: 60,
          //childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: giorniLavorativi.length,
        itemBuilder: (BuildContext ctx, index) {
          return StatisticsItem(
            giorniLavorativi[index]['numeroGiorno'],
            giorniLavorativi[index]['oreRegistrate'],
          );
        });
  }
}