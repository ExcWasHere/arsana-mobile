import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';

enum _ForumFilter { semua, guru, diskusiku }

class ForumKelasPage extends StatefulWidget {
  const ForumKelasPage({super.key});

  @override
  State<ForumKelasPage> createState() => _ForumKelasPageState();
}

class _ForumKelasPageState extends State<ForumKelasPage> {
  _ForumFilter _filter = _ForumFilter.semua;

  static const List<_ThreadData> _threads = [
    _ThreadData(
      authorName: 'Bu Rina',
      authorRole: _AuthorRole.guru,
      subject: 'Matematika',
      title: 'Kuis penjumlahan minggu ini sudah dibuka!',
      snippet:
          'Anak-anak, kuis penjumlahan 1-10 sudah bisa dikerjakan mulai hari ini sampai Jumat ya.',
      replyCount: 12,
      timeAgo: '10 menit lalu',
      pinned: true,
    ),
    _ThreadData(
      authorName: 'Dimas',
      authorRole: _AuthorRole.siswa,
      subject: 'IPA',
      title: 'Ada yang paham materi rantai makanan?',
      snippet:
          'Aku masih bingung bedain produsen sama konsumen tingkat 2, ada yang bisa bantu jelasin?',
      replyCount: 5,
      timeAgo: '32 menit lalu',
      pinned: false,
    ),
    _ThreadData(
      authorName: 'Bu Rina',
      authorRole: _AuthorRole.guru,
      subject: 'Bahasa Indonesia',
      title: 'Tips membaca pemahaman biar lebih cepat',
      snippet:
          'Coba baca judul dan paragraf pertama dulu sebelum masuk ke soal, biar tahu gambaran isinya.',
      replyCount: 8,
      timeAgo: '2 jam lalu',
      pinned: false,
    ),
    _ThreadData(
      authorName: 'Salsa',
      authorRole: _AuthorRole.siswa,
      subject: 'Matematika',
      title: 'Cara cepat hitung penjumlahan bersusun',
      snippet: 'Ini aku share trik dari kakak aku, lumayan ngebantu banget!',
      replyCount: 3,
      timeAgo: '5 jam lalu',
      pinned: false,
    ),
  ];

  List<_ThreadData> get _filteredThreads {
    switch (_filter) {
      case _ForumFilter.guru:
        return _threads.where((t) => t.authorRole == _AuthorRole.guru).toList();
      case _ForumFilter.diskusiku:
        return const [];
      case _ForumFilter.semua:
        return _threads;
    }
  }

  void _openThread(_ThreadData thread) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThreadDetailSheet(thread: thread),
    );
  }

  void _openNewThreadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewThreadSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final threads = _filteredThreads;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: _openNewThreadSheet,
          backgroundColor: const Color(0xFF8B5CF6),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              const SizedBox(height: 4),
              Expanded(
                child: threads.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: threads.length,
                        itemBuilder: (context, i) =>
                            _buildThreadCard(threads[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Text(
            'Forum Kelas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final labels = {
      _ForumFilter.semua: 'Semua',
      _ForumFilter.guru: 'Dari Guru',
      _ForumFilter.diskusiku: 'Diskusiku',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: labels.entries.map((entry) {
          final active = _filter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        )
                      : null,
                  color: active ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? Colors.transparent
                        : const Color(0xFFE9D5FF),
                  ),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🗂️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Belum ada diskusi yang kamu mulai',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadCard(_ThreadData thread) {
    final isGuru = thread.authorRole == _AuthorRole.guru;

    return GestureDetector(
      onTap: () => _openThread(thread),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: thread.pinned
                ? const Color(0xFFDDD6FE)
                : const Color(0xFFF1F5F9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isGuru
                          ? [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]
                          : [const Color(0xFF06B6D4), const Color(0xFF14B8A6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      thread.authorName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            thread.authorName,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (isGuru) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'GURU',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF7C3AED),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        thread.timeAgo,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (thread.pinned)
                  const Icon(Icons.push_pin_rounded,
                      size: 15, color: Color(0xFF8B5CF6)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                thread.subject,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              thread.title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              thread.snippet,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.forum_rounded,
                    size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  '${thread.replyCount} balasan',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadDetailSheet extends StatelessWidget {
  final _ThreadData thread;

  const _ThreadDetailSheet({required this.thread});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  children: [
                    Text(
                      thread.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${thread.authorName} · ${thread.timeAgo}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      thread.snippet,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF334155),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${thread.replyCount} Balasan',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Text(
                        'Balasan diskusi akan tampil di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tulis balasan...',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                      ),
                      Icon(Icons.send_rounded,
                          color: Colors.grey.shade300, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NewThreadSheet extends StatelessWidget {
  const _NewThreadSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mulai Diskusi Baru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Judul diskusi',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis pertanyaan atau ceritamu...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Kirim Diskusi',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AuthorRole { guru, siswa }

class _ThreadData {
  final String authorName;
  final _AuthorRole authorRole;
  final String subject;
  final String title;
  final String snippet;
  final int replyCount;
  final String timeAgo;
  final bool pinned;

  const _ThreadData({
    required this.authorName,
    required this.authorRole,
    required this.subject,
    required this.title,
    required this.snippet,
    required this.replyCount,
    required this.timeAgo,
    required this.pinned,
  });
}