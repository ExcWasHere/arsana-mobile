import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';

class LencanaPage extends StatefulWidget {
  const LencanaPage({super.key});

  @override
  State<LencanaPage> createState() => _LencanaPageState();
}

class _LencanaPageState extends State<LencanaPage> {
  bool _showAchievedOnly = false;

  static const List<_ShelfData> _shelves = [
    _ShelfData(
      label: 'Langkah Awal',
      colors: [Color(0xFF22D3EE), Color(0xFF0891B2)],
      badges: [
        _BadgeData(
          emoji: '🤝',
          title: 'Salam Pertama',
          description: 'Menyelesaikan pelajaran pertamamu.',
          unlocked: true,
          earnedOn: '3 Jun 2026',
        ),
        _BadgeData(
          emoji: '👍',
          title: 'Jempol Jago',
          description: 'Menyelesaikan 5 pelajaran materi belajar.',
          unlocked: true,
          earnedOn: '10 Jun 2026',
        ),
        _BadgeData(
          emoji: '📖',
          title: 'Kamus Isyarat',
          description: 'Mempelajari 20 kosakata isyarat SIBI.',
          unlocked: false,
          progress: 12,
          target: 20,
        ),
      ],
    ),
    _ShelfData(
      label: 'Konsisten Belajar',
      colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
      badges: [
        _BadgeData(
          emoji: '🔥',
          title: 'Api Semangat',
          description: 'Belajar 7 hari berturut-turut.',
          unlocked: true,
          earnedOn: '15 Jun 2026',
        ),
        _BadgeData(
          emoji: '🛡️',
          title: 'Perisai Konsisten',
          description: 'Belajar 30 hari berturut-turut.',
          unlocked: false,
          progress: 7,
          target: 30,
        ),
        _BadgeData(
          emoji: '💎',
          title: 'Ilmu Berlian',
          description: 'Belajar 100 hari berturut-turut.',
          unlocked: false,
          progress: 7,
          target: 100,
        ),
      ],
    ),
    _ShelfData(
      label: 'Jagoan Bahasa Isyarat',
      colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
      badges: [
        _BadgeData(
          emoji: '✋',
          title: 'Master Gesture',
          description: 'Menyelesaikan semua level Gesture Match.',
          unlocked: false,
          progress: 2,
          target: 5,
        ),
        _BadgeData(
          emoji: '🤟',
          title: 'Penerjemah Andal',
          description: 'Menggunakan Sign Translate 50 kali.',
          unlocked: false,
          progress: 8,
          target: 50,
        ),
      ],
    ),
    _ShelfData(
      label: 'Si Paling Sosial',
      colors: [Color(0xFF4ADE80), Color(0xFF15803D)],
      badges: [
        _BadgeData(
          emoji: '💬',
          title: 'Suara Forum',
          description: 'Membuat diskusi pertama di Forum Kelas.',
          unlocked: true,
          earnedOn: '18 Jun 2026',
        ),
        _BadgeData(
          emoji: '🧑‍🤝‍🧑',
          title: 'Teman Diskusi',
          description: 'Membalas 10 diskusi di Forum Kelas.',
          unlocked: false,
          progress: 3,
          target: 10,
        ),
      ],
    ),
  ];

  int get _totalBadges =>
      _shelves.fold(0, (sum, shelf) => sum + shelf.badges.length);

  int get _unlockedBadges => _shelves.fold(
        0,
        (sum, shelf) => sum + shelf.badges.where((b) => b.unlocked).length,
      );

  List<_ShelfData> get _visibleShelves {
    if (!_showAchievedOnly) return _shelves;
    return _shelves
        .map((shelf) => _ShelfData(
              label: shelf.label,
              colors: shelf.colors,
              badges: shelf.badges.where((b) => b.unlocked).toList(),
            ))
        .where((shelf) => shelf.badges.isNotEmpty)
        .toList();
  }

