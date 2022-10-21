import 'package:carl_touch_api/providers/work_orders.dart';
import 'package:carl_touch_api/widgets/wo_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WOList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workOrdersData = Provider.of<WorkOrders>(context);
    final workOrders = workOrdersData.wo;

    return workOrders.isEmpty
        ? const Center(
            child: Text(
              'Non sono presenti WO.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        : ListView.builder(
            itemCount: workOrders.length,
            itemBuilder: (ctx, i) => WOItem(workOrders[i]),
          );
  }
}
