import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tasks.dart';

import '../detail/task_detail.dart';

import '../../widgets/loading_indicator.dart';
import '../../widgets/badge.dart';
import '../../widgets/task_list.dart';

class TaskListScreen extends StatelessWidget {
  static const routeName = '/task-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshProducts(BuildContext context) async {
      await Provider.of<Tasks>(context, listen: false).fetchAndSetTasks();
    }

    var functionData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    var function = functionData['function'];

    return Scaffold(
      appBar: AppBar(
        title: Consumer<Tasks>(
            builder: (_, wo, ch) => Badge(
                  child: ch,
                  value: wo.itemCount.toString(),
                ),
            child: const Text('Attività')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(TaskDetailScreen.routeName);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: FutureBuilder(
          future: Provider.of<Tasks>(context, listen: false).fetchAndSetTasks(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator('In caricamento!');
            } else {
              if (dataSnapshot.error != null) {
                return const Center(
                  child: Text('Si è verificato un errore.'),
                );
                //Error
              } else {
                return TaskList();
              }
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(TaskDetailScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
