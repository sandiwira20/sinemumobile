import 'package:flutter/material.dart';
import '../models/chatbot_message_model.dart';
import '../services/chatbot_service.dart';

class ChatbotSinuPage extends StatefulWidget {
  const ChatbotSinuPage({super.key});

  @override
  State<ChatbotSinuPage> createState() => _ChatbotSinuPageState();
}

class _ChatbotSinuPageState extends State<ChatbotSinuPage> {
  final ChatbotService _chatbotService = ChatbotService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatbotMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  final List<String> _quickSuggestions = [
    'Cara lapor barang hilang?',
    'Cara klaim barang temuan?',
    'Syarat pengambilan barang?',
    'Apa itu Sinemu?',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await _chatbotService.getHistory();
    if (!mounted) return;

    setState(() {
      _messages.addAll(history);
      _isInitLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? textToSend]) async {
    final text = textToSend ?? _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (textToSend == null) {
      _textController.clear();
    }

    setState(() {
      _messages.add(ChatbotMessageModel(
        role: 'user',
        content: text,
        createdAt: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    final response = await _chatbotService.sendMessage(text);
    if (!mounted) return;

    setState(() {
      _messages.add(ChatbotMessageModel(
        role: 'assistant',
        content: response,
        createdAt: DateTime.now(),
      ));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mulai Percakapan Baru?'),
        content: const Text(
          'Riwayat pesan saat ini akan dihapus dan sesi baru akan dimulai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4FCF),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Mulai Baru'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _chatbotService.resetConversation();
      if (!mounted) return;
      setState(() {
        _messages.clear();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5B4FCF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primaryColor.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinu — Asisten Sinemu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online • Siap Membantu',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Percakapan Baru',
            onPressed: _handleReset,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isInitLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : _messages.isEmpty
                    ? _buildWelcomeState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return _buildMessageBubble(msg);
                        },
                      ),
          ),
          if (_isLoading) _buildTypingIndicator(),
          if (_messages.isEmpty && !_isInitLoading) _buildSuggestionsBar(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF5B4FCF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 46,
                color: Color(0xFF5B4FCF),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Halo! Saya Sinu 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Asisten virtual resmi Sinemu Indonesia.\nTanyakan apa saja tentang cara lapor atau klaim barang!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _quickSuggestions.map((text) {
          return ActionChip(
            label: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF5B4FCF),
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFF5B4FCF).withValues(alpha: 0.08),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => _handleSend(text),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBubble(ChatbotMessageModel msg) {
    final isUser = msg.isUser;
    final timeStr = msg.createdAt != null
        ? '${msg.createdAt!.hour.toString().padLeft(2, '0')}:${msg.createdAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF5B4FCF).withValues(alpha: 0.12),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: Color(0xFF5B4FCF),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF5B4FCF) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: isUser ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  if (timeStr.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: isUser
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF5B4FCF).withValues(alpha: 0.12),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 14,
              color: Color(0xFF5B4FCF),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Text(
              'Sinu sedang mengetik...',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF5B4FCF),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Tanyakan sesuatu ke Sinu...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF5B4FCF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _isLoading ? null : () => _handleSend(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