  void _showBadgeSheet(_BadgeData badge, List<Color> colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BadgeSheet(badge: badge, colors: colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shelves = _visibleShelves;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                floating: true,
                automaticallyImplyLeading: false,
                title: const Text(
                  'Lencana',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeroMedallion(),
                    const SizedBox(height: 22),
                    _buildTabs(),
                    const SizedBox(height: 18),
                    if (shelves.isEmpty)
                      _buildEmptyState()
                    else
                      for (final shelf in shelves) ...[
                        _buildCabinet(shelf),
                        const SizedBox(height: 20),
                      ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroMedallion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: -0.5,
                child: Icon(Icons.eco_rounded,
                    color: Colors.amber.shade300.withOpacity(0.8), size: 26),
              ),
              const SizedBox(width: 6),
              _TrophyMedal(
                size: 96,
                colors: const [Color(0xFFFDE68A), Color(0xFFD97706)],
                unlocked: true,
                child: const Text('🏆', style: TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 6),
              Transform.flip(
                flipX: true,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Icon(Icons.eco_rounded,
                      color: Colors.amber.shade300.withOpacity(0.8), size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Text(
              '$_unlockedBadges dari $_totalBadges Lencana Diraih',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Etalase Piala Belajarmu',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _buildTabButton('Semua', !_showAchievedOnly),
        const SizedBox(width: 20),
        _buildTabButton('Diraih', _showAchievedOnly),
      ],
    );
  }

  Widget _buildTabButton(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _showAchievedOnly = label == 'Diraih'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2.5,
              color: active ? const Color(0xFF14B8A6) : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: active ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Text('🗄️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            'Belum ada piala yang kamu raih di sini',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCabinet(_ShelfData shelf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: shelf.colors),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                shelf.label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border(
                  top: BorderSide(color: shelf.colors[0], width: 3),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 20),
              child: Wrap(
                spacing: 14,
                runSpacing: 20,
                children: shelf.badges
                    .map((badge) => _BadgeSlot(
                          badge: badge,
                          colors: shelf.colors,
                          onTap: () => _showBadgeSheet(badge, shelf.colors),
                        ))
                    .toList(),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.1,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0),
                      ],
                    ),
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

class _BadgeSlot extends StatelessWidget {
  final _BadgeData badge;
  final List<Color> colors;
  final VoidCallback onTap;

  const _BadgeSlot({
    required this.badge,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            _TrophyMedal(
              size: 64,
              colors: colors,
              unlocked: badge.unlocked,
              child: Text(
                badge.emoji,
                style: TextStyle(
                  fontSize: 24,
                  color: badge.unlocked ? null : Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: badge.unlocked ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrophyMedal extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final bool unlocked;
  final Widget child;

  const _TrophyMedal({
    required this.size,
    required this.colors,
    required this.unlocked,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = size * 1.3;

    return SizedBox(
      width: size * 1.15,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(size * 1.15, totalHeight),
            painter: _MedalPainter(colors: colors, unlocked: unlocked),
          ),
          if (unlocked)
            Positioned(
              top: size * 0.10,
              left: size * 0.20,
              child: Container(
                width: size * 0.38,
                height: size * 0.22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.35),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(
            width: size,
            height: size,
            child: Center(child: child),
          ),
          if (!unlocked)
            Positioned(
              top: -2,
              right: size * 0.02,
              child: Container(
                padding: const EdgeInsets.all(3.5),
                decoration: const BoxDecoration(
                  color: Color(0xFF334155),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MedalPainter extends CustomPainter {
  final List<Color> colors;
  final bool unlocked;

  _MedalPainter({required this.colors, required this.unlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final circleDiameter = size.width;
    final radius = circleDiameter / 2;
    final center = Offset(radius, radius * 0.92);

    final ribbonColor =
        unlocked ? colors.last : Colors.grey.shade500.withOpacity(0.6);
    final ribbonWidth = circleDiameter * 0.24;
    final ribbonTop = center.dy + radius * 0.55;
    final ribbonBottom = size.height;

    Path buildRibbon(bool onLeft) {
      final dir = onLeft ? -1.0 : 1.0;
      return Path()
        ..moveTo(center.dx + dir * ribbonWidth * 0.15, ribbonTop)
        ..lineTo(center.dx + dir * ribbonWidth * 1.15, ribbonTop)
        ..lineTo(center.dx + dir * ribbonWidth * 0.85, ribbonBottom)
        ..lineTo(center.dx + dir * ribbonWidth * 0.05, ribbonBottom - 7)
        ..close();
    }

    final ribbonPaint = Paint()..color = ribbonColor;
    canvas.drawPath(buildRibbon(true), ribbonPaint);
    canvas.drawPath(buildRibbon(false), ribbonPaint);

    const scallops = 14;
    final outerR = radius;
    final innerR = radius * 0.90;
    final seal = Path();
    for (int i = 0; i < scallops * 2; i++) {
      final angle = (math.pi * 2 / (scallops * 2)) * i - math.pi / 2;
      final r = i.isEven ? outerR : innerR;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        seal.moveTo(point.dx, point.dy);
      } else {
        seal.lineTo(point.dx, point.dy);
      }
    }
    seal.close();

    final rect = Rect.fromCircle(center: center, radius: outerR);
    final fillPaint = Paint()
      ..shader = (unlocked
              ? LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                ))
          .createShader(rect);
    canvas.drawPath(seal, fillPaint);

    canvas.drawPath(
      seal,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withOpacity(unlocked ? 0.7 : 0.35),
    );

    canvas.drawCircle(
      center,
      innerR * 0.76,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withOpacity(unlocked ? 0.35 : 0.2),
    );
  }

  @override
  bool shouldRepaint(covariant _MedalPainter oldDelegate) =>
      oldDelegate.unlocked != unlocked || oldDelegate.colors != colors;
}

class _BadgeSheet extends StatelessWidget {
  final _BadgeData badge;
  final List<Color> colors;

  const _BadgeSheet({required this.badge, required this.colors});

  @override
  Widget build(BuildContext context) {
    final progressFraction =
        badge.target != null ? (badge.progress ?? 0) / badge.target! : null;

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
          _TrophyMedal(
            size: 84,
            colors: colors,
            unlocked: badge.unlocked,
            child: Text(badge.emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          if (badge.unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFCFFAFE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Diperoleh ${badge.earnedOn}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0891B2),
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressFraction,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation(colors[1]),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${badge.progress}/${badge.target} tercapai',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShelfData {
  final String label;
  final List<Color> colors;
  final List<_BadgeData> badges;

  const _ShelfData({
    required this.label,
    required this.colors,
    required this.badges,
  });
}

class _BadgeData {
  final String emoji;
  final String title;
  final String description;
  final bool unlocked;
  final String? earnedOn;
  final int? progress;
  final int? target;

  const _BadgeData({
    required this.emoji,
    required this.title,
    required this.description,
    required this.unlocked,
    this.earnedOn,
    this.progress,
    this.target,
  });
}