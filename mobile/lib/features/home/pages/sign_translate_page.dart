import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';

class SignTranslatePage extends StatefulWidget {
  const SignTranslatePage({super.key});

  @override
  State<SignTranslatePage> createState() => _SignTranslatePageState();
}

class _SignTranslatePageState extends State<SignTranslatePage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _words = [];
  int _activeIndex = -1;

  static const Map<String, String> _signEmoji = {
    'halo': '👋',
    'terima': '🙏',
    'kasih': '💗',
    'selamat': '🌞',
    'pagi': '🌅',
    'siang': '☀️',
    'malam': '🌙',
    'nama': '🪪',
    'saya': '🙋',
    'kamu': '👉',
    'belajar': '📖',
    'sekolah': '🏫',
    'teman': '🧑‍🤝‍🧑',
    'senang': '😊',
    'ibu': '👩',
    'bapak': '👨',
  };

  String _emojiFor(String word) {
    final key = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return _signEmoji[key] ?? '🤟';
  }

  void _translate(String text) {
    final trimmed = text.trim();
    setState(() {
      _words = trimmed.isEmpty ? [] : trimmed.split(RegExp(r'\s+'));
      _activeIndex = -1;
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _words = [];
      _activeIndex = -1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Sign Translate',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLanguageBar(),
                const SizedBox(height: 2),
                _buildTranslatorCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Bahasa Indonesia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: const Color(0xFFE2E8F0),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 15,
              color: Color(0xFF7C3AED),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: const Color(0xFFE2E8F0),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Isyarat SIBI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslatorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: const Border(
          left: BorderSide(color: Color(0xFFE2E8F0)),
          right: BorderSide(color: Color(0xFFE2E8F0)),
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _translate,
                    maxLines: null,
                    minLines: 2,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF0F172A),
                      height: 1.4,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Ketik teks di sini',
                      hintStyle: TextStyle(
                        fontSize: 17,
                        color: Color(0xFFB0B8C4),
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clear,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: _words.isEmpty ? _buildEmptyResult() : _buildResult(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResult() {
    return Row(
      children: [
        Icon(Icons.front_hand_outlined, color: Colors.grey.shade300, size: 22),
        const SizedBox(width: 10),
        Text(
          'Peraga isyarat akan muncul di sini',
          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_words.length, (i) {
            final word = _words[i];
            final active = i == _activeIndex;

            return GestureDetector(
              onTap: () => setState(
                () => _activeIndex = active ? -1 : i,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      active ? const Color(0xFFF5F3FF) : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active
                        ? const Color(0xFFA855F7)
                        : const Color(0xFFEDEDED),
                    width: active ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_emojiFor(word), style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      word,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (_activeIndex >= 0) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  _emojiFor(_words[_activeIndex]),
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  _words[_activeIndex],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            _buildIconAction(Icons.volume_up_rounded, 'Peragakan'),
            const SizedBox(width: 18),
            _buildIconAction(Icons.bookmark_border_rounded, 'Simpan'),
            const Spacer(),
            Text(
              '${_words.length} kata',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconAction(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: const Color(0xFF7C3AED)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7C3AED),
          ),
        ),
      ],
    );
  }
}