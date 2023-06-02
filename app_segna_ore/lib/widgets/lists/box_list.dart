import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/boxes.dart';
import '../items/box_item.dart';

class BoxList extends StatelessWidget {
  final String function;

  BoxList(this.function);

  @override
  Widget build(BuildContext context) {
    final boxesData = Provider.of<Boxes>(context);
    final boxes = boxesData.boxes;

    return boxes.isEmpty
        ? const Center(
            child: Text(
              'Non sono presenti clienti.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        : ListView.builder(
            itemCount: boxes.length,
            itemBuilder: (ctx, i) => BoxItem(boxes[i], function),
          );
  }
}
