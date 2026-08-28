import 'package:web/web.dart' as web;

/// A refresh mid-interview must not throw away what the dietitian just typed,
/// so the whole demo state is mirrored into `localStorage` after every change.
class DemoStore {
  const DemoStore();

  /// No version in the key: `demo_codec.dart`'s `_schemaVersion` lives inside
  /// the payload and already discards anything it cannot read. A second
  /// version here would either drift from that one or orphan an entry per
  /// bump.
  static const _key = 'wellkit.demo';

  String? read() {
    try {
      return web.window.localStorage.getItem(_key);
    } catch (_) {
      // Private-mode browsers can throw on access. A demo that forgets is
      // still better than a demo that crashes.
      return null;
    }
  }

  void write(String json) {
    try {
      web.window.localStorage.setItem(_key, json);
    } catch (_) {}
  }

  void clear() {
    try {
      web.window.localStorage.removeItem(_key);
    } catch (_) {}
  }
}
