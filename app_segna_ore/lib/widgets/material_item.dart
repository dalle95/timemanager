import 'package:app_segna_ore/screens/detail/box_detail_screen.dart';
import 'package:flutter/material.dart';

import '../providers/material.dart' as carl;

class MaterialItem extends StatefulWidget {
  final carl.Material material;
  final String function;

  MaterialItem(
    this.material,
    this.function,
  );

  @override
  State<MaterialItem> createState() => _MaterialItemState();
}

class _MaterialItemState extends State<MaterialItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.function == 'list') {
          Navigator.of(context).pushNamed(
            BoxDetailScreen.routeName,
            arguments: widget.material.id,
          );
        } else {
          Navigator.of(context).pop(
            {
              'id': widget.material.id,
              'code': widget.material.code,
              'description': widget.material.description,
              'eqptType': widget.material.eqptType,
              'statusCode': widget.material.statusCode,
            },
          );
        }
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            leading: Icon(
              Icons.location_city,
              color: Theme.of(context).colorScheme.secondary,
              size: 40,
            ),
            title: Text(
              widget.material.description ?? '',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.material.code),
                Text('Stato: ${widget.material.statusCode}'),
                Text('Tipologia: ${widget.material.eqptType ?? ''}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
