import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/utils/http/http_client.dart';


/// Función para realizar solicitudes mediante el authClient.
/// Esta función además genera un [CacheOptions] con opciones personalizadas por defecto.
/// También esta función utiliza `$apiUrl/v1/` como prefijo.
///
/// [path] es el endpoint al que se desea acceder. No puede tener el prefijo `/v1/` o `/`.
/// [method] es el método HTTP a utilizar.
/// [data] es un mapa con los datos a enviar.
/// [options] son las opciones personalizadas para la solicitud.
/// [forceRefresh] fuerza a que se realice una solicitud nueva.
/// [ttl] es el tiempo que se guardará en caché la solicitud.
Future<Response> authClientRequest(String path, {
  String method = "GET",
  Map<String, String>? headers,
  Map<String, dynamic>? data,
  String? contentType,
  ResponseType? responseType,
  Options? options,
  bool forceRefresh = false,
  Duration? ttl = const Duration(days: 7),
}) async => await HttpClient.authClient.request("$apiUrl/v1/$path",
  data: data,
  options: options ?? buildCacheOptions(ttl ?? Duration(days: 7),
    forceRefresh: forceRefresh,
    primaryKey: 'miutem',
    subKey: path,
    maxStale: const Duration(days: 14),
  ).copyWith(
    method: method,
    headers: headers,
    contentType: contentType,
    responseType: responseType,
  ),
);