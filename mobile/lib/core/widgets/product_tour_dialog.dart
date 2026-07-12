import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/product_tour_step.dart';
import '../services/tour_dismiss_store.dart';

class ProductTourDialog extends StatefulWidget {
  const ProductTourDialog({
    super.key,
    required this.steps,
    required this.onFinished,
    this.tourKey,
    this.store,
  }) : assert(
          store == null || tourKey != null,
          'tourKey wajib diisi kalau store dikasih',
        );
  final String? tourKey;
  final List<ProductTourStep> steps;
  final TourDismissStore? store;
  final VoidCallback onFinished;
  static Future<void> showIfNeeded(
    BuildContext context, {
    required List<ProductTourStep> steps,
    String? tourKey,
    TourDismissStore? store,
  }) async {
    if (steps.isEmpty || !context.mounted) return;

    if (store != null) {
      final alreadyDismissed = await store.isDismissed(tourKey!);
      if (alreadyDismissed || !context.mounted) return;
    }

    if (!context.mounted) return;
    final overlayState = Overlay.of(context);

    late final OverlayEntry entry;
    var removed = false;
    void removeEntry() {
      if (removed) return;
      removed = true;
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (_) => ProductTourDialog(
        steps: steps,
        tourKey: tourKey,
        store: store,
        onFinished: removeEntry,
      ),
    );

    overlayState.insert(entry);
  }

  @override
  State<ProductTourDialog> createState() => _ProductTourDialogState();
}

class _ProductTourDialogState extends State<ProductTourDialog> {
  late VideoPlayerController _controller;
  int _stepIndex = 0;
  bool _dontRemindAgain = false;
  bool _isReady = false;
  bool _hasError = false;

  ProductTourStep get _currentStep => widget.steps[_stepIndex];
  bool get _isLastStep => _stepIndex >= widget.steps.length - 1;
  bool get _hasDismissOption => widget.store != null;

  @override
  void initState() {
    super.initState();
    _initController(_currentStep);
  }

  void _initController(ProductTourStep step) {
    _isReady = false;
    _hasError = false;
    _controller = step.isNetworkVideo
        ? VideoPlayerController.networkUrl(Uri.parse(step.videoAssetPath))
        : VideoPlayerController.asset(step.videoAssetPath);

    _controller
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isReady = true);
        _controller.play();
      }).catchError((Object error, StackTrace stack) {
        if (kDebugMode) {
          debugPrint('ProductTourDialog: gagal load video -> $error');
        }
        if (!mounted) return;
        setState(() => _hasError = true);
      })
      ..addListener(_onVideoTick);
  }

  void _onVideoTick() {
    final value = _controller.value;
    if (value.hasError && !_hasError) {
      setState(() => _hasError = true);
      return;
    }
    if (value.isInitialized &&
        !value.isPlaying &&
        value.duration > Duration.zero &&
        value.position >= value.duration) {
      _handleOk();
    }
  }

  Future<void> _handleOk() async {
    if (_hasDismissOption && _dontRemindAgain) {
      await widget.store!.markDismissed(widget.tourKey!);
      widget.onFinished();
      return;
    }

    if (_isLastStep) {
      widget.onFinished();
      return;
    }

    final oldController = _controller;
    oldController.removeListener(_onVideoTick);
    setState(() {
      _stepIndex += 1;
      _initController(_currentStep);
    });
    await oldController.dispose();
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoTick);
    _controller.dispose();
    super.dispose();
  }

  Rect? _resolveTargetRect(GlobalKey? key, double padding) {
    final ctx = key?.currentContext;
    if (ctx == null) return null;
    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final topLeft = renderObject.localToGlobal(Offset.zero);
    final rect = topLeft & renderObject.size;
    return rect.inflate(padding);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    const horizontalInset = 20.0;
    final cardWidth = screenWidth - (horizontalInset * 2);
    final videoHeight = cardWidth * 9 / 16;

    final targetRect = _resolveTargetRect(
      _currentStep.targetKey,
      _currentStep.highlightPadding,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: CustomPaint(
              painter: _SpotlightPainter(
                highlightRect: targetRect,
                borderRadius: _currentStep.highlightBorderRadius,
                barrierColor: Colors.black.withValues(alpha: 0.78),
              ),
            ),
          ),
        ),
        _buildCard(
          context: context,
          targetRect: targetRect,
          cardWidth: cardWidth,
          videoHeight: videoHeight,
          screenHeight: screenHeight,
          horizontalInset: horizontalInset,
        ),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required Rect? targetRect,
    required double cardWidth,
    required double videoHeight,
    required double screenHeight,
    required double horizontalInset,
  }) {
    final step = _currentStep;
    const gap = 16.0;

    final cardContent = Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.steps.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${_stepIndex + 1}/${widget.steps.length}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey),
                ),
              ),
            if (step.title != null) ...[
              Text(
                step.title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
            ],
            if (step.description != null) ...[
              Text(
                step.description!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            _buildVideoArea(width: cardWidth, height: videoHeight),
            const SizedBox(height: 12),
            Row(
              children: [
                if (_hasDismissOption)
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
                  )
                else
                  const Spacer(),
                ElevatedButton(
                  onPressed: _handleOk,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(88, 44),
                  ),
                  child: Text(_isLastStep ? 'OK' : 'Lanjut'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (targetRect == null) {
      return Positioned(
        left: horizontalInset,
        right: horizontalInset,
        top: (screenHeight - videoHeight) / 2 - 60,
        child: cardContent,
      );
    }
    final spaceBelow = screenHeight - targetRect.bottom;
    final spaceAbove = targetRect.top;
    final placeBelow = spaceBelow >= spaceAbove;

    if (placeBelow) {
      return Positioned(
        left: horizontalInset,
        right: horizontalInset,
        top: targetRect.bottom + gap,
        child: cardContent,
      );
    }

    return Positioned(
      left: horizontalInset,
      right: horizontalInset,
      bottom: (screenHeight - targetRect.top) + gap,
      child: cardContent,
    );
  }

  Widget _buildVideoArea({required double width, required double height}) {
    if (_hasError) {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          alignment: Alignment.center,
          color: Colors.black12,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Video gagal dimuat di perangkat ini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      );
    }
    final videoSize = _controller.value.size;
    final sizeValid = _isReady && videoSize.width > 0 && videoSize.height > 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: height,
        child: sizeValid
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoSize.width,
                  height: videoSize.height,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.highlightRect,
    required this.borderRadius,
    required this.barrierColor,
  });

  final Rect? highlightRect;
  final double borderRadius;
  final Color barrierColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final scrimPaint = Paint()..color = barrierColor;

    if (highlightRect == null) {
      canvas.drawRect(fullRect, scrimPaint);
      return;
    }

    final fullPath = Path()..addRect(fullRect);
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          highlightRect!,
          Radius.circular(borderRadius),
        ),
      );
    final scrimPath = Path.combine(
      PathOperation.difference,
      fullPath,
      holePath,
    );
    canvas.drawPath(scrimPath, scrimPaint);
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlightRect!, Radius.circular(borderRadius)),
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.highlightRect != highlightRect ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.barrierColor != barrierColor;
  }
}