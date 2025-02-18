class Todo {
  String title;
  bool isCompleted;
  DateTime created;
  String category;
  String priority;
  DateTime? dueDate;
  String? notes;
  List tags;

  Todo({
    required this.title,
    this.isCompleted = false,
    required this.created,
    required this.category,
    required this.priority,
    this.dueDate,
    this.notes,
    this.tags = const [],
  });

  Map toJson() => {
        'title': title,
        'completed': isCompleted,
        'created': created.toIso8601String(),
        'category': category,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'notes': notes,
        'tags': tags,
      };

  factory Todo.fromJson(Map json) => Todo(
        title: json['title'],
        isCompleted: json['completed'],
        created: DateTime.parse(json['created']),
        category: json['category'],
        priority: json['priority'],
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        notes: json['notes'],
        tags: List.from(json['tags']),
      );
}
