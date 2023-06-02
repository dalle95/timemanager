import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/worktime.dart';

import '../../providers/worktimes.dart';

import '../items/worktime_item.dart';

class WorkTimeDayList extends StatefulWidget {
  final List<WorkTime> workTimes;

  const WorkTimeDayList({
    super.key,
    required this.workTimes,
  });

  @override
  State<WorkTimeDayList> createState() => _WorkTimeDayListState();
}

class _WorkTimeDayListState extends State<WorkTimeDayList> {
  @override
  Widget build(BuildContext context) {
    final workTimes = widget.workTimes;

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
            itemBuilder: (ctx, i) {
              bool isSameDate = true;
              final DateTime date = workTimes[i].data;
              if (i == 0) {
                isSameDate = false;
              } else {
                final DateTime prevDate = workTimes[i - 1].data;
                isSameDate = date == prevDate;
              }
              if (i == 0 || !(isSameDate)) {
                return Column(children: [
                  Card(
                    color: Theme.of(context).colorScheme.secondary,
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      visualDensity: const VisualDensity(vertical: -3),
                      title: Text(
                        DateFormat('dd/MM/yyyy').format(workTimes[i].data),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Consumer<WorkTimes>(
                        builder: (context, value, child) => Text(
                          'Ore lavorate: ${Provider.of<WorkTimes>(context, listen: false).oreSegnate(workTimes[i].data)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  WorkTimeItem(workTimes[i]),
                ]);
              } else {
                return WorkTimeItem(workTimes[i]);
              }
            },
          );
  }
}
