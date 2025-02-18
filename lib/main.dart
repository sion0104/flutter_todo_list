import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/widgets/todo/todo_page.dart';

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
