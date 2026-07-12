import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/product_tour_service.dart';
class ProductTourDialog extends StatefulWidget {
  const ProductTourDialog({
    super.key,
    required this.tourKey,
    required this.videoAssetPath,
    this.title,
    this.description,
    this.isNetworkVideo = false,
  });
  final String tourKey;
  final String videoAssetPath;

  final String? title;
  final String? description;
  final bool isNetworkVideo;
  static Future<void> showIfNeeded(
    BuildContext context, {
    required String tourKey,
    required String videoAssetPath,
    String? title,
    String? description,
    bool isNetworkVideo = false,
  }) async {
    final alreadyDismissed =
        await ProductTourService.instance.isDismissed(tourKey);
    if (alreadyDismissed || !context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => ProductTourDialog(
        tourKey: tourKey,
        videoAssetPath: videoAssetPath,
        title: title,
        description: description,
        isNetworkVideo: isNetworkVideo,
      ),
    );
  }

  @override
  State<ProductTourDialog> createState() => _ProductTourDialogState();
}

class _ProductTourDialogState extends State<ProductTourDialog> {
  late final VideoPlayerController _controller;
  bool _dontRemindAgain = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.isNetworkVideo
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoAssetPath))
        : VideoPlayerController.asset(widget.videoAssetPath);

    _controller
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isReady = true);
        _controller.play();
      })
      ..addListener(_onVideoTick);
  }

  void _onVideoTick() {
    final value = _controller.value;
    if (value.isInitialized &&
        !value.isPlaying &&
        value.duration > Duration.zero &&
        value.position >= value.duration) {
      _finish();
    }
  }

  Future<void> _finish() async {
    if (_dontRemindAgain) {
      await ProductTourService.instance.markDismissed(widget.tourKey);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
            ],
            if (widget.description != null) ...[
              Text(
                widget.description!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio:
                    _isReady ? _controller.value.aspectRatio : 16 / 9,
                child: _isReady
                    ? VideoPlayer(_controller)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _dontRemindAgain,
                        onChanged: (v) {
                          setState(() => _dontRemindAgain = v ?? false);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Jangan ingatkan saya lagi',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _finish,
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}