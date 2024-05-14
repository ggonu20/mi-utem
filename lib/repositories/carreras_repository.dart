import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/models/carrera.dart';
import 'package:mi_utem/utils/http/http_client.dart';

class CarrerasRepository {

  final _authClient = HttpClient.authClient;

  Future<List<Carrera>> getCarreras({ bool forceRefresh = false }) async {
    final response = await _authClient.get("$apiUrl/v1/carreras", options: buildCacheOptions(Duration(days: 7), forceRefresh: forceRefresh, subKey: '/carreras'));
    return Carrera.fromJsonList(response.data as List<dynamic>);
  }

}