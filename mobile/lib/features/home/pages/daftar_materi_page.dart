import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';
import 'detail_materi_page.dart';
import '../models/materi_models.dart';

class DaftarMateriPage extends StatelessWidget {
  final SubjectData subject;

  const DaftarMateriPage({super.key, required this.subject});
  List<MateriListItem> get _materiList => matematikaMateriList;

  @override
  Widget build(BuildContext context) {
    final completedCount = _materiList.where((m) => m.completed).length;
    final progress = completedCount / _materiList.length;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: const Color(0xFF0891B2),
                  ),
                  const Text(
                    'Kembali',
                    style: TextStyle(
                      color: Color(0xFF0891B2),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildHeaderCard(completedCount, progress),
              const SizedBox(height: 16),
              _buildMateriListCard(context),
              const SizedBox(height: 16),
              _buildTipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(int completedCount, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFcffafe)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: subject.colors),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(subject.emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Kelas 5 SD • Kurikulum Merdeka',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress Belajar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '$completedCount/${_materiList.length} Materi',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFF9333EA),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).round()}% Selesai',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriListCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFcffafe)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Materi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_materiList.length, (idx) {
            final materi = _materiList[idx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MateriTile(
                materi: materi,
                index: idx,
                onTap: materi.locked
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DetailMateriPage(),
                          ),
                        );
                      },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAF5FF), Color(0xFFFDF2F8)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Tips Belajar',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF581C87),
            ),
          ),
          const SizedBox(height: 10),
          ..._tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•  ',
                    style: TextStyle(
                      color: Color(0xFF9333EA),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B21A8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _tips = [
    'Tonton video dengan saksama dan catat hal-hal penting',
    'Kerjakan latihan soal untuk mengasah kemampuan',
    'Selesaikan semua materi secara berurutan untuk hasil terbaik',
  ];
}

class _MateriTile extends StatelessWidget {
  final MateriListItem materi;
  final int index;
  final VoidCallback? onTap;

  const _MateriTile({
    required this.materi,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;
    if (materi.locked) {
      borderColor = const Color(0xFFE5E7EB);
      bgColor = const Color(0xFFF9FAFB);
    } else if (materi.completed) {
      borderColor = const Color(0xFFBBF7D0);
      bgColor = const Color(0xFFF0FDF4);
    } else {
      borderColor = const Color(0xFFcffafe);
      bgColor = Colors.white;
    }

    return Opacity(
      opacity: materi.locked ? 0.6 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: materi.locked
                      ? null
                      : LinearGradient(
                          colors: materi.completed
                              ? [
                                  const Color(0xFF4ADE80),
                                  const Color(0xFF16A34A),
                                ]
                              : [
                                  const Color(0xFFC084FC),
                                  const Color(0xFF7C3AED),
                                ],
                        ),
                  color: materi.locked ? const Color(0xFFE5E7EB) : null,
                ),
                child: Center(
                  child: materi.locked
                      ? const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: Color(0xFF9CA3AF),
                        )
                      : materi.completed
                          ? const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            materi.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: materi.locked
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: materi.locked
                                ? const Color(0xFFF3F4F6)
                                : materi.type.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                materi.type.icon,
                                size: 12,
                                color: materi.locked
                                    ? const Color(0xFF9CA3AF)
                                    : materi.type.color,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                materi.type.label,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: materi.locked
                                      ? const Color(0xFF9CA3AF)
                                      : materi.type.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      materi.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: materi.locked
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: materi.locked
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          materi.duration,
                          style: TextStyle(
                            fontSize: 10,
                            color: materi.locked
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const Spacer(),
                        if (materi.locked)
                          const Text(
                            'Terkunci',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (materi.completed)
                          const Text(
                            'Selesai',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else
                          const Text(
                            'Mulai Belajar  ›',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}