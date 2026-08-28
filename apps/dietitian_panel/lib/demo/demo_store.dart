/// Where the prototype's state survives a page reload.
///
/// The panel is web only (locked decision §2.3 #38), so the real implementation
/// is `localStorage`. The stub keeps `flutter test` compiling on the VM, where
/// `dart:js_interop` does not exist.
library;

export 'demo_store_stub.dart'
    if (dart.library.js_interop) 'demo_store_web.dart';
