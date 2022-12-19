import 'package:app_segna_ore/providers/actiontypes.dart';
import 'package:app_segna_ore/providers/tasks.dart';
import 'package:app_segna_ore/widgets/actiontype_item.dart';
import 'package:app_segna_ore/widgets/task_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiontypeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actionTypesData = Provider.of<ActionTypes>(context, listen: false);
    final actionTypes = actionTypesData.actionTypes;

    return actionTypes.isEmpty
        ? const Center(
            child: Text(
              'Non sono presenti nature.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        : ListView.builder(
            itemCount: actionTypes.length,
            itemBuilder: (ctx, i) => ActionTypeItem(actionTypes[i]),
          );
  }
}
