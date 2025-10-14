// import 'package:hive/hive.dart';
// part 'todoModel.g.dart';
//
// @HiveType(typeId: 0)
// class TodoTask extends HiveObject {
//   @HiveField(0)
//   final String title;
//
//   @HiveField(1)
//   final String startTime;
//
//   @HiveField(2)
//   final String endTime;
//
//   @HiveField(3)
//   bool isCompleted;
//
//   TodoTask(this.title, this.startTime, this.endTime, this.isCompleted);
//
//   factory TodoTask.fromJson(Map<String, dynamic> json) {
//     return TodoTask(
//       json['title'],
//       json['startTime'],
//       json['endTime'],
//       json['isCompleted'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'title': title,
//         'startTime': startTime,
//         'endTime': endTime,
//         'isCompleted': isCompleted,
//       };
// }

import 'package:hive/hive.dart';
part 'todoModel.g.dart';

@HiveType(typeId: 0)
class TodoTask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String startTime;

  @HiveField(2)
  String endTime;

  @HiveField(3)
  bool isCompleted;

  TodoTask(this.title, this.startTime, this.endTime, this.isCompleted);

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      json['title'],
      json['startTime'],
      json['endTime'],
      json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'startTime': startTime,
    'endTime': endTime,
    'isCompleted': isCompleted,
  };
}
