import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/category.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/widgets/todo/todo_page.dart';

class TodoDetailPage extends StatefulWidget {
  final Todo todo;
  final int index;

  const TodoDetailPage({super.key, required this.todo, required this.index});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late Category _selectedCategory;
  late String _selectedPriority;
  late DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _notesController = TextEditingController(text: widget.todo.notes ?? '');
    _selectedCategory = widget.todo.category;
    _selectedPriority = widget.todo.priority;
    _dueDate = widget.todo.haveToDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
        widget.todo.haveToDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    widget.todo.title = value;
                  },
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    widget.todo.notes = value;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: Category.values
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          ))
                      .toList(),
                  onChanged: (Category? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                      widget.todo.category = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: ['High', 'Medium', 'Low']
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                      widget.todo.priority = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ListTile(
                  title: Text(
                      'Due Date: ${_dueDate != null ? _dueDate!.toLocal().toString().split(' ')[0] : 'No date selected'}'),
                  trailing: ElevatedButton(
                    onPressed: () => _selectDueDate(context),
                    child: const Text('Select Date'),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final appState =
                        Provider.of<TodoAppState>(context, listen: false);
                    appState.todos[widget.index] = widget.todo;
                    appState.saveTodos();
                    appState.loadTodos();
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
