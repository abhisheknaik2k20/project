import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'taskentryform.dart';
import 'taskModel.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  late Future<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = _getTasks(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: Expanded(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 5, 8, 8),
              child: TableCalendar(
                focusedDay: _selectedDay,
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 10, 16),
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) async {
                  setState(() {
                    _selectedDay = selectedDay;
                    _tasks = _getTasks(selectedDay);
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    return FutureBuilder<List<Task>>(
                      future: _getTasks(date),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Positioned(
                            right: 1,
                            top: 1,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.fromLTRB(20.0, 10, 0, 10),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Tasks:",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  )),
            ),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _tasks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final task = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.indigo,
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TaskEntryForm(
                                              selectedDate: _selectedDay,
                                              isUpdate: true,
                                              task: task,
                                            )));
                                setState(() {
                                  _tasks = _getTasks(_selectedDay);
                                });
                              },
                              child: ListTile(
                                leading: Text(
                                  "${_selectedDay.difference(DateTime.now()).inDays} day \n to go!!",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                title: Text(
                                  task.title,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                subtitle: Text(
                                  task.description,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () async {
                                    await _deleteTask(task);
                                    setState(() {
                                      _tasks = _getTasks(_selectedDay);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                      child: Text(
                    'No tasks for this day.',
                    style: TextStyle(fontSize: 20),
                  ));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TaskEntryForm(selectedDate: _selectedDay, isUpdate: false),
              ),
            );
            setState(() {
              _tasks = _getTasks(_selectedDay);
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<List<Task>> _getTasks(DateTime date) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'task_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, date TEXT)",
        );
      },
      version: 1,
    );

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: "date = ? ",
      whereArgs: [date.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return Task(
        title: maps[i]['title'],
        description: maps[i]['description'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  Future<void> _deleteTask(Task task) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'task_database.db'),
    );

    await db.delete(
      'tasks',
      where: "title = ? AND description = ? AND date = ?",
      whereArgs: [task.title, task.description, task.date.toIso8601String()],
    );
  }
}
