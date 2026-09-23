/// Where the prototype's state survives a page reload.
///
/// The interview demo runs in a browser, so the real implementation is
/// `localStorage`; elsewhere the demo simply starts from seed data. The stub keeps `flutter test` compiling on the VM, where
/// `dart:js_interop` does not exist.
library;

export 'demo_store_stub.dart'
    if (dart.library.js_interop) 'demo_store_web.dart';
