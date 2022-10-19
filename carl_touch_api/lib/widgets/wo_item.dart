import 'package:carl_touch_api/screens/wo_detail_screen.dart';
import 'package:flutter/material.dart';

import '../providers/work_order.dart';

class WOItem extends StatefulWidget {
  final WorkOrder workOrder;

  WOItem(
    this.workOrder,
  );

  @override
  State<WOItem> createState() => _WOItemState();
}

class _WOItemState extends State<WOItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          WoDetailScreen.routeName,
          arguments: widget.workOrder.id,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: ListTile(
          title: Text(
            widget.workOrder.descrizione ?? '',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.workOrder.codice),
              Text(widget.workOrder.statusCode),
            ],
          ),
        ),
      ),
    );
  }
}
