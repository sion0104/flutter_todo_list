import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/widgets/floating_add.dart';

import '../../models/todo.dart';
import './todo_list.dart';

class TodoAppState extends ChangeNotifier {
  List<Todo> _todos = [];
  bool _hideCompleted = false;

  TodoAppState() {
    loadTodos();
  }

  List get todos {
    if (_hideCompleted) {
      return _todos.where((todo) => !todo.isCompleted).toList();
    }
    return _todos;
  }

  bool get hideCompleted => _hideCompleted;

  void addTodo(Todo todo) {
    todos.add(todo);
    saveTodos();
    notifyListeners();
    debugPrint('addTodo: ${todo.title} ${todo.created}');
  }

  void removeTodoAt(int index) {
    todos.removeAt(index);
    saveTodos();
    notifyListeners();
    debugPrint('removeTodoAt($index)');
  }

  int todoCount() {
    return todos.length;
  }

  void toggleTodoCompletion(int index) {
    _todos[index].isCompleted = !_todos[index].isCompleted;
    saveTodos();
    notifyListeners();
    debugPrint('toggleTodoCompletion: ${_todos[index].title}');
  }

  Future saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosJson =
        jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', todosJson);
    debugPrint('Todos saved: $_todos');
  }

  Future loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todos');

    if (todosJson != null) {
      final List jsonList = json.decode(todosJson);
      _todos = jsonList.map((json) => Todo.fromJson(json)).toList();
      notifyListeners();
      debugPrint('Todos loaded: $_todos');
    }
  }

  void toggleHideCompleted() {
    _hideCompleted = !_hideCompleted;
    notifyListeners();
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key, required this.title});
  final String title;

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Provider.of<TodoAppState>(context, listen: false)
                  .toggleHideCompleted();
            },
          ),
        ],
      ),
      body: Consumer<TodoAppState>(
        builder: (context, appState, child) {
          return TodoList();
        },
      ),
      floatingActionButton: FloatingAddButton(
        onPressed: () {
          final appState = Provider.of<TodoAppState>(context, listen: false);
          appState.addTodo(Todo(
              title: 'Tab hear...',
              isCompleted: false,
              created: DateTime.now(),
              category: 'General',
              priority: 'Medium'));
        },
      ),
    );
  }
}
