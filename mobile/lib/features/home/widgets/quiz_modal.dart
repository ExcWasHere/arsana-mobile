import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/materi_models.dart';

const _kInk = Color(0xFF0F172A);
const _kSubtle = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);
const _kTeal = Color(0xFF0E7490);
const _kTealAction = Color(0xFF0891B2);
const _kTealTrack = Color(0xFFE0F7FA);
const _kGreenBg = Color(0xFFECFDF3);
const _kGreenText = Color(0xFF15803D);
const _kRedBg = Color(0xFFFEF2F2);
const _kRedText = Color(0xFFB91C1C);

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
      return 'Luar biasa, semua jawabanmu tepat. Konsepnya udah kepegang dengan baik.';
    } else if (pct >= 70) {
      return 'Bagus, sebagian besar jawabanmu udah benar. Sedikit lagi lebih teliti aja.';
    }
    return 'Belum semua tepat, gak apa-apa. Coba tonton ulang videonya lalu ulangi kuis ini.';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildSurface(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _showResult ? _buildResult() : _buildQuestion(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSurface({required Widget child}) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: const Color(0xFFF7FEFF))),
        Positioned.fill(
          child: Opacity(
            opacity: 0.10,
            child: SvgPicture.asset(
              'assets/images/latar-belakang.svg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.materiTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _kTealAction,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                _showResult
                    ? 'Hasil Kuis'
                    : 'Soal ${_current + 1} dari ${widget.questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kInk,
                ),
              ),
              if (!_showResult) ...[
                const SizedBox(height: 10),
                _buildProgressDots(),
              ],
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 16, color: _kSubtle),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDots() {
    return Row(
      children: List.generate(widget.questions.length, (i) {
        final done = i <= _current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: i == widget.questions.length - 1 ? 0 : 4,
            ),
            decoration: BoxDecoration(
              color: done ? _kTealAction : _kTealTrack,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuestion() {
    final q = widget.questions[_current];
    const labels = ['A', 'B', 'C', 'D'];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
          ),
          child: Text(
            q.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _kInk,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(q.options.length, (idx) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildOption(q, idx, labels[idx]),
          );
        }),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selected != null ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kTealAction,
              disabledBackgroundColor: const Color(0xFFF1F5F9),
              disabledForegroundColor: const Color(0xFFCBD5E1),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _current + 1 == widget.questions.length
                  ? 'Lihat Hasil'
                  : 'Soal Berikutnya',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(QuizQuestion q, int idx, String label) {
    final isAnswered = _selected != null;
    final isCorrect = idx == q.answer;
    final isPicked = idx == _selected;

    Color border = _kBorder;
    Color bg = Colors.white;
    Color textColor = _kInk;
    Color circleBorder = _kBorder;
    Color circleText = _kSubtle;
    Widget? trailing;

    if (isAnswered) {
      if (isCorrect) {
        border = _kGreenText.withOpacity(0.4);
        bg = _kGreenBg;
        textColor = _kGreenText;
        circleBorder = _kGreenText;
        circleText = _kGreenText;
        trailing = const Icon(Icons.check_rounded, size: 18, color: _kGreenText);
      } else if (isPicked) {
        border = _kRedText.withOpacity(0.35);
        bg = _kRedBg;
        textColor = _kRedText;
        circleBorder = _kRedText;
        circleText = _kRedText;
        trailing = const Icon(Icons.close_rounded, size: 18, color: _kRedText);
      } else {
        textColor = const Color(0xFFB5BEC9);
        circleText = const Color(0xFFCBD5E1);
        circleBorder = const Color(0xFFE9EDF1);
      }
    }

    return GestureDetector(
      onTap: () => _handleAnswer(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: circleBorder, width: 1.4),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: circleText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                q.options[idx],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final total = widget.questions.length;

    return Column(
      children: [
        Text(
          '$_correctCount/$total',
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: _kTeal,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'jawaban benar',
          style: TextStyle(fontSize: 12, color: _kSubtle),
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: _kBorder),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 40,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: _kTealAction,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _feedback,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: _kInk,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kTealAction,
                  side: const BorderSide(color: _kBorder),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Ulangi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTealAction,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}