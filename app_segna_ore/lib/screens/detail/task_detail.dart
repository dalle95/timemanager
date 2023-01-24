import 'package:app_segna_ore/screens/list/material_list_screen.dart';
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
        );
      });
    }
  }

  void _showTimePickerTempoStimatoato() async {
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

    Future<void> _mostraDatePickerDataFine() async {
      DateTime pickedDate = await showDatePicker(
        context: context,
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

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _initTask.dataInizio = pickedDate;
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

    print(
        'WO: id: ${_initTask.id}, code: ${_initTask.code ?? ''}, description: ${_initTask.description ?? ''}, natura: ${_initTask.actionType.code ?? ''}, box: ${_initTask.cliente.code ?? ''}');

    _editedTask.actionType = _actionType;
    _editedTask.cliente = _cliente;
    _editedTask.cliente = _cliente;
    _editedTask.dataInizio = _initTask.dataInizio;
    _editedTask.dataFine = _initTask.dataFine;
    _editedTask.stima = _initTask.stima;

    print(
        'WO: id: ${_editedTask.id}, code: ${_editedTask.code ?? ''}, description: ${_editedTask.description ?? ''}, natura: ${_editedTask.actionType.code ?? ''}, box: ${_editedTask.cliente.code ?? ''}');

    if (_editedTask.id != null) {
      try {
        //Per aggiornare un WO già esistente
        await Provider.of<Tasks>(context, listen: false)
            .updateTask(_editedTask.id, _initTask, _editedTask);
        _tipologia = tipologia.update;
      } catch (error) {
        print(error);
      }
    } else {
      try {
        // Per creare un WO
        await Provider.of<Tasks>(context, listen: false).addTask(_editedTask);
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
          content: Text('Task inserito!'),
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
        title: const Text('Dettaglio del WO'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          _initTask.id != null
              ? IconButton(
                  onPressed: _saveForm,
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
              TextFormField(
                initialValue: _initTask.code ?? '',
                decoration: const InputDecoration(labelText: 'Codice'),
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
                    actionType: _editedTask.actionType,
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
              ),
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
                    actionType: _editedTask.actionType,
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
                    actionType: _editedTask.actionType,
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
              TextFormField(
                initialValue: _initTask.priority ?? '',
                decoration: const InputDecoration(
                  labelText: 'Priorità',
                ),
                textAlign: TextAlign.center,
                readOnly: _initTask.id == null ? false : true,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  setState(() {
                    _initTask.priority = value;
                  });
                },
                onSaved: (value) {
                  _editedTask = Task(
                    id: _editedTask.id,
                    code: _editedTask.code,
                    description: _editedTask.description,
                    statusCode: _editedTask.statusCode,
                    priority: value,
                    actionType: _editedTask.actionType,
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
                    return 'Inserisci la priorità.';
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
                  _searchListActiontype,
                  Text(_actionType.description),
                ),
              ),
              TextFormField(
                initialValue: _initTask.note ?? '',
                decoration: const InputDecoration(labelText: 'Note'),
                textInputAction: TextInputAction.next,
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
                    actionType: _editedTask.actionType,
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
                  _mostraDatePickerDataInizio,
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
                  _showTimePickerTempoStimatoato,
                  Text('${format(_initTask.stima)}'),
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.access_alarm),
      // ),
    );
  }
}
