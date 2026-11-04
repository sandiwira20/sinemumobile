class ChatbotMessageModel {
  const ChatbotMessageModel({
    required this.role,
    required this.content,
    this.createdAt,
    this.isError = false,
  });

  final String role; // 'user' atau 'assistant'
  final String content;
  final DateTime? createdAt;
  final bool isError;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory ChatbotMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatbotMessageModel(
      role: json['role']?.toString() ?? 'assistant',
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

