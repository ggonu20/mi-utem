import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/models/evaluacion/grades.dart';
import 'package:mi_utem/utils/http/http_client.dart';

class GradesRepository {
  final _authClient = HttpClient.authClient;

  Future<Grades> getGrades({required String carreraId, required String asignaturaId, bool forceRefresh = false}) async {
    final response = await _authClient.get("$apiUrl/v1/carreras/$carreraId/asignaturas/$asignaturaId/notas", options: buildCacheOptions(Duration(days: 7), forceRefresh: forceRefresh, subKey: "carreras/$carreraId/asignaturas/$asignaturaId/notas"));
    return Grades.fromJson(response.data as Map<String, dynamic>);
  }
}