class ChatException implements Exception {
  final String message;
  final int statusCode;

  ChatException({required this.message, required this.statusCode});
}
