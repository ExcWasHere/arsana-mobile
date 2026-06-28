import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';

class BerandaPage extends StatefulWidget {
  final VoidCallback onLogout;

  const BerandaPage({super.key, required this.onLogout});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  String _userName = 'Arsana';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final meta = user.userMetadata;
    final name = (meta?['full_name'] as String?)?.trim() ??
        (meta?['name'] as String?)?.trim() ??
        user.email?.split('@').first ??
        'Arsana';

    if (mounted && name.isNotEmpty) {
      setState(() => _userName = name);
    }
  }

  static const _features = [
    _FeatureData(
      emoji: '📚',
      title: 'Layar Ilmu',
      subtitle: 'Materi belajar & video pembelajaran',
      colors: [Color(0xFF06B6D4), Color(0xFF14B8A6)],
      tags: ['Video', 'Interaktif'],
    ),
    _FeatureData(
      emoji: '🎮',
      title: 'Arena Pintar',
      subtitle: 'Kuis & latihan soal seru',
      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      tags: ['Kuis', 'Tantangan'],
    ),
    _FeatureData(
      emoji: '✋',
      title: 'Gesture Match',
      subtitle: 'Praktik gerakan isyarat & validasi kamera AI',
      colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
      tags: ['4 level', 'AI'],
    ),
    _FeatureData(
      emoji: '🤟',
      title: 'Sign Translate',
      subtitle: 'Teks ke animasi isyarat SIBI instan & real-time',
      colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
      tags: ['SIBI', 'Real-time'],
    ),
  ];

  static const _recentLessons = [
    _LessonData(
      subject: 'Matematika',
      topic: 'Penjumlahan 1-10',
      done: true,
    ),
    _LessonData(
      subject: 'IPA',
      topic: 'Ekosistem Hutan',
      done: true,
    ),
    _LessonData(
      subject: 'Bahasa Indonesia',
      topic: 'Membaca Pemahaman',
      done: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStreakCard(),
                const SizedBox(height: 20),
                _buildSectionLabel('Fitur Utama'),
                const SizedBox(height: 12),
                _buildFeatureGrid(),
                const SizedBox(height: 20),
                _buildSectionLabel('Pelajaran Terakhir'),
                const SizedBox(height: 12),
                _buildRecentLessons(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.mist,
      elevation: 0,
      pinned: false,
      floating: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty
                        ? _userName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Halo, $_userName! 👋',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Text(
                      'Semangat belajar hari ini!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout_rounded, size: 20),
                color: Colors.red.shade400,
                tooltip: 'Keluar',
              ),
            ],
          ),
        ),
      ),
      expandedHeight: 78,
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7 Hari Streak!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pertahankan semangat belajarmu!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Kelas 5',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.92,
      children: _features.map(_buildFeatureCard).toList(),
    );
  }

  Widget _buildFeatureCard(_FeatureData f) {
    return GestureDetector(
      onTap: () {
        // TODO: navigasi ke halaman fitur
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFcffafe)), // cyan-100
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: f.colors),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            Text(f.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(
              f.title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                f.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: f.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: f.colors.first.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: f.colors.first,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLessons() {
    return Column(
      children: _recentLessons.map((lesson) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFcffafe)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: lesson.done
                        ? [const Color(0xFF34D399), const Color(0xFF059669)]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  lesson.done
                      ? Icons.check_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.topic,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                lesson.done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: lesson.done
                    ? const Color(0xFF34D399)
                    : Colors.grey.shade300,
                size: 18,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureData {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final List<String> tags;

  const _FeatureData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.tags,
  });
}

class _LessonData {
  final String subject;
  final String topic;
  final bool done;

  const _LessonData({
    required this.subject,
    required this.topic,
    required this.done,
  });
}