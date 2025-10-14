import 'package:get/get.dart';
import 'package:lets_do_it/app/bindings/todo_binding.dart';
import 'package:lets_do_it/app/modules/views/add_task_view.dart';
import 'package:lets_do_it/app/modules/views/task_view.dart';
import 'package:lets_do_it/app/modules/views/pay_for_tasks_view.dart';
import 'package:lets_do_it/app/modules/views/home_view.dart';
import 'package:lets_do_it/app/modules/views/tasks_details_view.dart';

class AppViews {
  static const initial = '/home';

  static final routes = [
    GetPage(
      name: '/home',
      page: () => const HomeView(),
      binding: TodoBinding(),
    ),
    GetPage(
      name: '/viewTask',
      page: () => const TaskView(),
      binding: TodoBinding(),
    ),
    GetPage(
      name: '/addTask',
      page: () => const AddTaskView(),
    ),
    GetPage(
      name: '/taskDetails',
      page: () => const TaskDetailsView(),
    ),
    GetPage(
      name: '/pay',
      page: () => const PayForTasksView(),
    ),
  ];
}
