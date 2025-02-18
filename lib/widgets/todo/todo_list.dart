import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/widgets/todo/todo_item.dart';
import 'package:todo_list/widgets/todo/todo_page.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoAppState>(builder: (context, appState, child) {
      return ListView.builder(
        itemCount: appState.todos.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              appState.removeTodoAt(index);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: TodoItem(
              todo: appState.todos[index],
              index: index, // 추가
              onDelete: () {
                appState.removeTodoAt(index);
              },
            ),
          );
        },
      );
    });
  }
}
