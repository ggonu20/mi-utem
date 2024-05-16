import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/utils/http/interceptors/auth_interceptor.dart';
import 'package:mi_utem/utils/http/interceptors/error_interceptor.dart';
import 'package:mi_utem/utils/http/interceptors/headers_interceptor.dart';
import 'package:mi_utem/utils/http/interceptors/log_interceptor.dart';

class HttpClient {

  static final DioCacheManager cacheManager = DioCacheManager(CacheConfig(
    baseUrl: apiUrl,
    defaultMaxAge: const Duration(days: 7),
    defaultMaxStale: const Duration(days: 14),
  ));

  static final Dio httpClient = Dio(BaseOptions(baseUrl: apiUrl))..interceptors.addAll([
    HeadersInterceptor(),
    errorInterceptor,
    logInterceptor,
    cacheManager.interceptor,
  ]);

  static final Dio authClient = httpClient..interceptors.add(AuthInterceptor());

  static Future<void> clearCache() async {
    await cacheManager.deleteByPrimaryKey("miutem");
    await cacheManager.clearExpired();
    await cacheManager.clearAll();
  }
}