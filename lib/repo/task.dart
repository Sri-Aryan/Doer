enum Priority { low, medium, high }

enum RecurringType { none, daily, weekly }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;
  final String? prerequisiteTaskId;
  final RecurringType recurringType;
  final int? sortOrder;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.prerequisiteTaskId,
    this.recurringType = RecurringType.none,
    this.sortOrder,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    Object? prerequisiteTaskId = _sentinel,
    RecurringType? recurringType,
    Object? sortOrder = _sentinel,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      prerequisiteTaskId: prerequisiteTaskId == _sentinel
          ? this.prerequisiteTaskId
          : prerequisiteTaskId as String?,
      recurringType: recurringType ?? this.recurringType,
      sortOrder: sortOrder == _sentinel
          ? this.sortOrder
          : sortOrder as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'prerequisiteTaskId': prerequisiteTaskId,
      'recurringType': recurringType.name,
      'sortOrder': sortOrder,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      priority: Priority.values.firstWhere((e) => e.name == map['priority']),
      isCompleted: map['isCompleted'] ?? false,
      prerequisiteTaskId: map['prerequisiteTaskId'] as String?,
      recurringType: RecurringType.values.firstWhere(
        (e) => e.name == map['recurringType'],
        orElse: () => RecurringType.none,
      ),
      sortOrder: map['sortOrder'] as int?,
    );
  }
}

const Object _sentinel = Object();
