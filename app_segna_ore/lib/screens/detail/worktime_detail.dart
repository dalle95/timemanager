import 'package:app_segna_ore/providers/worktime.dart';
import 'package:app_segna_ore/providers/worktimes.dart';
import 'package:app_segna_ore/screens/list/material_list_screen.dart';
import 'package:app_segna_ore/screens/list/task_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/actiontype.dart';
import '../../providers/task.dart';
import '../../providers/tasks.dart';
import '../../providers/box.dart';
import '../../providers/material.dart' as carl;

import '../list/box_list_screen.dart';
import '../list/actiontype_list_screen.dart';
import '../../widgets/flat_button.dart';

enum tipologia { insert, update }

class WorkTimeDetailScreen extends StatefulWidget {
  static const routeName = '/edit-worktime';

  @override
  State<WorkTimeDetailScreen> createState() => _WorkTimeDetailScreenState();
}

class _WorkTimeDetailScreenState extends State<WorkTimeDetailScreen> {
  final _form = GlobalKey<FormState>();

  var _isInit = true;
  var _isLoading = false;
  var _tipologia;

  // Inizializzo gli elementi vuoti
  var _task = Task(
    id: null,
    code: '',
    commessa: carl.Material(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
  );
  var _commessa = carl.Material(
    id: null,
    code: '',
    description: '',
    eqptType: '',
    statusCode: '',
  );

  // Inizializzo il valore iniziale del ticket ore sia nuovo che in modifica
  var _initWorkTime = WorkTime(
    id: null,
    code: '',
    data: DateTime.now(),
    task: Task(
      id: null,
      code: '',
      description: '',
      statusCode: '',
      actionType: ActionType(
        id: null,
        code: '',
        description: '',
      ),
    ),
    commessa: carl.Material(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    tempoLavorato: const Duration(
      hours: 0,
      minutes: 0,
    ),
    tempoFatturato: const Duration(
      hours: 0,
      minutes: 0,
    ),
    note: '',
    addebitoTrasferta: null,
    distanzaSede: null,
    spesePasto: null,
    speseNotte: null,
    speseAltro: null,
    comune: null,
  );
  var _editedWorkTime = WorkTime(
    id: null,
    code: '',
    data: DateTime.now(),
    task: Task(
      id: null,
      code: '',
      description: '',
      statusCode: '',
      actionType: ActionType(
        id: null,
        code: '',
        description: '',
      ),
    ),
    commessa: carl.Material(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    tempoLavorato: const Duration(
      hours: 0,
      minutes: 0,
    ),
    tempoFatturato: const Duration(
      hours: 0,
      minutes: 0,
    ),
    note: '',
    addebitoTrasferta: null,
    distanzaSede: null,
    spesePasto: null,
    speseNotte: null,
    speseAltro: null,
    comune: null,
  );

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final id = ModalRoute.of(context).settings.arguments as String;
      if (id != null) {
        _editedWorkTime =
            Provider.of<WorkTimes>(context, listen: false).findById(id);

        _initWorkTime = WorkTime(
          id: _editedWorkTime.id,
          code: _editedWorkTime.code,
          data: _editedWorkTime.data,
          task: _editedWorkTime.task,
          commessa: _editedWorkTime.commessa,
          tempoLavorato: _editedWorkTime.tempoLavorato,
          tempoFatturato: _editedWorkTime.tempoFatturato,
          note: _editedWorkTime.note,
          addebitoTrasferta: _editedWorkTime.addebitoTrasferta,
          distanzaSede: _editedWorkTime.distanzaSede,
          spesePasto: _editedWorkTime.spesePasto,
          speseNotte: _editedWorkTime.speseNotte,
          speseAltro: _editedWorkTime.speseAltro,
          comune: _editedWorkTime.comune,
        );

        _task = _editedWorkTime.task;
        _commessa = _editedWorkTime.commessa;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _searchListTask() async {
    final result = await Navigator.of(context).pushNamed(
      TaskListScreen.routeName,
      arguments: {
        'function': 'search',
      },
    ) as Map<String, dynamic>;

    if (result != null) {
      setState(() {
        _task = Task(
          id: result['id'],
          code: result['code'] ?? '',
          description: result['description'] ?? '',
          actionType: result['actionType'] ?? '',
          statusCode: result['statusCode'] ?? '',
          cliente: result['cliente'] ?? '',
          commessa: result['commessa'] ?? '',
          workflowTransitions: result['workflowTransitions'] ?? [],
        );

        _commessa = _task.commessa;
      });
    }
  }

  Future<void> _searchListMaterial() async {
    final result = await Navigator.of(context).pushNamed(
      MaterialListScreen.routeName,
      arguments: {
        'function': 'search',
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
        );
      });
    }
  }

  void _showTimePickerTempoLavorato() async {
    Picker(
      adapter: NumberPickerAdapter(
        data: <NumberPickerColumn>[
          NumberPickerColumn(
            initValue: _initWorkTime.tempoLavorato.inHours.toInt(),
            begin: 0,
            end: 999,
            suffix: const Text(' ore'),
          ),
          NumberPickerColumn(
            initValue: _initWorkTime.tempoLavorato.inMinutes.toInt(),
            begin: 0,
            end: 60,
            suffix: const Text(' minuti'),
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
          _initWorkTime.tempoLavorato = Duration(
              hours: picker.getSelectedValues()[0],
              minutes: picker.getSelectedValues()[1]);
        });
      },
    ).showDialog(context);
  }

  void _showTimePickerTempoFatturato() async {
    Picker(
      adapter: NumberPickerAdapter(
        data: <NumberPickerColumn>[
          NumberPickerColumn(
            initValue: _initWorkTime.tempoFatturato.inHours.toInt(),
            begin: 0,
            end: 999,
            suffix: const Text(' ore'),
          ),
          NumberPickerColumn(
            initValue: _initWorkTime.tempoFatturato.inMinutes.toInt(),
            begin: 0,
            end: 60,
            suffix: const Text(' minuti'),
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
          _initWorkTime.tempoFatturato = Duration(
              hours: picker.getSelectedValues()[0],
              minutes: picker.getSelectedValues()[1]);
        });
      },
    ).showDialog(context);
  }

  void _mostraDatePicker() async {
    DateTime pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      _initWorkTime.data = pickedDate;
    });
  }

