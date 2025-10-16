import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lets_do_it/app/bindings/remote_config_binding.dart';
import 'package:lets_do_it/app/bindings/theme_binding.dart';
import 'package:lets_do_it/app/bindings/task_binding.dart';
import 'package:lets_do_it/app/controllers/theme_controller.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/routes/app_views.dart';
import 'package:path_provider/path_provider.dart';
import 'app/data/ad_service.dart';
import 'core/theme/theme_constants.dart';
import 'package:device_preview/device_preview.dart';
import 'firebase_options.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(TodoTaskAdapter());
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.openBox<TodoTask>('tasks', path: appDocumentDir.path);
  await Hive.openBox('settings');
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setDefaults(<String, dynamic>{
    'max_free_tasks': 2,
    'toggle_reward_task_ad': true,
  });
  final themeController = Get.put(ThemeController());
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await dotenv.load(fileName: ".env");
  MobileAds.instance.initialize();
  await AdService.init();
  runApp(
    DevicePreview(
      // enabled: true,
      enabled: false,
      builder: (context) => MyApp(themeController: themeController),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;
  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Let’s Do It',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: '/splash',
        getPages: AppViews.routes,
        initialBinding: BindingsBuilder(() {
          ThemeBinding().dependencies();
          TaskBinding().dependencies();
          RemoteConfigBinding().dependencies();
        }),
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      );
    });
  }
}
