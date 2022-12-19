import 'package:app_segna_ore/providers/worktime.dart';
import 'package:app_segna_ore/providers/worktimes.dart';
import 'package:app_segna_ore/screens/list/material_list_screen.dart';
import 'package:app_segna_ore/screens/list/task_list_screen.dart';
import 'package:flutter/material.dart';
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
    code: null,
    description: null,
    eqptType: null,
    statusCode: null,
  );

  // Inizializzo il valore iniziale del ticket ore sia nuovo che in modifica
  var _initWorkTime = WorkTime(
    id: null,
    code: '',
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
    tempoLavorato: null,
    tempoFatturato: null,
    note: null,
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
    tempoLavorato: null,
    tempoFatturato: null,
    note: null,
    addebitoTrasferta: null,
    distanzaSede: null,
    spesePasto: null,
    speseNotte: null,
    speseAltro: null,
    comune: null,
  );

  // Inizializzo i valori iniziali dei textform
  var _initWorkTimeValues = {
    'occupationDate': '',
    'uowner': '',
    'tempoLavorato': '',
    'tempoFatturato': '',
    'note': '',
    'addebitoTrasferta': '',
    'distanzaSede': '',
    'spesePasto': '',
    'speseNotte': '',
    'speseAltro': '',
    'comune': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final id = ModalRoute.of(context).settings.arguments as String;
      if (id != null) {
        _editedWorkTime =
            Provider.of<WorkTimes>(context, listen: false).findById(id);

        _initWorkTime = WorkTime(
          id: _editedWorkTime.id,
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

        var _initWorkTimeValues = {
          'tempoLavorato': _editedWorkTime.tempoLavorato,
          'tempoFatturato': _editedWorkTime.tempoFatturato,
          'note': _editedWorkTime.note,
          'addebitoTrasferta': _editedWorkTime.addebitoTrasferta,
          'distanzaSede': _editedWorkTime.distanzaSede,
          'spesePasto': _editedWorkTime.spesePasto,
          'speseNotte': _editedWorkTime.speseNotte,
          'speseAltro': _editedWorkTime.speseAltro,
          'comune': _editedWorkTime.comune,
        };

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
          workflowTransitions: result['workflowTransitions'] ?? '',
        );
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
        // Per creare un WO
        // await Provider.of<WorkTimes>(context, listen: false)
        //     .addWorkTime(_editedWorkTime);
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
              TextFormField(
                initialValue: _initWorkTimeValues['code'],
                decoration: const InputDecoration(labelText: 'Codice'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  // _editedWorkTime = WorkTime(
                  //   id: _editedWorkTime.id,
                  //   codice: value,
                  //   descrizione: _editedWorkTime.descrizione,
                  //   statusCode: _editedWorkTime.statusCode,
                  //   actionType: _editedWorkTime.actionType,
                  // );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Inserisci il codice.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initWorkTimeValues['description'],
                decoration: const InputDecoration(labelText: 'Titolo'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  // _editedWorkTime = WorkTime(
                  //   id: _editedWorkTime.id,
                  //   codice: _editedWorkTime.codice,
                  //   descrizione: value,
                  //   statusCode: _editedWorkTime.statusCode,
                  //   actionType: _editedWorkTime.actionType,
                  // );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Inserisci un titolo.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initWorkTimeValues['statusCode'],
                decoration: const InputDecoration(
                  labelText: 'Stato',
                ),
                textAlign: TextAlign.center,
                readOnly: true,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  // _editedWorkTime = WorkTime(
                  //   id: _editedWorkTime.id,
                  //   codice: _editedWorkTime.codice,
                  //   descrizione: _editedWorkTime.descrizione,
                  //   statusCode: value,
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
                    return 'Inserisci lo stato.';
                  }
                  return null;
                },
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
                  _searchListTask,
                  Text(_task.code),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Punto di struttura',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _searchListMaterial,
                  Text(_commessa.code ?? ''),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.send),
      ),
    );
  }
}
