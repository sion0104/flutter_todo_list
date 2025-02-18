import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/widgets/todo/todo_detail.dart';
import 'package:todo_list/widgets/todo/todo_page.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final int index;
  final VoidCallback onDelete;

  const TodoItem(
      {super.key,
      required this.todo,
      required this.index,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (bool? value) {
          Provider.of<TodoAppState>(context, listen: false)
              .toggleTodoCompletion(index);
        },
      ),
      title: Text(
        todo.title,
        style: todo.isCompleted
            ? TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(DateFormat('yyyy-MM-dd').format(todo.created)),
      onTap: () {
        final route = MaterialPageRoute(
          builder: (context) => TodoDetailPage(todo: todo, index: index),
        );
        Navigator.push(context, route);
      },
    );
  }
}
