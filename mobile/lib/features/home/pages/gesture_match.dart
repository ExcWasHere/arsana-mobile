import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';

class GestureMatchPage extends StatefulWidget {
  const GestureMatchPage({super.key});

  @override
  State<GestureMatchPage> createState() => _GestureMatchPageState();
}

class _GestureMatchPageState extends State<GestureMatchPage> {
  static const List<_LevelData> _levels = [
    _LevelData(
      number: 1,
      emoji: '👋',
      title: 'Salam & Sapaan',
      difficulty: 'Pemula',
      status: _LevelStatus.completed,
      stars: 3,
    ),
    _LevelData(
      number: 2,
      emoji: '🔢',
      title: 'Angka & Waktu',
      difficulty: 'Pemula',
      status: _LevelStatus.completed,
      stars: 2,
    ),
    _LevelData(
      number: 3,
      emoji: '👨‍👩‍👧',
      title: 'Keluarga',
      difficulty: 'Menengah',
      status: _LevelStatus.current,
      stars: 0,
    ),
    _LevelData(
      number: 4,
      emoji: '🏃',
      title: 'Aktivitas Harian',
      difficulty: 'Menengah',
      status: _LevelStatus.locked,
      stars: 0,
    ),
    _LevelData(
      number: 5,
      emoji: '👑',
      title: 'Cerita Bebas',
      difficulty: 'Mahir',
      status: _LevelStatus.locked,
      stars: 0,
    ),
  ];

  static const List<double> _xFractions = [0.5, 0.78, 0.28, 0.72, 0.5];
  static const double _nodeSize = 78;
  static const double _rowHeight = 148;

  void _handleTap(_LevelData level) {
    if (level.status == _LevelStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF334155),
          content: Row(
            children: const [
              Text('🔒 ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  'Selesaikan level sebelumnya dulu, ya!',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    _showLevelSheet(level);
  }

  void _showLevelSheet(_LevelData level) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LevelSheet(level: level),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount =
        _levels.where((l) => l.status == _LevelStatus.completed).length;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Gesture Match',
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
                _buildProgressCard(completedCount),
                const SizedBox(height: 28),
                _buildPath(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(int completedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('✋', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completedCount dari ${_levels.length} level selesai',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completedCount / _levels.length,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPath() {
    final totalHeight = _rowHeight * _levels.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final centers = List.generate(_levels.length, (i) {
          final x = _xFractions[i] * width;
          final y = _rowHeight * i + _rowHeight / 2;
          return Offset(x, y);
        });

        return SizedBox(
          height: totalHeight,
          width: width,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DashedPathPainter(centers),
                ),
              ),
              for (int i = 0; i < _levels.length; i++)
                Positioned(
                  left: centers[i].dx - _nodeSize / 2,
                  top: centers[i].dy - _nodeSize / 2,
                  child: _LevelNode(
                    level: _levels[i],
                    size: _nodeSize,
                    onTap: () => _handleTap(_levels[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

enum _LevelStatus { locked, current, completed }

class _LevelData {
  final int number;
  final String emoji;
  final String title;
  final String difficulty;
  final _LevelStatus status;
  final int stars;

  const _LevelData({
    required this.number,
    required this.emoji,
    required this.title,
    required this.difficulty,
    required this.status,
    required this.stars,
  });
}

class _LevelNode extends StatelessWidget {
  final _LevelData level;
  final double size;
  final VoidCallback onTap;

  const _LevelNode({
    required this.level,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = level.status == _LevelStatus.locked;
    final isCurrent = level.status == _LevelStatus.current;

    final gradient = isLocked
        ? [Colors.grey.shade300, Colors.grey.shade400]
        : level.status == _LevelStatus.completed
            ? [const Color(0xFF34D399), const Color(0xFF059669)]
            : [const Color(0xFF06B6D4), const Color(0xFF14B8A6)];

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: Colors.white, width: 4)
                  : Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: gradient[1].withOpacity(isLocked ? 0.15 : 0.4),
                  blurRadius: isCurrent ? 18 : 10,
                  spreadRadius: isCurrent ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 26)
                  : level.status == _LevelStatus.completed
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 30)
                      : Text(
                          '${level.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'MAIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final filled = i < level.stars;
              return Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 13,
                color: filled
                    ? const Color(0xFFFBBF24)
                    : Colors.grey.shade300,
              );
            }),
          ),
      ],
    );
  }
}

class _DashedPathPainter extends CustomPainter {
  final List<Offset> points;

  _DashedPathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF99F6E4)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      _drawDashedLine(canvas, points[i], points[i + 1], paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 9.0;
    const dashSpace = 7.0;
    final total = (p2 - p1).distance;
    if (total == 0) return;
    final dir = (p2 - p1) / total;
    double distance = 0;
    while (distance < total) {
      final start = p1 + dir * distance;
      final end = p1 + dir * math.min(distance + dashWidth, total);
      canvas.drawLine(start, end, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPathPainter oldDelegate) => false;
}

class _LevelSheet extends StatelessWidget {
  final _LevelData level;

  const _LevelSheet({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(level.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            'Level ${level.number}: ${level.title}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFCFFAFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              level.difficulty,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0891B2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Mulai Latihan',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}