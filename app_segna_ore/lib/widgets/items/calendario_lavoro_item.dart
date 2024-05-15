import 'package:flutter/material.dart';

import '../../screens/list/worktime_day_list_screen.dart';

class CalendarioDiLavoroItem extends StatefulWidget {
  final String giorno;
  final String oreSegnate;

  const CalendarioDiLavoroItem(this.giorno, this.oreSegnate, {Key? key})
      : super(key: key);

  @override
  State<CalendarioDiLavoroItem> createState() => _CalendarioDiLavoroItemState();
}

class _CalendarioDiLavoroItemState extends State<CalendarioDiLavoroItem> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    Widget corretto = SizedBox(
      width: 45,
      height: 70,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Image.asset('assets/icons/corretto.png'),
      ),
    );
    Widget nonCorretto = SizedBox(
      width: 40,
      height: 70,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Image.asset('assets/icons/non_corretto.png'),
      ),
    );
    Widget nonCompleto = SizedBox(
      width: 150,
      height: 150,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Image.asset('assets/icons/alert.png'),
      ),
    );
    Widget nonPronto = SizedBox(
      width: 150,
      height: 70,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Image.asset('assets/icons/non_pronto.png'),
      ),
    );

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          WorkTimeDayListScreen.routeName,
          arguments: {'periodoCompetenza': widget.giorno},
        );
      },
      child: Container(
        height: mediaQuery.size.height * 0.2,
        width: mediaQuery.size.width * 0.01,
        clipBehavior: Clip.hardEdge,
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
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(9),
            topRight: Radius.circular(9),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.giorno != ""
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey,
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
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: widget.oreSegnate != ''
                        ? double.parse(widget.oreSegnate) == 0
                            ? DateTime.parse(widget.giorno)
                                    .isBefore(DateTime.now())
                                ? nonCorretto
                                : nonPronto
                            : double.parse(widget.oreSegnate) == 8.0
                                ? corretto
                                : nonCompleto
                        : nonPronto,

                    // Text(
                    //   widget.oreSegnate != ''
                    //       ? double.parse(widget.oreSegnate)
                    //           .toStringAsFixed(1)
                    //           .replaceFirst(RegExp(r'\.?0*$'), '')
                    //       : '',
                    //   style: TextStyle(
                    //     fontSize: 17,
                    //     fontWeight: FontWeight.bold,
                    //     color: widget.oreSegnate != ''
                    //         ? double.parse(widget.oreSegnate) == 0
                    //             ? Colors.red[400]
                    //             : double.parse(widget.oreSegnate) == 8.0
                    //                 ? Colors.green[400]
                    //                 : Colors.orange
                    //         : Colors.white,
                    //   ),
                    // ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
