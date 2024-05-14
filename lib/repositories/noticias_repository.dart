import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/models/noticia.dart';
import 'package:mi_utem/utils/http/http_client.dart';
import 'package:mi_utem/utils/http/interceptors/headers_interceptor.dart';

class NoticiasRepository {

  final _httpClient = Dio(BaseOptions(baseUrl: "https://noticias.utem.cl"))..interceptors.addAll([
    HeadersInterceptor(),
    HttpClient.logInterceptor,
    DioCacheManager(CacheConfig(
      baseUrl: "https://noticias.utem.cl",
      defaultMaxAge: Duration(days: 7),
      defaultMaxStale: Duration(days: 60),
      databaseName: 'utem_noticias_cache',
    )).interceptor,
  ]);

  Future<List<Noticia>?> getNoticias({ bool forceRefresh = false }) async {
    final hasta = DateTime.now().toUtc().toIso8601String();
    final desde = DateTime.now().subtract(Duration(days: 180)).toUtc().toIso8601String();
    final response = await _httpClient.get("/wp-json/wp/v2/posts?_embed&_fields=id,yoast_head_json&per_page=10&before=$hasta&after=$desde", options: buildCacheOptions(Duration(days: 14), forceRefresh: forceRefresh, subKey: "/noticias"));
    if (response.statusCode != 200) {
      return null;
    }

    return Noticia.fromJsonList(response.data as List<dynamic>);
  }

}