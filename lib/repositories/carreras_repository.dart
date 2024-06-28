import 'package:mi_utem/models/carrera.dart';
import 'package:mi_utem/utils/http/functions.dart';

class CarrerasRepository {

  Future<List<Carrera>> getCarreras({ bool forceRefresh = false }) async {
    final response = await authClientRequest("carreras",
      forceRefresh: forceRefresh,
      ttl: Duration(days: 60),
    );
    return Carrera.fromJsonList(response.data as List<dynamic>);
  }

}