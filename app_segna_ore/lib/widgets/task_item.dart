import 'package:flutter/material.dart';

import '../providers/task.dart';
import '../screens/detail/task_detail.dart';

class TaskItem extends StatefulWidget {
  final Task task;

  TaskItem(
    this.task,
  );

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          TaskDetailScreen.routeName,
          arguments: widget.task.id,
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
              widget.task.description ?? '',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.task.code),
                Text('Commessa: ${widget.task.commessa.description}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
