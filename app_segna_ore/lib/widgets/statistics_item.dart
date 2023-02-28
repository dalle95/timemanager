import 'package:app_segna_ore/providers/worktimes.dart';
import 'package:app_segna_ore/screens/list/worktime_list_screen.dart';
import 'package:app_segna_ore/screens/tabs_screen.dart';
import 'package:app_segna_ore/widgets/homepage.dart';
import 'package:app_segna_ore/widgets/statistics.dart';
import 'package:app_segna_ore/widgets/worktime_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatisticsItem extends StatefulWidget {
  final String giorno;
  final String oreSegnate;

  const StatisticsItem(this.giorno, this.oreSegnate, {Key key})
      : super(key: key);

  @override
  State<StatisticsItem> createState() => _StatisticsItemState();
}

Future<void> _refreshWorkTimes(
    BuildContext context, String periodoRiferimento) async {
  print(periodoRiferimento);
  Map<String, String> filtro = {'periodoCompetenza': periodoRiferimento};
  await Provider.of<WorkTimes>(context, listen: false)
      .fetchAndSetFilteredWorkTimes(filtro);
}

class _StatisticsItemState extends State<StatisticsItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          WorkTimeListScreen.routeName,
          arguments: {'function': 'list', 'periodoCompetenza': widget.giorno},
        );

        await _refreshWorkTimes(
          context,
          DateFormat("yyyy-MM")
              .format((DateTime.parse(widget.giorno)))
              .toString(),
        );

        // Navigator.of(context).pop();
        // Navigator.of(context).pushNamed(TabsScreen.routeName);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          border: Border.all(color: Colors.blueAccent),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.giorno != ""
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Center(
                    child: Text(
                  widget.giorno != ""
                      ? DateTime.parse(widget.giorno).day.toString()
                      : "",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ),
            ),
            Expanded(
              flex: 7,
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    widget.oreSegnate != ''
                        ? double.parse(widget.oreSegnate)
                            .toStringAsFixed(1)
                            .replaceFirst(RegExp(r'\.?0*$'), '')
                        : '',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: widget.oreSegnate != ''
                          ? double.parse(widget.oreSegnate) == 0
                              ? Colors.red[400]
                              : double.parse(widget.oreSegnate) == 8.0
                                  ? Colors.green[400]
                                  : Colors.orange
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
