import 'package:app_segna_ore/models/actiontype.dart';
import 'package:flutter/material.dart';

class ActionTypeItem extends StatelessWidget {
  final ActionType actionType;

  ActionTypeItem(
    this.actionType,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop({
          'id': actionType.id,
          'code': actionType.code,
          'description': actionType.description,
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: ListTile(
          title: Text(
            actionType.code ?? '',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          subtitle: Text(actionType.description ?? ''),
        ),
      ),
    );
  }
}
