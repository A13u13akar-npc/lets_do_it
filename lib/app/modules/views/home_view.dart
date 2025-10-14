import 'package:flutter/material.dart';
import 'package:lets_do_it/app/modules/views/task_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: TaskView(),
      ),
    );
  }
}


