import 'package:app_segna_ore/models/http_wooccupationdateexception.dart';
import 'package:app_segna_ore/providers/tasks.dart';
import 'package:app_segna_ore/screens/detail/box_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/http_exception.dart';
import '../../providers/actiontype.dart';
import '../../providers/task.dart';
import '../../providers/material.dart' as carl;
import '../../providers/worktime.dart';
import '../../providers/worktimes.dart';

import '../../screens/list/material_list_screen.dart';
import '../../screens/list/task_list_screen.dart';

import '../../widgets/flat_button.dart';

enum Tipologia { insert, update }

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
    tempoFatturato: const Duration(
      hours: 0,
      minutes: 0,
    ),
    note: '',
  );
  var _editedWorkTime = WorkTime(
    id: null,
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
    tempoFatturato: const Duration(
      hours: 0,
      minutes: 0,
    ),
    note: '',
  );

  // Controllo WorkTime esistente o nuovo
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final arguments =
          ModalRoute.of(context).settings.arguments as Map<String, String>;
      if (arguments != null) {
        // Se l'argomento in ingresso è relativo ad un ticket precompilo i valori con quelli del ticket
        if (arguments.containsKey("wo_id")) {
          final woID = arguments['wo_id'];
          _editedWorkTime.task =
              Provider.of<Tasks>(context, listen: false).findById(woID);
          _task = _editedWorkTime.task;
          _commessa = _editedWorkTime.task.commessa;
          _initWorkTime.note = _editedWorkTime.task.description;
        }
        // Se l'argomento in ingresso è relativo ad un giorno precompilo la data con quella del giorno
        if (arguments.containsKey("giornoCompetenza")) {
          final giorno = DateTime.parse(arguments['giornoCompetenza']);
          _initWorkTime.data = giorno;
        }

        // Se l'argomento in ingresso è relativo ad un Worktime già esistente lo compilo con i propri valori
        if (arguments.containsKey("worktime_id")) {
          final id = arguments['worktime_id'];

          if (id != null) {
            _editedWorkTime =
                Provider.of<WorkTimes>(context, listen: false).findById(id);

            _initWorkTime = WorkTime(
              id: _editedWorkTime.id,
              attore: _editedWorkTime.attore,
              data: _editedWorkTime.data,
              task: _editedWorkTime.task,
              commessa: _editedWorkTime.commessa,
              tempoFatturato: _editedWorkTime.tempoFatturato,
              note: _editedWorkTime.note,
            );

            _task = _editedWorkTime.task;
            _commessa = _editedWorkTime.commessa;
          }
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // Mostra elenco ticket
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
          priority: result['priority'],
          actionType: result['actionType'] ?? '',
          statusCode: result['statusCode'] ?? '',
          cliente: result['cliente'] ?? '',
          commessa: result['commessa'] ?? '',
          note: result['xtraTxt10'],
          dataInizio: result['dataInizio'],
          dataFine: result['dataFine'],
          stima: result['stima'],
        );

        _commessa = _task.commessa;
        _initWorkTime.note = _task.description;
      });
    }
  }

  // Mostra elenco commesse
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

  // Mostra selettore tempo
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

  // Date picker
  void _mostraDatePicker() async {
    DateTime pickedDate = await showDatePicker(
      context: context,
      locale: const Locale("it", "IT"),
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

  // Messaggio di errore
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

  // Messaggio di errore per aggiornamento date nel ticket
  void _showErrorDialogWOOccupationDate(String message) {
    var navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Si è verificato un errore'),
        content: Text('$message\nAggiornare il ticket di conseguenza?'),
        actions: [
          FlatButton(
            () async {
              try {
                // Aggiorno il le date del ticket
                await Provider.of<Tasks>(context, listen: false)
                    .updatePeriodTask(
                  _editedWorkTime.task.id,
                  _task,
                  _editedWorkTime.data,
                );

                // Inserisco il WorkTime
                await Provider.of<WorkTimes>(context, listen: false)
                    .addWorkTime(_editedWorkTime);
                _tipologia = tipologia.insert;
                navigator.pop();
                _mostraSnackbarRisultato(_tipologia);
              } on HttpException catch (error) {
                // Errore con messaggio
                _showErrorDialog(error.toString());
              } catch (error) {
                // Errore generico
                _showErrorDialog(
                    'Qualcosa è andato storto.. Anche ai migliori capita di sbagliare.');
              }
            },
            const Text('Conferma'),
          ),
          FlatButton(
            () {
              Navigator.of(context).pop();
            },
            const Text('Annulla'),
          )
        ],
      ),
    );
  }

  // Mostro la snakbar per il risultato
  void _mostraSnackbarRisultato(Tipologia tipologia) {
    var scaffold = ScaffoldMessenger.of(context);
    var navigator = Navigator.of(context);
    String message;

    if (tipologia == Tipologia.update) {
      message = 'WorkTime aggiornato!';
    } else if (tipologia == Tipologia.insert) {
      message = 'WorkTime inserito!';
    }

    navigator.pop();
    scaffold.hideCurrentSnackBar();
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  // Formattazione ore lavorate da stringa a durata
  format(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0").substring(0, 5);

  // Salvataggio e validazione del form
  Future<void> _saveForm() async {
    var isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }

    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    _editedWorkTime.data = _initWorkTime.data;
    _editedWorkTime.task = _task;
    _editedWorkTime.commessa = _commessa;
    _editedWorkTime.tempoFatturato = _initWorkTime.tempoFatturato;

    print(
        'WorkTime: id: ${_editedWorkTime.id ?? ''}, data: ${_editedWorkTime.data}, commessa: ${_editedWorkTime.commessa.code}, durata: ${_editedWorkTime.tempoFatturato.toString()}, note: ${_editedWorkTime.note}');

    if (_editedWorkTime.id != null) {
      try {
        //Per aggiornare un WorkTime già esistente
        await Provider.of<WorkTimes>(context, listen: false).updateWorkTime(
          _editedWorkTime.id,
          _initWorkTime,
          _editedWorkTime,
        );
        _tipologia = Tipologia.update;
        _mostraSnackbarRisultato(_tipologia);
      } on HttpException catch (error) {
        // Errore con messaggio
        _showErrorDialog(error.toString());
      } catch (error) {
        // Errore generico
        _showErrorDialog(
            'Qualcosa è andato storto.. Anche ai migliori capita di sbagliare.');
      }
    } else {
      try {
        // Per creare un WorkTime
        await Provider.of<WorkTimes>(context, listen: false)
            .addWorkTime(_editedWorkTime);
        _tipologia = Tipologia.insert;
        _mostraSnackbarRisultato(_tipologia);
      } on HttpException catch (error) {
        // Errore con messaggio
        _showErrorDialog(error.toString());
      } on HttpWOOccupationDateException catch (error) {
        // Errore con messaggio
        _showErrorDialogWOOccupationDate(error.toString());
      } catch (error) {
        // Errore generico
        _showErrorDialog(
            'Qualcosa è andato storto.. Anche ai migliori capita di sbagliare.');
      }
    }
    ;
    setState(() {
      _isLoading = false;
    });
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio ore'),
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
                  Text(_commessa.description),
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
                //tinitialValue: _initWorkTime.note,
                controller: TextEditingController(text: _initWorkTime.note),
                decoration: const InputDecoration(labelText: 'Note'),
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onSaved: (value) {
                  _editedWorkTime = WorkTime(
                    id: _editedWorkTime.id,
                    task: _task,
                    commessa: _commessa,
                    data: _initWorkTime.data,
                    tempoFatturato: _initWorkTime.tempoFatturato,
                    note: value,
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
