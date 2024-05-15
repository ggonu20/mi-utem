import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mi_utem/utils/http/interceptors/auth_interceptor.dart';
import 'package:mi_utem/utils/http/interceptors/error_interceptor.dart';
import 'package:mi_utem/utils/http/interceptors/headers_interceptor.dart';
import 'package:mi_utem/utils/http/interceptors/log_interceptor.dart';

class HttpClient {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static String debugUrl = dotenv.env['MI_UTEM_API_DEBUG'] ?? 'https://api.exdev.cl/';
  static const String productionUrl = 'https://api.exdev.cl/';
  static String url = isProduction ? productionUrl : debugUrl;

  static DioCacheManager cacheManager = DioCacheManager(CacheConfig(
    defaultMaxAge: const Duration(days: 7),
    defaultMaxStale: const Duration(days: 14),
  ));
  static Dio httpClient = Dio(BaseOptions(baseUrl: url))..interceptors.addAll([
    HeadersInterceptor(),
    errorInterceptor,
    logInterceptor,
    cacheManager.interceptor,
  ]);

  static Dio authClient = httpClient..interceptors.add(AuthInterceptor());

  static Future<void> clearCache() async => await cacheManager.clearAll();
}