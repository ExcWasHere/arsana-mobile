import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/widgets/app_background.dart';
import '../models/materi_models.dart';
import '../widgets/quiz_modal.dart';

class DetailMateriPage extends StatefulWidget {
  final List<MateriDetail> materiList;

  const DetailMateriPage({super.key, this.materiList = perkalianDetailList});

  @override
  State<DetailMateriPage> createState() => _DetailMateriPageState();
}

class _DetailMateriPageState extends State<DetailMateriPage> {
  late MateriDetail _active = widget.materiList.first;
  int? _expandedId = 1;
  bool _videoEnded = false;
  final Set<int> _watchedIds = {};
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _loadVideo(_active);
  }

  void _loadVideo(MateriDetail materi) {
    _controller?.dispose();
    final controller = VideoPlayerController.asset(materi.videoUrl);
    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      controller.addListener(_onVideoTick);
    });
  }

  void _onVideoTick() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final ended = c.value.position >= c.value.duration &&
        c.value.duration > Duration.zero;
    if (ended && !_videoEnded) {
      setState(() {
        _videoEnded = true;
        _watchedIds.add(_active.id);
      });
    }
  }

  void _selectMateri(MateriDetail materi) {
    setState(() {
      _active = materi;
      _expandedId = materi.id;
      _videoEnded = false;
    });
    _loadVideo(materi);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _watchedIds.length;
    final progress = completedCount / widget.materiList.length;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildVideoPlayer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleCard(),
                          if (_videoEnded) ...[
                            const SizedBox(height: 12),
                            _buildQuizButton(context),
                          ],
                          const SizedBox(height: 16),
                          _buildMateriListCard(completedCount, progress),
                          const SizedBox(height: 24),
                        ],
                      ),
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFcffafe)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF0891B2),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Matematika — Operasi Perkalian',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Kelas 5',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              border: Border.all(color: const Color(0xFFBFDBFE)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: Color(0xFF3B82F6),
                ),
                const SizedBox(width: 4),
                Text(
                  _active.duration,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final c = _controller;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          if (c != null && c.value.isInitialized)
            GestureDetector(
              onTap: () {
                setState(() {
                  c.value.isPlaying ? c.pause() : c.play();
                });
              },
              child: VideoPlayer(c),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
          if (c != null && c.value.isInitialized && !c.value.isPlaying && !_videoEnded)
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white70,
                size: 56,
              ),
            ),
          if (_videoEnded)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4ADE80),
                      size: 44,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Video Selesai! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Yuk uji pemahamanmu!',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => showQuizModal(
                        context,
                        materiTitle: _active.title,
                      ),
                      icon: const Icon(Icons.description_outlined, size: 16),
                      label: const Text('Mulai Kuis'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

  Widget _buildTitleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFcffafe)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _active.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.play_circle_outline_rounded,
                size: 13,
                color: Color(0xFF0891B2),
              ),
              const SizedBox(width: 4),
              const Text(
                'Video Pembelajaran  •  ',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const Icon(
                Icons.access_time_rounded,
                size: 12,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 3),
              Text(
                _active.duration,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._active.subtopics.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5, right: 8),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22D3EE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
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

  Widget _buildQuizButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () =>
            showQuizModal(context, materiTitle: _active.title),
        icon: const Icon(Icons.description_outlined, size: 16),
        label: const Text('Kerjakan Kuis Sekarang'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0891B2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMateriListCard(int completedCount, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFcffafe)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Materi',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              Text(
                '$completedCount/${widget.materiList.length} selesai',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF22C55E)),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.materiList.map((m) => _buildMateriItem(m)),
          const SizedBox(height: 4),
          _buildBadgeCta(),
        ],
      ),
    );
  }

  Widget _buildMateriItem(MateriDetail m) {
    final isActive = _active.id == m.id;
    final isWatched = _watchedIds.contains(m.id);
    final isExpanded = _expandedId == m.id;

    final Color border = isActive
        ? const Color(0xFF22D3EE)
        : isWatched
            ? const Color(0xFFBBF7D0)
            : const Color(0xFFE5E7EB);
    final Color bg = isActive
        ? const Color(0xFFECFEFF)
        : isWatched
            ? const Color(0xFFF0FDF4)
            : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _expandedId = isExpanded ? null : m.id;
              });
              _selectMateri(m);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isWatched
                          ? const Color(0xFF22C55E)
                          : isActive
                              ? const Color(0xFF06B6D4)
                              : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isWatched
                          ? Icons.check_circle_rounded
                          : Icons.play_arrow_rounded,
                      size: isWatched ? 16 : 14,
                      color: isWatched || isActive
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isActive
                                ? const Color(0xFF0E7490)
                                : isWatched
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 10,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              m.duration,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...m.subtopics.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 7),
                            decoration: const BoxDecoration(
                              color: Color(0xFF22D3EE),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _selectMateri(m),
                      icon: const Icon(Icons.play_arrow_rounded, size: 14),
                      label: const Text('Tonton Video'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadgeCta() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
        ),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFACC15), Color(0xFFF97316)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lanjutkan belajar!',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                Text(
                  'Selesaikan semua untuk dapat lencana',
                  style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}