import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/models/noticia.dart';
import 'package:mi_utem/repositories/interfaces/noticias_repository.dart';
import 'package:mi_utem/utils/http/http_client.dart';

class NoticiasRepositoryImplementation implements NoticiasRepository {

  final _httpClient = HttpClient.httpClient;

  @override
  Future<List<Noticia>?> getNoticias({ bool forceRefresh = false }) async {
    final response = await _httpClient.get("$apiUrl/v1/noticias", options: buildCacheOptions(Duration(days: 14), forceRefresh: forceRefresh, subKey: "/noticias"));
    return Noticia.fromJsonList(response.data as List<dynamic>);
  }

}