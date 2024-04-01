import 'package:dio/dio.dart';
import 'package:mi_utem/config/constants.dart';
import 'package:mi_utem/models/user/credential.dart';
import 'package:mi_utem/models/user/user.dart';
import 'package:mi_utem/repositories/interfaces/auth_repository.dart';
import 'package:mi_utem/utils/http/http_client.dart';

class AuthRepositoryImplementation extends AuthRepository {

  final _httpClient = HttpClient.httpClient;

  @override
  Future<User> auth({required Credentials credentials}) async {
    final response = await _httpClient.post("$apiUrl/v1/auth", data: credentials.toJson());
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> refresh({required String token, required Credentials credentials}) async {
    final response = await _httpClient.post("$apiUrl/v1/auth/refresh", data: credentials.toJson(), options: Options(headers: {"Authorization": "Bearer $token"}));
    final json = response.data as Map<String, dynamic>;
    return json["token"];
  }

  @override
  Future<String> updateProfilePicture({required String image}) async {
    final response = await HttpClient.authClient.put("$apiUrl/v1/usuarios/foto", data: ({"imagen": image}));
    final json = response.data;

    return json["fotoUrl"] as String;
  }

}