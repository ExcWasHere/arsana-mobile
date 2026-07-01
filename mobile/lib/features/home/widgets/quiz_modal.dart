import 'package:flutter/material.dart';
import '../models/materi_models.dart';

Future<void> showQuizModal(
  BuildContext context, {
  required String materiTitle,
  List<QuizQuestion> questions = perkalianQuiz,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => QuizModal(materiTitle: materiTitle, questions: questions),
  );
}

class QuizModal extends StatefulWidget {
  final String materiTitle;
  final List<QuizQuestion> questions;

  const QuizModal({
    super.key,
    required this.materiTitle,
    this.questions = perkalianQuiz,
  });

  @override
  State<QuizModal> createState() => _QuizModalState();
}

class _QuizModalState extends State<QuizModal> {
  int _current = 0;
  int? _selected;
  final List<int?> _answers = [];
  bool _showResult = false;

  void _reset() {
    setState(() {
      _current = 0;
      _selected = null;
      _answers.clear();
      _showResult = false;
    });
  }

  void _handleAnswer(int idx) {
    if (_selected != null) return;
    setState(() => _selected = idx);
  }

  void _handleNext() {
    _answers.add(_selected);
    if (_current + 1 < widget.questions.length) {
      setState(() {
        _current += 1;
        _selected = null;
      });
    } else {
      setState(() => _showResult = true);
    }
  }

  int get _correctCount {
    var count = 0;
    for (var i = 0; i < _answers.length; i++) {
      if (_answers[i] == widget.questions[i].answer) count++;
    }
    return count;
  }

  String get _feedback {
    final pct = _correctCount / widget.questions.length * 100;
    if (pct == 100) {
      return 'Luar biasa! Kamu menguasai konsep ini dengan sangat baik!';
    } else if (pct >= 70) {
      return 'Bagus sekali! Kamu sudah memahami sebagian besar materi.';
    }
    return 'Tetap semangat! Coba ulangi lagi ya!';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            if (!_showResult)
              LinearProgressIndicator(
                value: _current / widget.questions.length,
                minHeight: 5,
                backgroundColor: const Color(0xFFCFFAFE),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF0891B2)),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _showResult ? _buildResult() : _buildQuestion(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0E7490)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuis — ${widget.materiTitle}',
                  style: const TextStyle(
                    color: Color(0xFFA5F3FC),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!_showResult) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Soal ${_current + 1} dari ${widget.questions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final q = widget.questions[_current];
    const labels = ['A', 'B', 'C', 'D'];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFECFEFF),
            border: Border.all(color: const Color(0xFFA5F3FC), width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            q.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF155E75),
            ),
          ),
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: List.generate(q.options.length, (idx) {
            Color border = const Color(0xFFE5E7EB);
            Color bg = Colors.white;
            Color text = const Color(0xFF374151);
            Color badgeBg = const Color(0xFFECFEFF);
            Color badgeText = const Color(0xFF0891B2);

            if (_selected != null) {
              if (idx == q.answer) {
                border = const Color(0xFF22C55E);
                bg = const Color(0xFFDCFCE7);
                text = const Color(0xFF166534);
                badgeBg = const Color(0xFF22C55E);
                badgeText = Colors.white;
              } else if (idx == _selected) {
                border = const Color(0xFFF87171);
                bg = const Color(0xFFFEE2E2);
                text = const Color(0xFFB91C1C);
                badgeBg = const Color(0xFFF87171);
                badgeText = Colors.white;
              } else {
                text = const Color(0xFF9CA3AF);
              }
            }

            return GestureDetector(
              onTap: () => _handleAnswer(idx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: border, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          labels[idx],
                          style: TextStyle(
                            color: badgeText,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        q.options[idx],
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selected != null ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0891B2),
              disabledBackgroundColor: const Color(0xFFF3F4F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _current + 1 == widget.questions.length
                  ? 'Lihat Hasil'
                  : 'Soal Berikutnya',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final total = widget.questions.length;
    final title = _correctCount >= (total * 0.8).ceil()
        ? 'Luar Biasa! 🎉'
        : _correctCount >= (total * 0.6).ceil()
            ? 'Bagus! 👍'
            : 'Terus Berlatih! 💪';

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFACC15), Color(0xFFF97316)],
            ),
          ),
          child: const Icon(Icons.star_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kamu menjawab dengan benar',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFECFEFF),
            border: Border.all(color: const Color(0xFFA5F3FC), width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                '$_correctCount/$total',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0E7490),
                ),
              ),
              const Text(
                'Jawaban benar',
                style: TextStyle(color: Color(0xFF0891B2), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            border: Border.all(color: const Color(0xFFBAE6FD)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🤖 FEEDBACK ARSI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E7490),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _feedback,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Ulangi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0891B2),
                  side: const BorderSide(color: Color(0xFF67E8F9), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Selesai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}