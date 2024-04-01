import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/models/permiso_ingreso.dart';
import 'package:mi_utem/repositories/interfaces/permiso_ingreso_repository.dart';
import 'package:mi_utem/utils/http/http_client.dart';

class PermisoIngresoRepositoryImplementation extends PermisoIngresoRepository {

  final _authClient = HttpClient.authClient;

  @override
  Future<PermisoIngreso> getDetallesPermiso(String id, { bool forceRefresh = false }) async {
    final response = await _authClient.post("$apiUrl/v1/permisos/$id", options: buildCacheOptions(Duration(days: 7), forceRefresh: forceRefresh, subKey: "/permisos/$id"));
    return PermisoIngreso.fromJson(response.data as Map<String, dynamic>?);
  }

  @override
  Future<List<PermisoIngreso>> getPermisos({ bool forceRefresh = false }) async {
    final response = await _authClient.post("$apiUrl/v1/permisos", options: buildCacheOptions(Duration(days: 7), forceRefresh: forceRefresh, subKey: "/permisos"));
    return PermisoIngreso.fromJsonList(response.data as List<dynamic>?);
  }

}