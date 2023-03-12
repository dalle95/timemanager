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
    var mediaQuery = MediaQuery.of(context);

    final List<Map> giorniLavorativi =
        Provider.of<WorkTimes>(context, listen: false).impostaMese(mese);

    return GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisExtent: mediaQuery.size.height * 0.1,
          crossAxisSpacing: mediaQuery.size.width * 0.02,
          mainAxisSpacing: mediaQuery.size.height * 0.01,
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
