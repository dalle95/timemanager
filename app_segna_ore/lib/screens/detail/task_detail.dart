import 'package:app_segna_ore/providers/actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/http_exception.dart';

import '../../providers/actiontype.dart';
import '../../providers/task.dart';
import '../../providers/tasks.dart';
import '../../providers/box.dart';
import '../../providers/material.dart' as carl;

import '../../screens/list/material_list_screen.dart';
import '../../screens/list/worktime_list_screen.dart';

import '../list/box_list_screen.dart';
import '../list/actiontype_list_screen.dart';
import '../../widgets/flat_button.dart';

enum tipologia { insert, update }

class TaskDetailScreen extends StatefulWidget {
  static const routeName = '/edit-task';

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;
  var _tipologia;

  // Inizializzo il valore iniziale della natura
  var _actionType = ActionType(
    id: null,
    code: '',
    description: '',
  );
  // Inizializzo il valore iniziale del cliente
  var _cliente = Box(
    id: null,
    code: '',
    description: '',
    eqptType: '',
    statusCode: '',
  );
  // Inizializzo il valore iniziale della commessa
  var _commessa = carl.Material(
    id: null,
    code: '',
    description: '',
    eqptType: '',
    statusCode: '',
  );

  // Inizializzo il valore iniziale del WO sia nuovo che in modifica
  var _initTask = Task(
    id: null,
    code: '',
    description: '',
    statusCode: 'PREPARAZIONE',
    priority: '',
    actionType: ActionType(
      id: null,
      code: '',
      description: '',
    ),
    cliente: Box(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    commessa: carl.Material(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    stima: const Duration(
      hours: 0,
      minutes: 0,
    ),
    dataInizio: DateTime.now(),
    dataFine: DateTime.now(),
    note: '',
    workflowTransitions: [],
  );
  var _editedTask = Task(
    id: null,
    code: '',
    description: '',
    statusCode: 'PREPARAZIONE',
    priority: '',
    actionType: ActionType(
      id: null,
      code: '',
      description: '',
    ),
    cliente: Box(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    commessa: carl.Material(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    stima: const Duration(
      hours: 0,
      minutes: 0,
    ),
    dataInizio: DateTime.now(),
    dataFine: DateTime.now(),
    note: '',
    workflowTransitions: [],
  );

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final woId = ModalRoute.of(context).settings.arguments as String;
      if (woId != null) {
        _editedTask = Provider.of<Tasks>(context, listen: false).findById(woId);

        _initTask = Task(
          id: _editedTask.id,
          code: _editedTask.code,
          description: _editedTask.description,
          statusCode: _editedTask.statusCode,
          priority: _editedTask.priority,
          actionType: _editedTask.actionType,
          cliente: _editedTask.cliente,
          commessa: _editedTask.commessa,
          stima: _editedTask.stima ??
              const Duration(
                hours: 0,
                minutes: 0,
              ),
          dataInizio: _editedTask.dataInizio,
          dataFine: _editedTask.dataFine,
          note: _editedTask.note,
          workflowTransitions: _editedTask.workflowTransitions,
        );

        _actionType = _editedTask.actionType;
        _cliente = _editedTask.cliente;
        _commessa = _editedTask.commessa;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _searchListActiontype() async {
    final result = await Navigator.of(context)
        .pushNamed(ActionTypeListScreen.routeName) as Map<String, dynamic>;

    if (result != null) {
      setState(() {
        _actionType = ActionType(
          id: result['id'],
          code: result['code'] ?? '',
          description: result['description'] ?? '',
        );
      });
    }
  }

  Future<void> _searchListBox() async {
    final result = await Navigator.of(context).pushNamed(
      BoxListScreen.routeName,
      arguments: {
        'function': 'search',
      },
    ) as Map<String, dynamic>;

    if (result != null) {
      setState(() {
        _cliente = Box(
          id: result['id'],
          code: result['code'],
          description: result['description'] ?? '',
          eqptType: result['eqptType'] ?? '',
          statusCode: result['statusCode'],
        );
      });
    }
  }

  Future<void> _searchListMaterial() async {
    final result = await Navigator.of(context).pushNamed(
      MaterialListScreen.routeName,
      arguments: {
        'function': 'search',
        'cliente': _cliente.code,
      },
    ) as Map<String, dynamic>;

    if (result != null) {
      setState(() {
        _commessa = carl.Material(
            id: result['id'],
            code: result['code'],
            description: result['description'] ?? '',
            eqptType: result['eqptType'] ?? '',
            statusCode: result['statusCode'],
            responsabile: Actor(
              id: result['responsabile']['id'],
              code: result['responsabile']['code'],
              nome: result['responsabile']['nome'],
            ));
      });
    }
  }

  void _showTimePickerTempoStimato() async {
    Picker(
      adapter: NumberPickerAdapter(
        data: <NumberPickerColumn>[
          NumberPickerColumn(
            initValue: _initTask.stima.inHours.toInt(),
            begin: 0,
            end: 999,
            suffix: Text(' ore'),
          ),
          NumberPickerColumn(
            initValue: _initTask.stima.inMinutes.toInt(),
            begin: 0,
            end: 60,
            suffix: Text(' minuti'),
            jump: 15,
          ),
        ],
      ),
      delimiter: <PickerDelimiter>[
        PickerDelimiter(
          child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: const Icon(Icons.more_vert),
          ),
        )
      ],
      hideHeader: true,
      confirmText: 'Conferma',
      confirmTextStyle: TextStyle(
        inherit: false,
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 22,
      ),
      cancelText: 'Annulla',
      cancelTextStyle: const TextStyle(
        inherit: false,
        color: Colors.black,
        fontSize: 22,
      ),
      title: const Text(
        'Inserisci la durata',
        style: TextStyle(fontSize: 25),
        textAlign: TextAlign.center,
      ),
      selectedTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
      ),
      onConfirm: (Picker picker, List<int> value) {
        setState(() {
          _initTask.stima = Duration(
              hours: picker.getSelectedValues()[0],
              minutes: picker.getSelectedValues()[1]);
        });
      },
    ).showDialog(context);
  }

  Future<void> _mostraDatePickerDataInizio() async {
    DateTime pickedDate = await showDatePicker(
      context: context,
      locale: const Locale("it", "IT"),
      initialDate: _initTask.dataInizio,
      firstDate: DateTime(1970),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.background,
              onSurface: Colors.blueAccent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child,
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _initTask.dataInizio = pickedDate;
    });
  }

  Future<void> _mostraDatePickerDataFine() async {
    DateTime pickedDate = await showDatePicker(
      context: context,
      locale: const Locale("it", "IT"),
      initialDate: _initTask.dataFine,
      firstDate: DateTime(1970),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.background,
              onSurface: Colors.blueAccent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child,
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _initTask.dataFine = pickedDate;
    });
  }

  Future<void> _confermaPassaggioStato(String statoNew, String statoOld) async {
    var navigator = Navigator.of(context);
    String messaggio;
    if (statoNew == 'INPROGRESS') {
      messaggio =
          'Effettuare il passaggio di stato per mandare il ticket in corso?';
    } else if (statoNew == 'PAUSE') {
      messaggio =
          'Effettuare il passaggio di stato per mandare il ticket in pausa?';
    } else if (statoNew == 'CONCLUSIONE') {
      messaggio = 'Effettuare il passaggio di stato per concludere il ticket?';
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Passaggio di stato'),
        content: Text(messaggio),
        actions: [
          FlatButton(
            () async {
              //_saveForm();
              await Provider.of<Tasks>(context, listen: false)
                  .passaggioStatoTask(_editedTask, statoNew, statoOld);
              navigator.pop();
              navigator.pop();
              navigator.pushNamed(
                TaskDetailScreen.routeName,
                arguments: _editedTask.id,
              );
            },
            const Text('Conferma'),
          ),
          FlatButton(
            () {
              navigator.pop();
            },
            const Text('Annulla'),
          ),
        ],
      ),
    );
  }

