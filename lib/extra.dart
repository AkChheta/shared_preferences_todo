import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ToDoPage extends StatefulWidget {
  const ToDoPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  List<Map<String, String>> tasksList = [];
  SharedPreferences? _prefs;
  List<bool> completedList = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  _loadTasks() async {
    _prefs = await SharedPreferences.getInstance();
    final tasksJson = _prefs?.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> tasksData = json.decode(tasksJson);
      tasksList =
          tasksData.map((data) => Map<String, String>.from(data)).toList();
      completedList = List.generate(tasksList.length, (index) => false);
      setState(() {});
    } else {
      tasksList = []; // Initialize tasksList as an empty list
      completedList = []; // Initialize completedList as an empty list
    }
  }

  void addTask(String task) {
    setState(() {
      tasksList.add({"task": task, "completed": "false"});
      completedList.add(false);
      _saveTasks();
    });
  }

  void editTask(int index, String task) {
    setState(() {
      tasksList[index] = {"task": task, "completed": "false"};
      _saveTasks();
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasksList.removeAt(index);
      completedList.removeAt(index); // Remove corresponding completed status
      _saveTasks();
    });
  }

  _saveTasks() async {
    final tasksJson = json.encode(tasksList);
    final completedJson = json.encode(completedList);
    await _prefs?.setString('tasks', tasksJson);
    await _prefs?.setString('completed', completedJson);
  }

  void toggleCompleted(int index) {
    setState(() {
      completedList[index] = !completedList[index];
      if (completedList[index]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task completed')),
        );

        ///after 2 second delete the selected task
        // Future.delayed(const Duration(seconds: 2), () {
        //   deleteTask(index);
        // });
      }
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: tasksList.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(
                        tasksList[index]['task']!), // Unique key for each item
                    direction:
                        DismissDirection.endToStart, // Swipe from right to left
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.blue,
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        // Delete item
                        deleteTask(index);
                      } else if (direction == DismissDirection.startToEnd) {
                        editTaskDialog(index);
                      }
                      return null;
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        // Delete item
                        deleteTask(index);
                      } else if (direction == DismissDirection.startToEnd) {
                        editTaskDialog(index);
                      }
                    },
                    child: Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: completedList[
                              index], // Replace with your checkbox value
                          onChanged: (value) {
                            toggleCompleted(index);
                          },
                        ),
                        title: Text(tasksList[index]['task']!),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: todolistDailog,
        child: const Icon(Icons.add),
      ),
    );
  }

  todolistDailog() {
    showDialog(
      context: context,
      builder: (context) {
        String task = "";

        return AlertDialog(
          scrollable: true,
          title: const Text(
            'New Task',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.brown),
          ),
          content: SizedBox(
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      hintText: 'Task',
                      hintStyle: const TextStyle(fontSize: 14),
                      icon: const Icon(Icons.list_alt, color: Colors.brown),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onChanged: (value) {
                      task = value;
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                addTask(task);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  editTaskDialog(int index) {
    String task = tasksList[index]["task"] ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text(
            'Edit Task',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.brown),
          ),
          content: SizedBox(
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: task,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      hintText: 'Task',
                      hintStyle: const TextStyle(fontSize: 14),
                      icon: const Icon(CupertinoIcons.square_list,
                          color: Colors.brown),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onChanged: (value) {
                      task = value;
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                editTask(index, task);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
