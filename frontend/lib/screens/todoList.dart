import 'package:flutter/material.dart';
import 'package:frontend/functions/utils.dart';
import 'package:frontend/screens/loginScreen.dart';
import 'package:frontend/widgets/todoItem.dart';
import '../models/todo.dart';
import '../functions/requests.dart';
import '../functions/utils.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key, required this.todos}) : super(key: key);
  final List<Todo> todos;
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late TextEditingController _newTodoController;
  String todoUrgency = 'Low';

  void update(int todoId, ListAction action, Todo? newTodo) {
    setState(() {
      switch (action) {
        case ListAction.add:
          widget.todos.add(newTodo!);
          break;
        case ListAction.remove:
          widget.todos.removeWhere((Todo element) => element.id == todoId);
          break;
        case ListAction.check:
          int idx = widget.todos.indexWhere((element) => element.id == todoId);
          widget.todos[idx].finished = 1;
          break;
        case ListAction.uncheck:
          int idx = widget.todos.indexWhere((element) => element.id == todoId);
          widget.todos[idx].finished = 0;
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _newTodoController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> finished = [];
    List<Todo> inProgress = [];
    for (Todo todo in widget.todos) {
      if (todo.finished == 0) {
        inProgress.add(todo);
      } else {
        finished.add(todo);
      }
    }
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
            title: const Text("My Todos"),
            bottom: const TabBar(tabs: [
              Tab(
                child: Text("In Progress"),
              ),
              Tab(
                child: Text("Done"),
              ),
            ]),
            actions: [
              IconButton(
                  onPressed: () => logout().then(
                        (value) => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const LoginScreen(),
                          ),
                        ),
                      ),
                  icon: const Icon(Icons.logout))
            ]),
        body: TabBarView(
          children: [
            Column(
              children: [
                Expanded(
                  child: SizedBox(
                    child: ListView.builder(
                      itemCount: inProgress.length,
                      itemBuilder: (context, index) {
                        return TodoItem(
                          todo: inProgress[index],
                          updateParent: update,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16, right: 10),
                          child: TextField(
                            controller: _newTodoController,
                          ),
                        ),
                      ),
                      DropdownButton(
                        items: ['Low', 'Medium', 'High'].map(
                          (String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Center(child: Text(value)),
                            );
                          },
                        ).toList(),
                        value: todoUrgency,
                        icon: const Icon(Icons.arrow_drop_up),
                        onChanged: (String? newValue) {
                          setState(
                            () {
                              todoUrgency = newValue!;
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                      ),
                      RawMaterialButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          addTodo(_newTodoController.text, todoUrgency).then(
                            ((List<dynamic> values) {
                              if (!values[0]) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Error adding todo')),
                                );
                              } else {
                                _newTodoController.clear();
                                Todo newTodo = values[1];
                                update(newTodo.id!, ListAction.add, newTodo);
                              }
                            }),
                          ); //[ok,Todo/null]
                        },
                        fillColor: Colors.blue,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
            ListView.builder(
              itemCount: finished.length,
              itemBuilder: (context, index) {
                return TodoItem(
                  todo: finished[index],
                  updateParent: update,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
