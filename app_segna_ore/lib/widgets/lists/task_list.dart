import 'package:app_segna_ore/providers/tasks.dart';
import 'package:app_segna_ore/widgets/items/task_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskList extends StatelessWidget {
  final String function;

  TaskList(this.function);

  @override
  Widget build(BuildContext context) {
    final taskData = Provider.of<Tasks>(context);
    final tasks = taskData.tasks;

    return tasks.isEmpty
        ? const Center(
            child: Text(
              'Non sono presenti WO.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (ctx, i) => TaskItem(tasks[i], function),
          );
  }
}
