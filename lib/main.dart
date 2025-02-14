import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
              title: 'New Todo', isCompleted: false, created: DateTime.now()));
        },
      ),
    );
  }
}

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
  List<Todo> _todos = [];
  bool _hideCompleted = false;

  TodoAppState() {
    _loadTodos();
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
    debugPrint('Todos saved: $todos');
  }

  Future _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todos');

    if (todosJson != null) {
      final List jsonList = json.decode(todosJson);
      _todos = jsonList.map((json) => Todo.fromJson(json)).toList();
      notifyListeners();
      debugPrint('Todos loaded: $todos');
    }
  }

  void toggleHideCompleted() {
    _hideCompleted = !_hideCompleted;
    notifyListeners();
  }
}

class Todo {
  String title;
  bool isCompleted = false;
  DateTime created = DateTime.now();

  Todo({
    required this.title,
    this.isCompleted = false,
    required this.created,
  });

  // JSON 직렬화 및 역직렬화 메소드를 추가
  Map toJson() => {
        'title': title,
        'completed': isCompleted,
        'created': created.toIso8601String(),
      };

  factory Todo.fromJson(Map json) => Todo(
        title: json['title'],
        isCompleted: json['completed'],
        created: DateTime.parse(json['created']),
      );
}
