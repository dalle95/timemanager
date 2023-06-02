import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/actiontype.dart';
import '../../models/box.dart';
import '../../models/material.dart' as carl;

import '../../providers/tasks.dart';
import '../detail/task_detail.dart';

import '../../widgets/loading_indicator.dart';
import '../../widgets/badge.dart';
import '../../widgets/lists/task_list.dart';

class TaskListScreen extends StatelessWidget {
  static const routeName = '/task-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshTasks(BuildContext context) async {
      await Provider.of<Tasks>(context, listen: false).fetchAndSetTasks();
    }

    var functionData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var function = functionData['function'];

    return Scaffold(
      appBar: AppBar(
        title: Consumer<Tasks>(
            builder: (_, wo, ch) => BadgeWidget(
                  value: wo.itemCount.toString(),
                  child: ch!,
                ),
            child: const Text('Attività')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: function == 'search'
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed(TaskDetailScreen.routeName);
                  },
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshTasks(context),
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
                return TaskList(function);
              }
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: function == 'search'
          ? FloatingActionButton(
              child: const Icon(Icons.disabled_by_default_rounded),
              onPressed: () {
                Navigator.of(context).pop(
                  {
                    'id': null,
                    'code': '',
                    'description': '',
                    'statusCode': '',
                    'actionType':
                        ActionType(id: null, code: '', description: ''),
                    'cliente': Box(
                        id: null,
                        code: '',
                        description: '',
                        eqptType: '',
                        statusCode: ''),
                    'commessa': carl.Material(
                        id: null,
                        code: '',
                        description: '',
                        eqptType: '',
                        statusCode: ''),
                    'xtraTxt10': '',
                    'workflow': [],
                  },
                );
              })
          : FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(TaskDetailScreen.routeName);
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
