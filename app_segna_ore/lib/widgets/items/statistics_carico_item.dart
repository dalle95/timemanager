import 'package:flutter/material.dart';

class StatisticsCaricoItem extends StatefulWidget {
  final String commessa;
  final String oreRegistrate;
  final double caricoPercentuale;

  const StatisticsCaricoItem(
    this.commessa,
    this.oreRegistrate,
    this.caricoPercentuale,
  );

  @override
  State<StatisticsCaricoItem> createState() => _StatisticsCaricoItemState();
}

class _StatisticsCaricoItemState extends State<StatisticsCaricoItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.commessa,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 350 * (widget.caricoPercentuale),
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.circular(2),
                        bottomRight: Radius.circular(5),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 20,
                  padding: const EdgeInsets.only(left: 5),
                  child: SizedBox(
                    child: Text(
                      '${widget.oreRegistrate} ${widget.oreRegistrate == '1.0' ? 'ora' : 'ore'} | ${(widget.caricoPercentuale * 100).toStringAsFixed(2)}%',
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
