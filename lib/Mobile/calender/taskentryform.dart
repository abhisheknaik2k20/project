import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'taskModel.dart';

class TaskEntryForm extends StatefulWidget {
  final DateTime selectedDate;
  final bool isUpdate;
  final Task? task;

  const TaskEntryForm(
      {super.key,
      required this.selectedDate,
      required this.isUpdate,
      this.task});

  @override
  _TaskEntryFormState createState() => _TaskEntryFormState();
}

class _TaskEntryFormState extends State<TaskEntryForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                onSaved: (value) {
                  _description = value!;
                },
                maxLines: 4, // Allows for multiple lines of text
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    !widget.isUpdate
                        ? _saveTask(Task(
                            title: _title,
                            description: _description,
                            date: widget.selectedDate))
                        : _updateTask(
                            Task(
                                title: _title,
                                description: _description,
                                date: widget.selectedDate),
                            widget.task!);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    !widget.isUpdate ? 'Save Task' : 'Update Task',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTask(Task task) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'task_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT, description TEXT, date TEXT)",
        );
      },
      version: 1,
    );

    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _updateTask(Task taskNew, Task taskOld) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'task_database.db'),
    );

    await db.update(
      'tasks',
      taskNew.toMap(),
      where: "title = ? AND description = ? AND date = ?",
      whereArgs: [
        taskOld.title,
        taskOld.description,
        taskOld.date.toIso8601String()
      ],
    );
  }
}
