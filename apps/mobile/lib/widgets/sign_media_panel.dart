import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../models/sign_detail.dart';
import 'sign_video_player.dart';

class SignMediaPanel extends StatelessWidget {
  const SignMediaPanel({super.key, required this.signDetail});

  final SignDetail signDetail;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildMediaContent(context),
        ),
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    if (signDetail.hasVideo) {
      return SignVideoPlayer(
        key: ValueKey(signDetail.videoUrl),
        videoUrl: signDetail.videoUrl!,
        thumbnailUrl: signDetail.thumbnailUrl,
      );
    }

    if (signDetail.hasThumbnail) {
      return _ThumbnailPanel(thumbnailUrl: signDetail.thumbnailUrl!);
    }

    return _NoMediaPanel();
  }
}

class _NoMediaPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.play_circle_outline,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signVideoComingSoon,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ThumbnailPanel extends StatelessWidget {
  const _ThumbnailPanel({required this.thumbnailUrl});

  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _NoMediaPanel();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                l10n.previewImage,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
