// lib/screens/ai_screen.dart
import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/ai_service.dart';
import '../theme/app_colors.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dest = ModalRoute.of(context)!.settings.arguments as DestinationModel;
      _sendMessage(
        'Create a 3-day itinerary for ${dest.name}, ${dest.country}. Include top attractions, best local food spots, and practical travel tips.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final dest = ModalRoute.of(context)!.settings.arguments as DestinationModel;

    setState(() {
      _messages.add({'role': 'user', 'text': text.trim()});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await AiService().askAI(dest, text.trim());

    setState(() {
      _messages.add({'role': 'ai', 'text': response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  static const _quickPrompts = [
    '🍽 Best local foods',
    '🏨 Hotel recommendations',
    '💰 Budget tips',
    '🚌 Getting around',
    '📸 Best photo spots',
    '🌤 Best time to visit',
  ];

  @override
  Widget build(BuildContext context) {
    final dest = ModalRoute.of(context)!.settings.arguments as DestinationModel;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Travel Assistant', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 17)),
            Text(dest.name, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'New conversation',
            onPressed: () {
              setState(() {
                _messages.clear();
                _isLoading = false;
              });
              _sendMessage('Create a 3-day itinerary for ${dest.name}, ${dest.country}. Include top attractions, best local food spots, and practical travel tips.');
            },
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: _messages.isEmpty && !_isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == _messages.length) {
                      return const _TypingIndicator();
                    }
                    final msg = _messages[i];
                    final isAi = msg['role'] == 'ai';
                    return _MessageBubble(text: msg['text']!, isAi: isAi, destName: dest.name);
                  },
                ),
        ),
        if (!_isLoading && _messages.length > 1)
          SizedBox(
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickPrompts.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                child: ActionChip(
                  label: Text(_quickPrompts[i], style: const TextStyle(fontSize: 12, fontFamily: 'Nunito', color: AppColors.primary)),
                  backgroundColor: AppColors.cardTint,
                  side: BorderSide.none,
                  onPressed: () => _sendMessage(_quickPrompts[i]),
                ),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          padding: EdgeInsets.only(left: 16, right: 12, top: 10, bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isLoading,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: AppColors.charcoal),
                decoration: InputDecoration(
                  hintText: 'Ask anything about ${dest.name}…',
                  hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14, fontFamily: 'Nunito'),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
                onSubmitted: _isLoading ? null : _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: _isLoading ? AppColors.gray : AppColors.primary, shape: BoxShape.circle),
              child: IconButton(
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isAi;
  final String destName;

  const _MessageBubble({required this.text, required this.isAi, required this.destName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) ...[
            Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isAi ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(isAi ? 4 : 18), topRight: Radius.circular(isAi ? 18 : 4), bottomLeft: const Radius.circular(18), bottomRight: const Radius.circular(18)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Text(text, style: TextStyle(fontSize: 14, height: 1.55, fontFamily: 'Nunito', color: isAi ? AppColors.charcoal : Colors.white)),
            ),
          ),
          if (!isAi) ...[
            const SizedBox(width: 8),
            const CircleAvatar(radius: 16, backgroundColor: AppColors.cardTint, child: Icon(Icons.person_outline, color: AppColors.primaryDark, size: 16)),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))]),
          child: FadeTransition(
            opacity: _anim,
            child: Row(children: List.generate(3, (i) => Padding(padding: EdgeInsets.only(left: i > 0 ? 4 : 0), child: const CircleAvatar(radius: 4, backgroundColor: AppColors.gray)))),
          ),
        ),
      ]),
    );
  }
}
