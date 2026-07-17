import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback? onDownload;
  final bool isDownloading;
  final double playbackSpeed;
  final ValueChanged<double> onSpeedChanged;
  final GlobalKey? downloadButtonKey;

  const VideoControlsOverlay({
    super.key,
    required this.controller,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.playbackSpeed,
    required this.onSpeedChanged,
    this.onDownload,
    this.isDownloading = false,
    this.downloadButtonKey,
  });

  @override
  State<VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  bool _visible = true;
  Timer? _hideTimer;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _resetHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _visible = false);
      }
    });
  }

  void _toggleVisible() {
    setState(() => _visible = !_visible);
    if (_visible) _resetHideTimer();
  }

  void _seekRelative(Duration offset) {
    final c = widget.controller;
    final newPos = c.value.position + offset;
    final clamped = newPos < Duration.zero
        ? Duration.zero
        : (newPos > c.value.duration ? c.value.duration : newPos);
    c.seekTo(clamped);
    _resetHideTimer();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _showSpeedMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Kecepatan Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              ..._speeds.map((s) {
                final isSelected = s == widget.playbackSpeed;
                return ListTile(
                  onTap: () {
                    widget.controller.setPlaybackSpeed(s);
                    widget.onSpeedChanged(s);
                    Navigator.pop(context);
                  },
                  title: Text(
                    s == 1.0 ? 'Normal' : '${s}x',
                    style: TextStyle(
                      color:
                          isSelected ? const Color(0xFF22D3EE) : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Color(0xFF22D3EE))
                      : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return GestureDetector(
      onTap: _toggleVisible,
      behavior: HitTestBehavior.opaque,
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: c,
        builder: (context, value, _) {
          return AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_visible,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                    stops: const [0, 0.25, 0.6, 1],
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: [
                          const Spacer(),
                          if (widget.onDownload != null)
                            IconButton(
                              key: widget.downloadButtonKey,
                              onPressed: widget.isDownloading
                                  ? null
                                  : () {
                                      widget.onDownload!();
                                      _resetHideTimer();
                                    },
                              icon: widget.isDownloading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.download_rounded,
                                      color: Colors.white,
                                    ),
                            ),
                          TextButton(
                            onPressed: () {
                              _showSpeedMenu();
                              _resetHideTimer();
                            },
                            child: Text(
                              widget.playbackSpeed == 1.0
                                  ? '1x'
                                  : '${widget.playbackSpeed}x',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 34,
                          onPressed: () =>
                              _seekRelative(const Duration(seconds: -10)),
                          icon: const Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          iconSize: 52,
                          onPressed: () {
                            value.isPlaying ? c.pause() : c.play();
                            _resetHideTimer();
                          },
                          icon: Icon(
                            value.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          iconSize: 34,
                          onPressed: () =>
                              _seekRelative(const Duration(seconds: 10)),
                          icon: const Icon(
                            Icons.forward_10_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 14,
                                ),
                                activeTrackColor: const Color(0xFF22D3EE),
                                inactiveTrackColor: Colors.white24,
                                thumbColor: const Color(0xFF22D3EE),
                              ),
                              child: Slider(
                                min: 0,
                                max: value.duration.inMilliseconds
                                    .toDouble()
                                    .clamp(1, double.infinity),
                                value: value.position.inMilliseconds
                                    .toDouble()
                                    .clamp(
                                      0,
                                      value.duration.inMilliseconds
                                          .toDouble()
                                          .clamp(1, double.infinity),
                                    ),
                                onChangeStart: (_) => _hideTimer?.cancel(),
                                onChanged: (v) {
                                  c.seekTo(Duration(milliseconds: v.round()));
                                },
                                onChangeEnd: (_) => _resetHideTimer(),
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              widget.onToggleFullscreen();
                              _resetHideTimer();
                            },
                            icon: Icon(
                              widget.isFullscreen
                                  ? Icons.fullscreen_exit_rounded
                                  : Icons.fullscreen_rounded,
                              color: Colors.white,
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
        },
      ),
    );
  }
}