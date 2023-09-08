// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      // Check if tasksList is not empty before generating completedList
      if (tasksList.isNotEmpty) {
        completedList = List.generate(tasksList.length, (index) => false);
      } else {
        completedList = [];
      }
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

        ///after 2 seconds, delete the selected task
        // Future.delayed(const Duration(seconds: 2), () {
        //   deleteTask(index);
        // });
      }
      _saveTasks();
    });
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

  ListView generateItemsList() {
    return ListView.builder(
      itemCount: tasksList.length,
      itemBuilder: (context, index) {
        return Dismissible(
          background: slideRightBackground(),
          secondaryBackground: slideLeftBackground(),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              final bool res = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text(
                          "Are you sure you want to delete ${tasksList[index]['task']}?"),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        ElevatedButton(
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            setState(() {
                              deleteTask(index);
                            });
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  });
              return res;
            } else if (direction == DismissDirection.startToEnd) {
              // Uncomment the code to open the editTaskDialog
              editTaskDialog(index);
            }
            return null;
          },
          key: Key(tasksList[index]['task']!),
          child: InkWell(
            onTap: () {
              print("${tasksList[index]} clicked");
            },
            child: Card(
              child: ListTile(
                leading: Checkbox(
                  value: completedList[index],
                  onChanged: (value) {
                    toggleCompleted(index);
                  },
                ),
                title: Text(tasksList[index]['task']!),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          "To DO",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: generateItemsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: todolistDailog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: const Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}
