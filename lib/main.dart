import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  final VoidCallback onDelete;

  const TodoItem({super.key, required this.todo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.title),
      subtitle: Text('Details about ${todo.title}'),
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

  void addTodo(Todo todo) {
    todos.add(todo);
    notifyListeners();
    debugPrint('addTodo: ${todo.title}');
  }

  void removeTodoAt(int index) {
    todos.removeAt(index);
    notifyListeners();
    debugPrint('removeTodoAt($index)');
  }

  int todoCount() {
    return todos.length;
  }
}

class Todo {
  String title;

  Todo({
    required this.title,
  });
}
