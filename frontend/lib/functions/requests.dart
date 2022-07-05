import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/todo.dart';
import 'utils.dart';

//server will register user if not exists
Future<List<Todo>> login(String email) async {
  try {
    String userEmail = jsonEncode({"email": email});
    String loginRoute = "${dotenv.get('server')}/login";
    var response = await Dio().post(loginRoute, data: userEmail);
    if (response.statusCode == 201 ||
        response.data == null &&
            response.statusCode == 200) //user created or no todos
    {
      saveEmailToPreferences(email);
      return [];
    } else //create todos list
    {
      saveEmailToPreferences(email);
      List<Todo> res = [];
      for (var elem in response.data) {
        Todo newTodo = Todo.fromJson(elem);
        res.add(newTodo);
      }
      return res;
    }
  } catch (e) {
    print(e);
    return [];
  }
}

Future<List<dynamic>> addTodo(String todoText, String urgencyStr) async {
  try {
    Urgency urgency = stringToUrgency(urgencyStr);
    final String email = await getEmailFromPreferences();
    final String data = jsonEncode(
        {"email": email, "text": todoText, "urgency": urgencyToInt(urgency)});
    final String addTodoRoute = "${dotenv.get('server')}/add_todo";
    var response = await Dio().post(addTodoRoute, data: data);
    if (response.statusCode == 201) {
      return [true, Todo.fromJson(response.data)];
    }
    return [false, null];
  } catch (e) {
    print(e);
    return [false, null];
  }
}

Future<bool> removeTodo(int todoId) async {
  try {
    final String email = await getEmailFromPreferences();
    final String data = jsonEncode({"email": email, "id": todoId});
    final String removeTodoRoute = "${dotenv.get('server')}/remove_todo";
    var response = await Dio().post(removeTodoRoute, data: data);
    return response.statusCode == 200 ? true : false;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> checkTodo(int todoId) async {
  try {
    final String email = await getEmailFromPreferences();
    final dynamic data = jsonEncode({"email": email, "id": todoId});
    final String checkTodoRoute = "${dotenv.get('server')}/check_todo";
    var response = await Dio().put(checkTodoRoute, data: data);
    return response.statusCode == 200 ? true : false;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> uncheckTodo(int todoId) async {
  try {
    final String email = await getEmailFromPreferences();
    final dynamic data = jsonEncode({"email": email, "id": todoId});
    final String uncheckTodoRoute = "${dotenv.get('server')}/uncheck_todo";
    var response = await Dio().put(uncheckTodoRoute, data: data);
    return response.statusCode == 200 ? true : false;
  } catch (e) {
    print(e);
    return false;
  }
}
