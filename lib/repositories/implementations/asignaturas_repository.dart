import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/models/asignaturas/asignatura.dart';
import 'package:mi_utem/repositories/interfaces/asignaturas_repository.dart';
import 'package:mi_utem/utils/http/http_client.dart';

class AsignaturasRepositoryImplementation implements AsignaturasRepository {

  final _authClient = HttpClient.authClient;

  @override
  Future<List<Asignatura>?> getAsignaturas(String? carreraId, {bool forceRefresh = false}) async {
    if(carreraId == null) {
      return null;
    }

    final _cacheOptions = buildCacheOptions(Duration(days: 7),
      forceRefresh: forceRefresh,
      subKey: 'carreras/$carreraId/asignaturas',
    );

    final Response response = await _authClient.get('$apiUrl/v1/carreras/$carreraId/asignaturas', options: _cacheOptions);

    return Asignatura.fromJsonList(response.data);
  }

  @override
  Future<Asignatura?> getDetalleAsignatura(Asignatura? asignatura, {bool forceRefresh = false}) async {
    if(asignatura == null) {
      return null;
    }

    final _cacheOptions = buildCacheOptions(Duration(days: 7),
      forceRefresh: forceRefresh,
      subKey: 'asignaturas/${asignatura.codigo}',
    );

    final response = await _authClient.get('$apiUrl/v1/asignaturas/${asignatura.codigo}', options: _cacheOptions);
    final json = response.data as Map<String, dynamic>;

    // Por ahora solo se actualizan los estudiantes
    return Asignatura.fromJson({
      ...asignatura.toJson(),
      'estudiantes': json['estudiantes'],
    });
  }

}