  List<Widget> _listWorkflowStatus() {
    List<Widget> passaggiDiStato = [];

    if (_initTask.statusCode == 'AWAITINGREAL') {
      passaggiDiStato = [
        FloatingActionButton.extended(
          onPressed: () {
            _confermaPassaggioStato('INPROGRESS', 'AWAITINGREAL');
          },
          heroTag: null,
          label: const Text('In Corso'),
          icon: const Icon(Icons.start),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton.extended(
          onPressed: () {
            _confermaPassaggioStato('PAUSE', 'AWAITINGREAL');
          },
          heroTag: null,
          label: const Text('In pausa'),
          icon: const Icon(Icons.pause),
        ),
      ];
    }
    if (_initTask.statusCode == 'INPROGRESS') {
      passaggiDiStato = [
        FloatingActionButton.extended(
          onPressed: () {
            _confermaPassaggioStato('CONCLUSIONE', 'INPROGRESS');
          },
          heroTag: null,
          label: const Text('Concluso'),
          icon: const Icon(Icons.stop),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton.extended(
          onPressed: () {
            _confermaPassaggioStato('PAUSE', 'INPROGRESS');
          },
          heroTag: null,
          label: const Text('In pausa'),
          icon: const Icon(Icons.pause),
        ),
      ];
    }
    if (_initTask.statusCode == 'PAUSE') {
      passaggiDiStato = [
        FloatingActionButton.extended(
          onPressed: () {
            _confermaPassaggioStato('INPROGRESS', 'PAUSE');
          },
          heroTag: null,
          label: const Text('In Corso'),
          icon: const Icon(Icons.start),
        ),
      ];
    }
    return passaggiDiStato;
  }

  Future<void> _scegliPriorita() async {
    final List<String> priorities = [
      'Non urgente',
      '1 mese',
      '2 settimane',
      'Urgenza (5 giorni)',
      'Urgenza (3 giorni)',
      'Emergenza'
    ];

    Widget setupAlertDialoadContainer() {
      return Container(
        height: 280.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: priorities.length,
          itemBuilder: (BuildContext context, int index) {
            return SimpleDialogOption(
              child: Text(
                priorities[index],
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              onPressed: () {
                setState(() {
                  _initTask.priority = priorities[index];
                });

                Navigator.of(context).pop();
              },
            );
          },
        ),
      );
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Scegli la priorità'),
            content: setupAlertDialoadContainer(),
          );
        });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Si è verificato un errore'),
        content: Text(message),
        actions: [
          FlatButton(
            () {
              Navigator.of(context).pop();
            },
            const Text('Conferma'),
          )
        ],
      ),
    );
  }

  format(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0").substring(0, 5);

  Future<void> _saveForm() async {
    var scaffold = ScaffoldMessenger.of(context);
    var navigator = Navigator.of(context);

    var isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }

    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    print(
      'WO: id: ${_initTask.id}, code: ${_initTask.code ?? ''}, description: ${_initTask.description ?? ''}, natura: ${_initTask.actionType.code ?? ''}, box: ${_initTask.cliente.code ?? ''}',
    );

    _editedTask.code = _initTask.code;
    _editedTask.description = _initTask.description;
    _editedTask.actionType = _actionType;
    _editedTask.cliente = _cliente;
    _editedTask.cliente = _cliente;
    _editedTask.priority = _initTask.priority;
    _editedTask.dataInizio = _initTask.dataInizio;
    _editedTask.dataFine = _initTask.dataFine;
    _editedTask.stima = _initTask.stima;

    print(
      'WO: id: ${_editedTask.id}, code: ${_editedTask.code ?? ''}, description: ${_editedTask.description ?? ''}, natura: ${_editedTask.actionType.code ?? ''}, box: ${_editedTask.cliente.code ?? ''}',
    );

    if (_editedTask.id != null) {
      try {
        //Per aggiornare un WO già esistente
        await Provider.of<Tasks>(context, listen: false)
            .updateTask(_editedTask.id, _initTask, _editedTask);
        _tipologia = tipologia.update;
      } on HttpException catch (error) {
        // Errore con messaggio
        _showErrorDialog(error.toString());
      } catch (error) {
        // Errore generico
        print(error);
        _showErrorDialog('Qualcosa è andato storto.');
      }
    } else {
      try {
        // Per creare un WO
        await Provider.of<Tasks>(context, listen: false).addTask(_editedTask);
        _tipologia = tipologia.insert;
        navigator.pop();
      } on HttpException catch (error) {
        // Errore con messaggio
        _showErrorDialog(error.toString());
      } catch (error) {
        // Errore generico
        print(error);
        _showErrorDialog('Qualcosa è andato storto.');
      }
    }
    setState(() {
      _isLoading = false;
    });
    //Navigator.of(context).pop();

    if (_tipologia == tipologia.insert) {
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Task inserito!'),
          duration: Duration(
            seconds: 2,
          ),
          //action: SnackBarAction(label: 'Annulla', onPressed: () {}),
        ),
      );
    } else if (_tipologia == tipologia.update) {
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Task aggiornato!'),
          duration: Duration(
            seconds: 2,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio ticket'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          _initTask.id != null
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      WorkTimeListScreen.routeName,
                      arguments: {
                        'function': 'list',
                        'filter': {'wo_id': _initTask.id}
                      },
                    );
                  },
                  icon: const Icon(Icons.alarm_add),
                )
              : const SizedBox(),
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                width: double.infinity,
                height: 30,
                child: Center(
                  child: Text(
                    'Informazioni attività',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              _initTask.id != null
                  ? TextFormField(
                      initialValue: _initTask.code ?? '',
                      decoration: const InputDecoration(labelText: 'Codice'),
                      readOnly: true,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        setState(() {
                          _initTask.code = value;
                        });
                      },
                      onSaved: (value) {
                        _editedTask = Task(
                          id: _editedTask.id,
                          code: value,
                          description: _editedTask.description,
                          statusCode: _editedTask.statusCode,
                          priority: _editedTask.priority,
                          cliente: _cliente,
                          commessa: _commessa,
                          stima: _editedTask.stima,
                          note: _editedTask.note,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Inserisci il codice.';
                        }
                        return null;
                      },
                    )
                  : SizedBox(),
              TextFormField(
                initialValue: _initTask.description ?? '',
                decoration: const InputDecoration(labelText: 'Titolo'),
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  setState(() {
                    _initTask.description = value;
                  });
                },
                onSaved: (value) {
                  _editedTask = Task(
                    id: _editedTask.id,
                    code: _editedTask.code,
                    description: value,
                    statusCode: _editedTask.statusCode,
                    priority: _editedTask.priority,
                    cliente: _cliente,
                    commessa: _commessa,
                    stima: _editedTask.stima,
                    note: _editedTask.note,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Inserisci un titolo.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initTask.statusCode ?? '',
                decoration: const InputDecoration(
                  labelText: 'Stato',
                ),
                textAlign: TextAlign.center,
                readOnly: true,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedTask = Task(
                    id: _editedTask.id,
                    code: _editedTask.code,
                    description: _editedTask.description,
                    statusCode: value,
                    priority: _editedTask.priority,
                    cliente: _cliente,
                    commessa: _commessa,
                    stima: _editedTask.stima,
                    note: _editedTask.note,
                  );
                },
                onEditingComplete: () {
                  setState(() {});
                },
                onFieldSubmitted: (_) {
                  _saveForm();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Inserisci lo stato.';
                  }
                  return null;
                },
              ),
              // TextFormField(
              //   initialValue: _initTask.priority ?? '',
              //   decoration: const InputDecoration(
              //     labelText: 'Priorità',
              //   ),
              //   textAlign: TextAlign.center,
              //   readOnly: _initTask.id == null ? false : true,
              //   textInputAction: TextInputAction.next,
              //   onChanged: (value) {
              //     setState(() {
              //       _initTask.priority = value;
              //     });
              //   },
              //   onSaved: (value) {
              //     _editedTask = Task(
              //       id: _editedTask.id,
              //       code: _editedTask.code,
              //       description: _editedTask.description,
              //       statusCode: _editedTask.statusCode,
              //       priority: value,
              //       actionType: _editedTask.actionType,
              //       cliente: _cliente,
              //       commessa: _commessa,
              //       stima: _editedTask.stima,
              //       note: _editedTask.note,
              //     );
              //   },
              //   onEditingComplete: () {
              //     setState(() {});
              //   },
              //   onFieldSubmitted: (_) {
              //     _saveForm();
              //   },
              //   validator: (value) {
              //     if (value.isEmpty) {
              //       return 'Inserisci la priorità.';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 10),
              const Text(
                'Priorità',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _scegliPriorita,
                  Text(_initTask.priority),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Natura',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _searchListActiontype,
                  Text(_actionType.description),
                ),
              ),
              TextFormField(
                initialValue: _initTask.note ?? '',
                decoration: const InputDecoration(labelText: 'Note'),
                //textInputAction: TextInputAction.next,
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (value) {
                  setState(() {
                    _initTask.note = value;
                  });
                },
                onSaved: (value) {
                  _editedTask = Task(
                    id: _editedTask.id,
                    code: _editedTask.code,
                    description: _editedTask.description,
                    statusCode: _editedTask.statusCode,
                    priority: _editedTask.priority,
                    cliente: _cliente,
                    commessa: _commessa,
                    stima: _editedTask.stima,
                    note: value,
                  );
                },
                onEditingComplete: () {
                  setState(() {});
                },
                onFieldSubmitted: (_) {
                  _saveForm();
                },
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                width: double.infinity,
                height: 30,
                child: Center(
                  child: Text(
                    'Informazioni Gestionali',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cliente',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _searchListBox,
                  Text(_cliente.description ?? ''),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Commessa',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _searchListMaterial,
                  Text(_commessa.description),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                width: double.infinity,
                height: 30,
                child: Center(
                  child: Text(
                    'Pianificazione',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Data di inizio',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _mostraDatePickerDataInizio,
                  Text(DateFormat('dd/MM/yyyy').format(_initTask.dataInizio) ??
                      ''),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Data di fine',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _mostraDatePickerDataFine,
                  Text(DateFormat('dd/MM/yyyy').format(_initTask.dataFine) ??
                      ''),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tempo Stimato',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _showTimePickerTempoStimato,
                  Text('${format(_initTask.stima)}'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _listWorkflowStatus(),
      ),
    );
  }
}
