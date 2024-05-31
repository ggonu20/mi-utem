import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:mi_utem/models/carrera.dart';
import 'package:mi_utem/models/user/user.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AnalyticsService {
  static Future<void> setUser(User user) async {
    await FirebaseAnalytics.instance.setUserId(id: user.correoUtem);
    await FlutterUxcam.setUserIdentity(user.correoUtem);

    if (user.rut != null) {
      await FirebaseAnalytics.instance.setUserProperty(name: "rut", value: user.rut?.toString());
      await FlutterUxcam.setUserProperty("rut", user.rut!.toString());
    }

    if (user.primerNombre != null) {
      await FirebaseAnalytics.instance.setUserProperty(name: "name", value: user.primerNombre);
      await FlutterUxcam.setUserProperty("name", user.primerNombre);
    }

    if (user.apellidos != null) {
      await FirebaseAnalytics.instance.setUserProperty(name: "last_name", value: user.apellidos);
      await FlutterUxcam.setUserProperty("last_name", user.apellidos!);
    }

    final correoUtem = user.correoUtem;

    await Sentry.configureScope((scope) => scope.setUser(SentryUser(
      id: correoUtem,
      email: correoUtem,
      name: user.nombreCompletoCapitalizado,
      username: user.username,
      data: {
        "backend_uid": correoUtem != null ? md5.convert(utf8.encode(correoUtem)) : "desconocido",
      },
      ipAddress: "{{auto}}",
    )));
  }

  static Future<void> setCarreraToUser(Carrera carrera) async {
    if (carrera.nombre != null) {
      await FirebaseAnalytics.instance.setUserProperty(name: "carreraActiva", value: carrera.nombre!);
      await FlutterUxcam.setUserProperty("carreraActiva", carrera.nombre!);
    }

    if (carrera.estado != null) {
      await FirebaseAnalytics.instance.setUserProperty(name: "estadoCarreraActiva", value: carrera.estado!);
      await FlutterUxcam.setUserProperty("estadoCarreraActiva", carrera.estado!);
    }

    await Sentry.configureScope((scope) => scope.setUser(scope.user?.copyWith(
      data: {
        ...?scope.user?.data,
        "carrera": carrera.nombre,
        "estado_carrera": carrera.estado,
      },
    )));
  }

  static Future<void> removeUser() async {
    await FirebaseAnalytics.instance.setUserId(id: null);
    await FlutterUxcam.setUserIdentity(null);
    await Sentry.configureScope((scope) => scope.setUser(null));
  }

  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);

    if (parameters != null) {
      await FlutterUxcam.logEventWithProperties(name, parameters);
    } else {
      await FlutterUxcam.logEvent(name);
    }

    Sentry.metrics().increment(name, tags: parameters?.map((key, value) => MapEntry(key, value.toString())));
  }
}
