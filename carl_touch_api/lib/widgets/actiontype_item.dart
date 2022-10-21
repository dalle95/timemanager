import 'package:carl_touch_api/providers/actiontype.dart';
import 'package:carl_touch_api/screens/wo_detail_screen.dart';
import 'package:flutter/material.dart';

import '../providers/work_order.dart';

class ActionTypeItem extends StatelessWidget {
  final ActionType actionType;

  ActionTypeItem(
    this.actionType,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(
          actionType.code,
        );
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
