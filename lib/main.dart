import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoAppState(),
      child: MaterialApp(
        title: 'Todo Demo ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const TodoPage(title: 'Todo'),
        debugShowCheckedModeBanner: false,
      ),
    );
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
            title: 'New Todo',
            isCompleted: false,
          ));
        },
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<TodoAppState>(context);
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
  }
}

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
              .toggleTodoAtIndex(index);
        },
      ),
      title: Text(
        todo.title,
        style: todo.isCompleted
            ? TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text('Details about ${todo.title}'),
      onTap: () {
        final route = MaterialPageRoute(
          builder: (context) => TodoDetailPage(todo: todo, index: index),
        );
        Navigator.push(context, route);
      },
    );
  }
}

class TodoDetailPage extends StatelessWidget {
  final Todo todo;
  final int index;

  const TodoDetailPage({super.key, required this.todo, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(todo.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: TextEditingController(text: todo.title),
              onChanged: (String value) {
                todo.title = value;
              },
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<TodoAppState>(context, listen: false).todos[index] =
                    todo;
                Provider.of<TodoAppState>(context, listen: false).saveTodos();
                Provider.of<TodoAppState>(context, listen: false)
                    ._loadTodos()
                    .then((_) {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingAddButton extends StatelessWidget {
  const FloatingAddButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}

class TodoAppState extends ChangeNotifier {
  List<Todo> todos = [];

  TodoAppState() {
    _loadTodos();
  }

  void addTodo(Todo todo) {
    todos.add(todo);
    saveTodos();
    notifyListeners();
    debugPrint('addTodo: ${todo.title}');
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

  void toggleTodoAtIndex(int index) {
    todos[index].isCompleted = !todos[index].isCompleted;
    notifyListeners();
  }

  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosJson = jsonEncode(todos
        .map((todo) => {
              'title': todo.title,
              'completed': todo.isCompleted,
            })
        .toList());
    await prefs.setString('todos', todosJson);
    debugPrint('Todos saved: $todos');
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todos');

    if (todosJson != null) {
      final List<dynamic> jsonList = json.decode(todosJson);
      todos = jsonList
          .map((json) => Todo(
                title: json['title'],
                isCompleted: json['completed'],
              ))
          .toList();
      notifyListeners();
      debugPrint('Todos loaded: $todos');
    }
  }
}

class Todo {
  String title;
  bool isCompleted = false;

  Todo({
    required this.title,
    required this.isCompleted,
  });
}
