import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../services/gemini_service.dart';
import '../services/ad_service.dart';
import '../services/activity_log_service.dart';

class ChatbotScreen extends StatefulWidget {
  final bool embeddedMode;

  const ChatbotScreen({super.key, this.embeddedMode = false});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with AutomaticKeepAliveClientMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _geminiService = GeminiService();
  final _adService = AdService();
  final _activityLog = ActivityLogService();
  bool _hasLoggedSession = false;
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  int _freeQuestionsToday = 0;
  static const int _maxFreeQuestions = 5;

  @override
  bool get wantKeepAlive => widget.embeddedMode; // Tab modunda state koru

  String _selectedCategory = 'Genel';

  // Kategori emojileri
  static const Map<String, String> _categoryEmojis = {
    'Aşk': '💕',
    'Kariyer': '💼',
    'Finans': '💰',
    'Sağlık': '🏥',
    'İlişkiler': '👥',
    'Genel': '🔮',
  };

  // Kategorilere göre önerilen sorular
  static const Map<String, List<String>> _categoryQuestions = {
    'Aşk': [
      'Aşk hayatımda bu hafta ne olacak?',
      'Beni seven biri var mı hayatımda?',
      'Ruh eşimi ne zaman bulacağım?',
      'İlişkimde ne yapmalıyım?',
    ],
    'Kariyer': [
      'Kariyer değişikliği yapmalı mıyım?',
      'Terfi alabilir miyim bu dönem?',
      'İş kurmam için doğru zaman mı?',
      'Hangi sektör bana uygun?',
    ],
    'Finans': [
      'Finansal durumum ne zaman düzelecek?',
      'Yatırım yapmalı mıyım?',
      'Para kazanma şansım bu ay nasıl?',
      'Tasarruf için ne önerirsin?',
    ],
    'Sağlık': [
      'Sağlığıma dikkat etmem gereken konular?',
      'Stresimi nasıl azaltabilirim?',
      'Enerji seviyem neden düşük?',
      'Hangi spor bana iyi gelir?',
    ],
    'İlişkiler': [
      'Arkadaşlıklarımda dikkat etmem gereken ne?',
      'Aile ilişkilerim nasıl olacak?',
      'Yeni insanlarla tanışmam için ne yapmalıyım?',
      'İlişkilerimde tekrar eden kalıplarım neler?',
    ],
    'Genel': [
      'Bugün iş değiştirmeli miyim?',
      'Bu hafta şansım nasıl?',
      'Hangi renkler bana iyi gelir?',
      'Hayatımda önemli bir değişiklik olacak mı?',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadTodayCount();
    _addWelcomeMessage();
    _adService.loadRewardedAd();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('chatbot_last_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastDate != today) {
      await prefs.setString('chatbot_last_date', today);
      await prefs.setInt('chatbot_free_count', 0);
      _freeQuestionsToday = 0;
    } else {
      _freeQuestionsToday = prefs.getInt('chatbot_free_count') ?? 0;
    }
    if (mounted) setState(() {});
  }

  Future<void> _incrementCount() async {
    final prefs = await SharedPreferences.getInstance();
    _freeQuestionsToday++;
    await prefs.setInt('chatbot_free_count', _freeQuestionsToday);
  }

  void _addWelcomeMessage() {
    final authProvider = context.read<AuthProvider>();
    final zodiacName = authProvider.selectedZodiac?.displayName ?? 'Gezgin';
    _messages.add(_ChatMessage(
      text: 'Merhaba $zodiacName! 🌟\n\nBen Astro Dozi, kozmik danışmanın. Aşk, kariyer, sağlık, ilişkiler... Hayatınla ilgili her şeyi sorabilirsin.\n\nBugün sana nasıl yardımcı olabilirim?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  bool get _canAskFree => _freeQuestionsToday < _maxFreeQuestions;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Premium kullanıcılar sınırsız
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isPremium && !_canAskFree) {
      _showLimitDialog();
      return;
    }

    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final zodiacName = authProvider.selectedZodiac?.displayName ?? 'Bilinmeyen';

      // Build conversation context from last 4 messages
      final recentMessages = _messages.where((m) => m != _messages.first).toList(); // skip welcome
      final contextMessages = recentMessages.length > 4
          ? recentMessages.sublist(recentMessages.length - 4)
          : recentMessages;

      final conversationContext = contextMessages.map((m) {
        return '${m.isUser ? "Kullanıcı" : "Zodi"}: ${m.text}';
      }).join('\n');

      final prompt = '''
Sen Zodi'sin - Astroloji dünyasının en dürüst, en "cool" ve bazen en huysuz rehberi.
Kullanıcının burcu: $zodiacName

${conversationContext.isNotEmpty ? 'ÖNCEKİ KONUŞMA:\n$conversationContext\n' : ''}

Kullanıcının yeni sorusu: "$text"

Kısa ve öz cevap ver (max 3 paragraf). Astrolojik açıdan yorum yap. Samimi, dürüst ve eğlenceli ol.
Önceki konuşma bağlamını dikkate al ve tutarlı ol.
Gerekirse burç özelliklerini kullanarak kişiselleştir.
Yanıtını düz metin olarak ver, JSON formatında değil.
''';

      final response = await _geminiService.generateTarotInterpretation(prompt);

      // JSON olarak parse etmeye çalış, düz metin olarak da kabul et
      String botResponse;
      try {
        final json = jsonDecode(response);
        botResponse = json['response'] ?? json['answer'] ?? json['text'] ?? response;
      } catch (_) {
        botResponse = response;
      }

      await _incrementCount();

      if (!_hasLoggedSession) {
        _hasLoggedSession = true;
        _activityLog.logChatbot();
      }

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: 'Ups! Kozmik bağlantıda bir sorun oluştu. Biraz sonra tekrar dene! 🌙',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E3F) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Günlük Soru Limitin Doldu! 🌙',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bugün $_maxFreeQuestions ücretsiz sorunun tamamını kullandın.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              // Reklam izle butonu
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(ctx);
                      final rewarded = await _adService.showRewardedAd(
                        placement: 'chatbot_extra',
                      );
                      if (rewarded) {
                        setState(() => _freeQuestionsToday -= 2); // 2 ekstra soru
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('2 ekstra soru hakkı kazandın! 🎉'),
                              backgroundColor: AppColors.positive,
                            ),
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Reklam İzle (+2 Soru)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'veya Premium\'a geç → sınırsız soru!',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppColors.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Kapat',
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppColors.textMuted,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin için gerekli
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final body = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)]
              : [const Color(0xFFE8D5F5), const Color(0xFFF0E6FF), const Color(0xFFE0D0F0)],
        ),
      ),
      child: Column(
        children: [
          // AppBar — embedded modda back button yok
          widget.embeddedMode
              ? _buildEmbeddedHeader(isDark)
              : _buildAppBar(isDark),
          // Mesajlar
          Expanded(child: _buildMessageList(isDark)),
          // Önerilen sorular
          if (_messages.length <= 3) _buildSuggestions(isDark),
          // Input
          _buildInputBar(isDark),
        ],
      ),
    );

    // Embedded modda Scaffold yok — MainShell zaten sağlıyor
    if (widget.embeddedMode) {
      return body;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: SafeArea(child: body),
    );
  }

  /// Embedded mod header — back button yok, daha kompakt
  Widget _buildEmbeddedHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.cosmicGradient,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Center(
              child: Text('🔮', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Astrolog',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                  ),
                ),
                Builder(
                  builder: (context) {
                    final isPremium = context.read<AuthProvider>().isPremium;
                    final subtitle = _isTyping
                        ? 'Yazıyor...'
                        : isPremium
                            ? 'Sınırsız soru hakkın var ✨'
                            : '$_freeQuestionsToday/$_maxFreeQuestions soru kullandın';
                    return Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: _isTyping
                            ? AppColors.positive
                            : (isDark ? Colors.white54 : Colors.grey.shade500),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.cosmicGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🔮', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Astro Dozi AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                Builder(
                  builder: (context) {
                    final isPremium = context.read<AuthProvider>().isPremium;
                    final subtitle = _isTyping
                        ? 'Yazıyor...'
                        : isPremium
                            ? 'Kozmik danışmanın (Sınırsız ✨)'
                            : 'Kozmik danışmanın ($_freeQuestionsToday/$_maxFreeQuestions)';
                    return Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isTyping
                            ? AppColors.positive
                            : (isDark ? Colors.white54 : AppColors.textMuted),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator(isDark);
        }
        return _buildMessageBubble(_messages[index], isDark);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, bool isDark) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.accentPurple
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: message.isUser
                ? Colors.white
                : (isDark ? Colors.white : AppColors.textDark),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: message.isUser ? 0.1 : -0.1,
          end: 0,
          duration: 300.ms,
        );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: -6,
                  delay: Duration(milliseconds: i * 200),
                  duration: 600.ms,
                );
          }),
        ),
      ),
    );
  }

  Widget _buildSuggestions(bool isDark) {
    final questions = _categoryQuestions[_selectedCategory] ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kategori chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categoryQuestions.keys.length,
            itemBuilder: (context, index) {
              final category = _categoryQuestions.keys.elementAt(index);
              final emoji = _categoryEmojis[category] ?? '';
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedCategory = category),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentPurple
                          : AppColors.accentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentPurple
                            : AppColors.accentPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '$emoji $category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.accentPurple,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Kategori sorular
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => _sendMessage(questions[index]),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      questions[index],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.accentPurple,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.accentPurple.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: _canAskFree
                      ? 'Sorunuzu yazın...'
                      : 'Günlük limit doldu',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: _sendMessage,
                enabled: !_isTyping,
                maxLines: 3,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.cosmicGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _isTyping ? null : () => _sendMessage(_controller.text),
              icon: const Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
