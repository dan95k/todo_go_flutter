import 'package:flutter/material.dart';
import 'package:frontend/functions/utils.dart';
import '../functions/requests.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({Key? key, required this.todo, required this.updateParent})
      : super(key: key);
  final Todo todo;
  final void Function(int, ListAction, Todo?) updateParent;
  Color todoColor() {
    switch (todo.urgency) {
      case Urgency.low:
        return const Color.fromARGB(255, 147, 221, 64);
      case Urgency.medium:
        return Colors.orange;
      case Urgency.high:
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        tileColor: const Color.fromARGB(255, 239, 239, 239),
        leading: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: todoColor(),
          ),
        ),
        title: Text(
          todo.text!,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: todo.finished != 0
                  ? TextDecoration.lineThrough
                  : TextDecoration.none),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => removeTodo(todo.id!).then(
                (value) => value
                    ? updateParent(todo.id!, ListAction.remove, null)
                    : ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Error removing todo"),
                        ),
                      ),
              ),
              icon: const Icon(Icons.clear),
            ),
            IconButton(
              onPressed: () => todo.finished == 0
                  ? checkTodo(todo.id!).then(
                      (value) => value
                          ? updateParent(todo.id!, ListAction.check, null)
                          : ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error checking todo"),
                              ),
                            ),
                    )
                  : uncheckTodo(todo.id!).then(
                      (value) => value
                          ? updateParent(todo.id!, ListAction.uncheck, null)
                          : ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error unchecking todo"),
                              ),
                            ),
                    ),
              icon: Icon(todo.finished == 0 ? Icons.done : Icons.restart_alt),
            )
          ],
        ),
      ),
    );
  }
}
