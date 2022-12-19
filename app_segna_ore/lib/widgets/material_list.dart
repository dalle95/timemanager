import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/materials.dart';
import '../widgets/material_item.dart';

class MaterialList extends StatelessWidget {
  final String function;

  MaterialList(this.function);

  @override
  Widget build(BuildContext context) {
    final materialsData = Provider.of<Materials>(context);
    final materials = materialsData.materials;

    return materials.isEmpty
        ? const Center(
            child: Text(
              'Non ci sono commesse attive.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        : ListView.builder(
            itemCount: materials.length,
            itemBuilder: (ctx, i) => MaterialItem(materials[i], function),
          );
  }
}
