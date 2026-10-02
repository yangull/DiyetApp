import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Stands in for the embedded video call — no video SDK has been picked yet
/// (Agora / 100ms / Daily are candidates), so this screen is a mockup
/// of the moment, not a working call. The dark background is deliberate and
/// outside the brand palette on purpose: real call UIs (FaceTime, Meet, Zoom)
/// go dark regardless of the host app's theme, and matching that here is what
/// makes the mockup read as "this is what a call looks like" rather than "we
/// forgot to theme this screen".
class VideoCallPlaceholderScreen extends StatelessWidget {
  const VideoCallPlaceholderScreen({super.key, required this.clientName});

  final String clientName;

  @override
  Widget build(BuildContext context) {
    final initials = initialsOf(clientName);

    return Scaffold(
      backgroundColor: const Color(0xFF15181A),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.white12,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    clientName,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bağlanıyor…',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A way out that is not the red hang-up button.
                  IconButton(
                    tooltip: 'Geri',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(AppIcons.back, color: Colors.white),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Bu ekran temsilidir; video altyapısı henüz seçilmedi.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Above the call controls, not beside them: on a phone the
            // controls are as wide as the screen and the tile covered the
            // hang-up button.
            Positioned(
              bottom: 24 + 64 + 24,
              right: 24,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(
                  child: Text(
                    'Siz',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mic and camera are drawn disabled: there is no call to
                  // mute yet, and a live-looking button that does nothing is
                  // exactly the fake UI PLANNING #50 rules out.
                  const _CallControl(
                    icon: AppIcons.mic,
                    tooltip: 'Mikrofon: video henüz bağlı değil',
                  ),
                  const SizedBox(width: 16),
                  const _CallControl(
                    icon: AppIcons.video,
                    tooltip: 'Kamera: video henüz bağlı değil',
                  ),
                  const SizedBox(width: 16),
                  _CallControl(
                    icon: AppIcons.callEnd,
                    tooltip: 'Görüşmeyi bitir',
                    background: context.palette.error,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.background = Colors.white24,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: background,
        disabledBackgroundColor: Colors.white12,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
