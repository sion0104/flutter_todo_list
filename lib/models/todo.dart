import 'package:todo_list/models/category.dart';

class Todo {
  String title;
  bool isCompleted;
  DateTime created;
  Category category;
  String priority;
  DateTime? haveToDate;
  String? notes;
  List tags;

  Todo({
    required this.title,
    this.isCompleted = false,
    required this.created,
    required this.category,
    required this.priority,
    this.haveToDate,
    this.notes,
    this.tags = const [],
  });

  Map toJson() => {
        'title': title,
        'completed': isCompleted,
        'created': created.toIso8601String(),
        'category': category.name,
        'priority': priority,
        'dueDate': haveToDate?.toIso8601String(),
        'notes': notes,
        'tags': tags,
      };

  factory Todo.fromJson(Map json) => Todo(
        title: json['title'],
        isCompleted: json['completed'],
        created: DateTime.parse(json['created']),
        category: CategoryExtension.fromString(json['category']),
        priority: json['priority'],
        haveToDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        notes: json['notes'],
        tags: List.from(json['tags']),
      );
}
