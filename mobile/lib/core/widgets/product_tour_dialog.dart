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
  static const double _fallbackAspectRatio = 3 / 4;
  static const double _gap = 16.0;
  static const double _screenSafeMargin = 20.0;
  static const double _minVideoHeight = 90.0;

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

  double get _activeAspectRatio {
    if (_isReady) {
      final size = _controller.value.size;
      if (size.width > 0 && size.height > 0) {
        return size.width / size.height;
      }
    }
    return _fallbackAspectRatio;
  }

  Size _resolveVideoBoxSize(double maxWidth, double maxHeight) {
    final aspectRatio = _activeAspectRatio;
    var width = maxWidth;
    var height = width / aspectRatio;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspectRatio;
    }
    return Size(width, height);
  }
  double _estimateChromeHeight() {
    final step = _currentStep;
    var height = 32.0;
    if (widget.steps.length > 1) height += 20;
    if (step.title != null) height += 28;
    if (step.description != null) height += 44;
    height += 12;
    height += 12;
    height += 44;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    const horizontalInset = 20.0;
    final cardWidth = screenWidth - (horizontalInset * 2);

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
    required double screenHeight,
    required double horizontalInset,
  }) {
    final chromeHeight = _estimateChromeHeight();
    final absoluteMaxVideoHeight = screenHeight * 0.4;

    double top;
    double? bottom;
    double maxVideoHeight;

    if (targetRect == null) {
      final available =
          screenHeight - (_screenSafeMargin * 2) - chromeHeight;
      maxVideoHeight = available.clamp(_minVideoHeight, absoluteMaxVideoHeight);
      final cardHeightGuess = chromeHeight + maxVideoHeight;
      top = ((screenHeight - cardHeightGuess) / 2).clamp(
        _screenSafeMargin,
        screenHeight - _screenSafeMargin - cardHeightGuess,
      );
    } else {
      final spaceBelow =
          screenHeight - targetRect.bottom - _gap - _screenSafeMargin;
      final spaceAbove = targetRect.top - _gap - _screenSafeMargin;
      final placeBelow = spaceBelow >= spaceAbove;
      final available = placeBelow ? spaceBelow : spaceAbove;

      maxVideoHeight =
          (available - chromeHeight).clamp(_minVideoHeight, absoluteMaxVideoHeight);

      if (placeBelow) {
        top = targetRect.bottom + _gap;
        bottom = null;
      } else {
        top = targetRect.top - _gap - (chromeHeight + maxVideoHeight);
        top = top.clamp(_screenSafeMargin, double.infinity);
        bottom = null;
      }
    }

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
            if (_currentStep.title != null) ...[
              Text(
                _currentStep.title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
            ],
            if (_currentStep.description != null) ...[
              Text(
                _currentStep.description!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            Center(
              child: _buildVideoArea(
                maxWidth: cardWidth,
                maxHeight: maxVideoHeight,
              ),
            ),
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

    return Positioned(
      left: horizontalInset,
      right: horizontalInset,
      top: top,
      bottom: bottom,
      child: cardContent,
    );
  }

  Widget _buildVideoArea({required double maxWidth, required double maxHeight}) {
    final boxSize = _resolveVideoBoxSize(maxWidth, maxHeight);

    if (_hasError) {
      return SizedBox(
        width: boxSize.width,
        height: boxSize.height,
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: boxSize.width,
        height: boxSize.height,
        child: _isReady
            ? VideoPlayer(_controller)
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