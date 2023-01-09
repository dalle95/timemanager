import 'package:flutter/material.dart';

import '../providers/task.dart';
import '../screens/detail/task_detail.dart';
import '../providers/actiontype.dart';
import '../providers/box.dart';
import '../providers/material.dart' as carl;

class TaskItem extends StatefulWidget {
  final Task task;
  final String function;

  TaskItem(
    this.task,
    this.function,
  );

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.function == 'list') {
          Navigator.of(context).pushNamed(
            TaskDetailScreen.routeName,
            arguments: widget.task.id,
          );
        } else {
          Navigator.of(context).pop(
            {
              'id': widget.task.id,
              'code': widget.task.code,
              'description': widget.task.description,
              'statusCode': widget.task.statusCode,
              'actionType': ActionType(
                id: widget.task.actionType.id,
                code: widget.task.actionType.code,
                description: widget.task.actionType.description,
              ),
              'cliente': Box(
                id: widget.task.cliente.id,
                code: widget.task.cliente.code,
                description: widget.task.cliente.description,
                eqptType: widget.task.cliente.eqptType,
                statusCode: widget.task.cliente.statusCode,
              ),
              'commessa': carl.Material(
                id: widget.task.commessa.id,
                code: widget.task.commessa.code,
                description: widget.task.commessa.description,
                eqptType: widget.task.commessa.eqptType,
                statusCode: widget.task.commessa.statusCode,
              ),
              'workflow': [],
            },
          );
        }
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
              color: Theme.of(context).colorScheme.secondary,
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
