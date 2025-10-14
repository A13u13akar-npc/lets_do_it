import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TodoTask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  DateTime createdAt;

  TodoTask(
      this.title, {
        this.description,
        DateTime? createdAt,
      }) : createdAt = createdAt ?? DateTime.now();

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      json['title'],
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };
}
