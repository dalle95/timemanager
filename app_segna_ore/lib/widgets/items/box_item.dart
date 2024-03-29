import 'package:flutter/material.dart';

import '../../models/box.dart';

import '../../../screens/detail/box_detail_screen.dart';

class BoxItem extends StatefulWidget {
  final Box box;
  final String function;

  BoxItem(
    this.box,
    this.function,
  );

  @override
  State<BoxItem> createState() => _BoxItemState();
}

class _BoxItemState extends State<BoxItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.function == 'list') {
          Navigator.of(context).pushNamed(
            BoxDetailScreen.routeName,
            arguments: widget.box.id,
          );
        } else {
          Navigator.of(context).pop(
            {
              'id': widget.box.id,
              'code': widget.box.code,
              'description': widget.box.description,
              'eqptType': widget.box.eqptType,
              'statusCode': widget.box.statusCode,
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
              Icons.account_circle,
              color: Theme.of(context).colorScheme.secondary,
              size: 40,
            ),
            title: Text(
              widget.box.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.box.code),
                Text('Stato: ${widget.box.statusCode}'),
                Text('Tipologia: ${widget.box.eqptType ?? ''}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