  format(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0").substring(0, 5);

  Future<void> _saveForm() async {
    var isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }

    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    print('WorkTime: id: ${_initWorkTime.id ?? ''}');

    _editedWorkTime.task = _task;
    _editedWorkTime.commessa = _commessa;

    print('WorkTime: id: ${_editedWorkTime.id ?? ''}');

    if (_editedWorkTime.id != null) {
      try {
        //Per aggiornare un WO già esistente
        // await Provider.of<WorkTimes>(context, listen: false).updateWorkTime(
        //     _editedWorkTime.id, _initWorkTime, _editedWorkTime);
        _tipologia = tipologia.update;
      } catch (error) {
        print(error);
      }
    } else {
      try {
        // Per creare un WorkTime
        await Provider.of<WorkTimes>(context, listen: false)
            .addWorkTime(_editedWorkTime);
        _tipologia = tipologia.insert;
      } catch (error) {
        print(error);
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Si è verificato un errore'),
            content: const Text('Qualcosa è andato storto.'),
            actions: [
              FlatButton(
                () {
                  Navigator.of(context).pop();
                },
                const Text('Conferma'),
              ),
            ],
          ),
        );
      }
    }
    ;
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();

    if (_tipologia == tipologia.insert) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WorkTime inserito!'),
          duration: const Duration(
            seconds: 2,
          ),
          action: SnackBarAction(label: 'Annulla', onPressed: () {}),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WorkTime aggiornato!'),
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
        title: const Text('Descrizione ticket'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              // Container(
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).accentColor,
              //   ),
              //   width: double.infinity,
              //   height: 30,
              // ),
              // TextFormField(
              //   initialValue: _initWorkTime.code, //_initWorkTimeValues['code'],
              //   decoration: const InputDecoration(labelText: 'Codice'),
              //   textInputAction: TextInputAction.next,
              //   readOnly: true,
              //   onSaved: (value) {
              //     // _editedWorkTime = WorkTime(
              //     //   id: _editedWorkTime.id,
              //     //   codice: value,
              //     //   descrizione: _editedWorkTime.descrizione,
              //     //   statusCode: _editedWorkTime.statusCode,
              //     //   actionType: _editedWorkTime.actionType,
              //     // );
              //   },
              //   validator: (value) {
              //     if (value.isEmpty) {
              //       return 'Inserisci il codice.';
              //     }
              //     return null;
              //   },
              // ),
              const Text(
                'Data',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _mostraDatePicker,
                  Text(DateFormat('dd/MM/yyyy').format(_initWorkTime.data) ??
                      ''),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Task',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _searchListTask,
                  Text(_task.code),
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
                  Text(_commessa.code),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tempo lavorato',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _showTimePickerTempoLavorato,
                  Text('${format(_initWorkTime.tempoLavorato)}'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tempo fatturato',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _showTimePickerTempoFatturato,
                  Text('${format(_initWorkTime.tempoFatturato)}'),
                ),
              ),
              TextFormField(
                initialValue: _initWorkTime.note,
                decoration: const InputDecoration(labelText: 'Note'),
                textInputAction: TextInputAction.done,
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onSaved: (value) {
                  // _editedWorkTime = WorkTime(
                  //   id: _editedWorkTime.id,
                  //   codice: value,
                  //   descrizione: _editedWorkTime.descrizione,
                  //   statusCode: _editedWorkTime.statusCode,
                  //   actionType: _editedWorkTime.actionType,
                  // );
                },
                onEditingComplete: () {
                  setState(() {});
                },
                onFieldSubmitted: (_) {
                  _saveForm();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Inserisci delle note.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveForm,
        child: const Icon(Icons.send),
      ),
    );
  }
}
