import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class MultipartUploadFile {
  const MultipartUploadFile({
    required this.fieldName,
    required this.filePath,
    this.fileName,
  });

  final String fieldName;
  final String filePath;
  final String? fileName;
}

class ApiClient {
  ApiClient({http.Client? httpClient, TokenStorage? tokenStorage})
    : _httpClient = httpClient ?? http.Client(),
      _tokenStorage = tokenStorage ?? const TokenStorage();

  final http.Client _httpClient;
  final TokenStorage _tokenStorage;

  Future<dynamic> get(String path, {bool requiresAuth = true}) {
    return _send('GET', path, requiresAuth: requiresAuth);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send('POST', path, body: body, requiresAuth: requiresAuth);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send('PUT', path, body: body, requiresAuth: requiresAuth);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send('PATCH', path, body: body, requiresAuth: requiresAuth);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send('DELETE', path, body: body, requiresAuth: requiresAuth);
  }

  Future<dynamic> multipart(
    String method,
    String path, {
    Map<String, String> fields = const {},
    List<MultipartUploadFile> files = const [],
    bool requiresAuth = true,
  }) {
    return _sendMultipart(
      method,
      path,
      fields: fields,
      files: files,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final request = http.Request(method, _buildUri(path));
      request.headers.addAll(await _buildHeaders(requiresAuth: requiresAuth));

      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamedResponse = await _httpClient
          .send(request)
          .timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Koneksi ke server terlalu lama. Coba lagi beberapa saat.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak bisa terhubung ke server. Periksa koneksi atau base URL API.',
      );
    } on FormatException {
      throw const ApiException('Response server tidak valid.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Terjadi kesalahan saat menghubungi server.');
    }
  }

  Future<dynamic> _sendMultipart(
    String method,
    String path, {
    required Map<String, String> fields,
    required List<MultipartUploadFile> files,
    required bool requiresAuth,
  }) async {
    try {
      final request = http.MultipartRequest(method, _buildUri(path));
      request.headers.addAll(
        await _buildHeaders(
          requiresAuth: requiresAuth,
          includeContentType: false,
        ),
      );
      request.fields.addAll(fields);

      for (final file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(
            file.fieldName,
            file.filePath,
            filename: file.fileName,
          ),
        );
      }

      final streamedResponse = await _httpClient
          .send(request)
          .timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Koneksi ke server terlalu lama. Coba lagi beberapa saat.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak bisa terhubung ke server. Periksa koneksi atau base URL API.',
      );
    } on FormatException {
      throw const ApiException('Response server tidak valid.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Terjadi kesalahan saat menghubungi server.');
    }
  }

  Uri _buildUri(String path) {
    final baseUrl = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse('$baseUrl/$normalizedPath');
  }

  Future<Map<String, String>> _buildHeaders({
    required bool requiresAuth,
    bool includeContentType = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (requiresAuth) {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final data = _decodeBody(response.body, response.statusCode);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final errors = data is Map<String, dynamic> && data['errors'] is Map
        ? Map<String, dynamic>.from(data['errors'] as Map)
        : null;

    throw ApiException(
      _errorMessage(response.statusCode, data, errors),
      statusCode: response.statusCode,
      errors: errors,
    );
  }

  dynamic _decodeBody(String body, int statusCode) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } on FormatException {
      if (statusCode >= 200 && statusCode < 300) {
        throw const ApiException('Response server tidak valid.');
      }

      return <String, dynamic>{};
    }
  }

  String _errorMessage(
    int statusCode,
    dynamic data,
    Map<String, dynamic>? errors,
  ) {
    final serverMessage = _readServerMessage(data);

    if (statusCode == 401) {
      return serverMessage ?? 'Login gagal atau sesi sudah berakhir.';
    }

    if (statusCode == 403) {
      return serverMessage ?? 'Tidak punya akses untuk request ini.';
    }

    if (statusCode == 404) {
      return serverMessage ?? 'Data tidak ditemukan.';
    }

    if (statusCode == 413) {
      return serverMessage ?? 'Ukuran foto terlalu besar.';
    }

    if (statusCode == 422) {
      return _firstValidationError(errors) ??
          serverMessage ??
          'Data yang dikirim belum valid.';
    }

    if (statusCode >= 500) {
      return serverMessage ?? 'Server sedang bermasalah. Coba lagi nanti.';
    }

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    return 'Request gagal dengan status $statusCode.';
  }

  String? _readServerMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    for (final key in ['message', 'error', 'pesan']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String? _firstValidationError(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) {
      return null;
    }

    final firstValue = errors.values.first;
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }

    return firstValue.toString();
  }
}
