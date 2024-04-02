import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mi_utem/config/logger.dart';
import 'package:mi_utem/models/exceptions/custom_exception.dart';
import 'package:mi_utem/utils/http/interceptors/auth_interceptor.dart';
import 'package:mi_utem/utils/http/interceptors/headers_interceptor.dart';

class HttpClient {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static String debugUrl = dotenv.env['MI_UTEM_API_DEBUG'] ?? 'https://api.exdev.cl/';
  static const String productionUrl = 'https://api.exdev.cl/';
  static String url = isProduction ? productionUrl : debugUrl;

  static CacheConfig cacheConfig = CacheConfig(
    baseUrl: url,
    defaultMaxAge: Duration(days: 7),
    defaultMaxStale: Duration(days: 60),
  );

  static DioCacheManager dioCacheManager = DioCacheManager(cacheConfig);

  static Dio httpClient = Dio(BaseOptions(baseUrl: url))..interceptors.addAll([
    HeadersInterceptor(),
    _errorInterceptor,
    _logInterceptor,
    dioCacheManager.interceptor,
  ]);

  static Dio get authClient => httpClient..interceptors.add(AuthInterceptor());

  static InterceptorsWrapper _errorInterceptor = InterceptorsWrapper(
    onError: (DioError err, ErrorInterceptorHandler handler) {
      final json = err.response?.data ?? {};
      if(json is Map && json.containsKey("error")) {
        throw CustomException.fromJson(json as Map<String, dynamic>);
      }

      throw CustomException.custom(err.response?.statusMessage);
    },
  );

  static InterceptorsWrapper _logInterceptor = InterceptorsWrapper(
    onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      logger.d("[HttpClient]: ${options.method.toUpperCase()} ${options.uri}");
      options.extra["request_created_at"] = DateTime.now().toIso8601String();
      return handler.next(options);
    },
    onResponse: (Response response, ResponseInterceptorHandler handler) {
      final now = DateTime.now();
      final request = DateTime.tryParse(response.requestOptions.extra["request_created_at"] as String);
      if(request != null) {
        final duration = now.difference(request);
        logger.d("[HttpClient]: ${response.statusCode} > ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri} ${duration.inMilliseconds}ms");
      }
      return handler.next(response);
    },
  );
}
