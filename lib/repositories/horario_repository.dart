import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/models/horario.dart';
import 'package:mi_utem/utils/http/http_client.dart';

class HorarioRepository {
  final _authClient = HttpClient.authClient;

  Future<Horario?> getHorario(String carreraId, {bool forceRefresh = false}) async {
    final response = await _authClient.get("$apiUrl/v1/carreras/$carreraId/horarios", options: buildCacheOptions(Duration(days: 7), forceRefresh: forceRefresh, subKey: "carreras/$carreraId/horarios"));
    return Horario.fromJson(response.data);
  }
}
