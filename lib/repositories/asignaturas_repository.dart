import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/models/asignaturas/asignatura.dart';
import 'package:mi_utem/models/user/user.dart';
import 'package:mi_utem/utils/http/http_client.dart';

class AsignaturasRepository {

  final _authClient = HttpClient.authClient;

  Future<List<Asignatura>?> getAsignaturas(String? carreraId, {bool forceRefresh = false}) async {
    if(carreraId == null) {
      return null;
    }

    final path = "carreras/$carreraId/asignaturas";
    final Response response = await _authClient.get("$apiUrl/v1/$path", options: buildCacheOptions(Duration(days: 7),
      forceRefresh: forceRefresh,
      subKey: path,
    ));

    final asignaturas = Asignatura.fromJsonList(response.data);
    for(int i = 0; i < asignaturas.length; i++) {
      final asignatura = await getNotasAsignatura(carreraId, asignaturas[i], forceRefresh: forceRefresh);
      if(asignatura != null) {
        asignaturas[i] = asignatura;
      }
    }

    return asignaturas;
  }

  Future<List<User>?> getEstudiantesAsignatura(Asignatura? asignatura, {bool forceRefresh = false}) async {
    if(asignatura == null) {
      return null;
    }

    final path = "asignaturas/${asignatura.codigo}";
    final response = await _authClient.get("$apiUrl/v1/$path", options: buildCacheOptions(Duration(days: 7),
      forceRefresh: forceRefresh,
      subKey: path,
    ));
    final json = response.data as Map<String, dynamic>;

    // Por ahora solo se actualizan los estudiantes
    return User.fromJsonList(json['estudiantes']);
  }

  Future<Asignatura?> getNotasAsignatura(String? carreraId, Asignatura? asignatura, { bool forceRefresh = false }) async {
    if(asignatura == null || carreraId == null) {
      return null;
    }

    final path = "carreras/$carreraId/asignaturas/${asignatura.id}/notas";

    final response = await _authClient.get("$apiUrl/v1/$path", options: buildCacheOptions(Duration(days: 7),
      forceRefresh: forceRefresh,
      subKey: path,
    ));

    return Asignatura.fromJson({
      ...asignatura.toJson(),
      'notas': response.data as Map<String, dynamic>,
    });
  }

}