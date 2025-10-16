import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/5354046379'
          : 'ca-app-pub-3940256099942544/5354046379';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
