import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:get/get.dart';
import 'package:mi_utem/services/interfaces/auth_service.dart';
import 'package:mi_utem/services/interfaces/grades_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final _backgroundFetchConfig = BackgroundFetchConfig(
  minimumFetchInterval: 30,
  startOnBoot: true,
  stopOnTerminate: false,
  enableHeadless: true,
  requiresBatteryNotLow: false,
  requiresCharging: false,
  requiresStorageNotLow: false,
  requiresDeviceIdle: false,

  // Se necesita conexión a internet para funcionar.
  requiredNetworkType: NetworkType.ANY,
);

class BackgroundController {
  // [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
  // Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
  @pragma('vm:entry-point')
  static void backgroundFetchHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      BackgroundFetch.finish(taskId);
      return;
    }
    BackgroundFetch.finish(taskId);
  }
}

class BackgroundService {

  static Future<void> initAndStart() async {
    BackgroundFetch.registerHeadlessTask(
        BackgroundController.backgroundFetchHeadlessTask);
    await BackgroundFetch.configure(
        _backgroundFetchConfig, _onFetch, _onTimeout);

    BackgroundFetch.start().then((_) {}).catchError((e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    });
  }

  static _onFetch(String taskId) async {
    // Refresca el token de autenticación
    await Get.find<AuthService>().isLoggedIn(forceRefresh: true);

    // Revisa si hubo un cambio en las notas
    await Get.find<GradesService>().lookForGradeUpdates();

    // Termina la tarea de segundo plano
    BackgroundFetch.finish(taskId);
  }

  static _onTimeout(String taskId) async {
    Sentry.captureMessage("Se agotó el tiempo de espera para la tarea '$taskId'",
      level: SentryLevel.warning,
    );
    BackgroundFetch.finish(taskId);
  }
}
