import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Plays a remote sign video (MP4). Used on web, Android, and iOS.
class SignVideoPlayer extends StatefulWidget {
  const SignVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  final String videoUrl;
  final String? thumbnailUrl;

  @override
  State<SignVideoPlayer> createState() => _SignVideoPlayerState();
}

class _SignVideoPlayerState extends State<SignVideoPlayer> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(SignVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _isInitialized = false;
      _hasError = false;
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    final videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _videoController = videoController;
    videoController.addListener(_handleControllerUpdate);

    try {
      await videoController.initialize();
      if (!mounted || _videoController != videoController) {
        await videoController.dispose();
        return;
      }

      if (videoController.value.hasError) {
        throw Exception(videoController.value.errorDescription);
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (error) {
      debugPrint('SignVideoPlayer failed for ${widget.videoUrl}: $error');
      videoController.removeListener(_handleControllerUpdate);
      await videoController.dispose();
      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
        _videoController = null;
      });
    }
  }

  void _handleControllerUpdate() {
    final videoController = _videoController;
    if (videoController == null || !videoController.value.hasError) {
      return;
    }

    debugPrint(
      'SignVideoPlayer error for ${widget.videoUrl}: '
      '${videoController.value.errorDescription}',
    );

    if (mounted) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _disposeController() {
    final videoController = _videoController;
    if (videoController != null) {
      videoController.removeListener(_handleControllerUpdate);
      videoController.dispose();
    }
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _togglePlayback() {
    final videoController = _videoController;
    if (videoController == null || !_isInitialized) {
      return;
    }

    setState(() {
      if (videoController.value.isPlaying) {
        videoController.pause();
      } else {
        videoController.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _VideoErrorPanel(onRetry: _retryAfterError);
    }

    if (!_isInitialized || _videoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final videoController = _videoController!;
    final isPlaying = videoController.value.isPlaying;
    final videoSize = videoController.value.size;

    if (videoSize.width == 0 || videoSize.height == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: videoSize.width,
            height: videoSize.height,
            child: VideoPlayer(videoController),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _togglePlayback,
              child: Center(
                child: AnimatedOpacity(
                  opacity: isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.play_arrow,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _retryAfterError() {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    _initializePlayer();
  }
}

class _VideoErrorPanel extends StatelessWidget {
  const _VideoErrorPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load video',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check that the API is running and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
