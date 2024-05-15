import 'package:dio/dio.dart';
import 'package:mi_utem/models/exceptions/custom_exception.dart';

InterceptorsWrapper errorInterceptor = InterceptorsWrapper(
  onError: (DioError err, ErrorInterceptorHandler handler) {
    if(err.response?.statusCode == 401) {
      return handler.next(err);
    }

    final json = err.response?.data ?? {};
    if(json is Map && json.containsKey("error")) {
      return handler.reject(DioError(requestOptions: err.requestOptions, error: CustomException.fromJson(json as Map<String, dynamic>)));
    }

    final error = DioError(requestOptions: err.requestOptions, error: CustomException.custom(err.response?.statusMessage), response: err.response, type: err.type);
    error.stackTrace = err.stackTrace;
    return handler.reject(error);
  },
);