import 'package:flutter/material.dart';
import 'package:lets_do_it/app/data/model/todoModel.dart';
import 'package:lets_do_it/core/theme/themeProvider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/modules/views/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoTaskAdapter());
  var appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.openBox<TodoTask>('tasks', path: appDocumentDir.path);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light(), // Provide your light theme here
            darkTheme: ThemeData.dark(), // Provide your dark theme here
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
