import 'package:app_segna_ore/providers/worktime.dart';
import 'package:app_segna_ore/screens/detail/task_detail.dart';
import 'package:app_segna_ore/screens/detail/worktime_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/task.dart';

class WorkTimeItem extends StatefulWidget {
  final WorkTime workTime;

  WorkTimeItem(
    this.workTime,
  );

  @override
  State<WorkTimeItem> createState() => _WorkTimeItemState();
}

format(Duration d) =>
    d.toString().split('.').first.padLeft(8, "0").substring(0, 5);

class _WorkTimeItemState extends State<WorkTimeItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          WorkTimeDetailScreen.routeName,
          arguments: widget.workTime.id,
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            leading: Icon(
              Icons.alarm,
              color: Theme.of(context).colorScheme.secondary,
              size: 40,
            ),
            title: Text(
              DateFormat('dd/MM/yyyy').format(widget.workTime.data) ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.workTime.commessa.description),
                    Text(widget.workTime.note),
                  ],
                ),
                Container(
                  child: Column(
                    children: [
                      Text(
                        'Lavorato',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        format(widget.workTime.tempoLavorato),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Text(
                        'Fatturato',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        format(widget.workTime.tempoFatturato),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
