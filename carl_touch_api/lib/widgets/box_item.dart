import 'package:flutter/material.dart';

import '../providers/box.dart';

import '../screens/wo_detail_screen.dart';

class BoxItem extends StatefulWidget {
  final Box box;

  BoxItem(
    this.box,
  );

  @override
  State<BoxItem> createState() => _BoxItemState();
}

class _BoxItemState extends State<BoxItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          WoDetailScreen.routeName, // da modificare
          arguments: widget.box.id,
        );
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
              color: Theme.of(context).accentColor,
              size: 40,
            ),
            title: Text(
              widget.box.description ?? '',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.box.code),
                Text('Stato: ${widget.box.statusCode}'),
                Text('Tipologia: ${widget.box.eqptType}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
