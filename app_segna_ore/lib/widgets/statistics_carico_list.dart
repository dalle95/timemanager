import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/worktimes.dart';
import '../widgets/statistics_carico_item.dart';

class StatisticsCaricoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workTimesData = Provider.of<WorkTimes>(context, listen: false);
    final workTimes = workTimesData.workTimes;

    final List<Map> caricoXCommessa =
        Provider.of<WorkTimes>(context, listen: false).calcolaCarichi();

    return caricoXCommessa.isEmpty
        ? const Center(
            child: Text('Non sono presenti ore caricate.'),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: caricoXCommessa.length,
            itemBuilder: (BuildContext ctx, index) {
              return StatisticsCaricoItem(
                caricoXCommessa[index]['commessa'],
                caricoXCommessa[index]['oreRegistrate'].toString(),
                caricoXCommessa[index]['caricoPercentuale'],
              );
            });
  }
}
