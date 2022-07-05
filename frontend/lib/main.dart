import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/functions/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/loginScreen.dart';
import 'screens/todoList.dart';
import 'models/todo.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Todo App',
      home: TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  TodoAppState createState() => TodoAppState();
}

class TodoAppState extends State<TodoApp> {
  Future<dynamic> fetchData() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    if (email == null || email == "") {
      return null;
    }
    List<Todo> todos = await login(email); //fetch todos from server
    return todos;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: fetchData(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              if (snapshot.data == null) //no token, show login screen
              {
                return const LoginScreen();
              }
              return TodoList(todos: snapshot.data);
            }
        }
      },
    );
  }
}
