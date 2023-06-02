import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../providers/worktimes.dart';
import '../items/statistics_carico_item.dart';

class StatisticsCaricoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map> caricoXCommessa =
        Provider.of<WorkTimes>(context).calcolaCarichi();

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
