import 'package:app_segna_ore/widgets/worktime_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/worktimes.dart';

class WorkTimeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workTimesData = Provider.of<WorkTimes>(context);
    final workTimes = workTimesData.workTimes;

    return workTimes.isEmpty
        ? const Center(
            child: Text(
              'Non è stata registrata nessuna ora.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        : ListView.builder(
            itemCount: workTimes.length,
            itemBuilder: (ctx, i) => WorkTimeItem(workTimes[i]),
          );
  }
}
