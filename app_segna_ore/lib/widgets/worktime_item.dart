import 'package:app_segna_ore/providers/worktime.dart';
import 'package:app_segna_ore/screens/detail/task_detail.dart';
import 'package:app_segna_ore/screens/detail/worktime_detail.dart';
import 'package:flutter/material.dart';

import '../providers/task.dart';

class WorkTimeItem extends StatefulWidget {
  final WorkTime workTime;

  WorkTimeItem(
    this.workTime,
  );

  @override
  State<WorkTimeItem> createState() => _WorkTimeItemState();
}

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
              Icons.work,
              color: Theme.of(context).accentColor,
              size: 40,
            ),
            title: Text(
              widget.workTime.code ?? '',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.workTime.commessa.description),
                Text('Task: ${widget.workTime.task.code}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
