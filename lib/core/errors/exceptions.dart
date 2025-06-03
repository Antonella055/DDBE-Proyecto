class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Error del servidor'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Error de caché'});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Error de red'});
}

class AuthExceptionCustom implements Exception {
  final String message;
  const AuthExceptionCustom({this.message = 'Error de autenticación'});
}