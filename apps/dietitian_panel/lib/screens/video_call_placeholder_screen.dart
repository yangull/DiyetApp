import 'package:flutter/material.dart';

/// Stands in for the embedded video call — PLANNING.md §3 hasn't picked an
/// SDK yet (Agora / 100ms / Daily are candidates), so this screen is a mockup
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
    final initials = clientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

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
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bağlanıyor…',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Bu ekran temsilidir — video altyapısı henüz seçilmedi '
                  '(PLANNING.md §3).',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
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
                  _CallControl(icon: Icons.mic_none, onPressed: () {}),
                  const SizedBox(width: 16),
                  _CallControl(icon: Icons.videocam_outlined, onPressed: () {}),
                  const SizedBox(width: 16),
                  _CallControl(
                    icon: Icons.call_end,
                    background: const Color(0xFFA32017),
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
    required this.onPressed,
    this.background = Colors.white24,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: background,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
