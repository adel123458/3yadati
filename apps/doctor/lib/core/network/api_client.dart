import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kBaseUrlKey = 'apiBaseUrl';
const String defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage)
      : _dio = Dio(
          BaseOptions(
            baseUrl: defaultBaseUrl,
            connectTimeout: const Duration(milliseconds: 1500),
            receiveTimeout: const Duration(milliseconds: 3000),
            sendTimeout: const Duration(milliseconds: 1500),
            contentType: 'application/json',
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'accessToken');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;

  Future<void> setToken(String? token) async {
    if (token == null) {
      await _storage.delete(key: 'accessToken');
    } else {
      await _storage.write(key: 'accessToken', value: token);
    }
  }

  Future<String?> getToken() => _storage.read(key: 'accessToken');

  Future<void> setBaseUrl(String url) async {
    _dio.options.baseUrl = url;
    await _storage.write(key: _kBaseUrlKey, value: url);
  }
}
