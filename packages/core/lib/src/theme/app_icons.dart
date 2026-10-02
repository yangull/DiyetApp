import 'package:flutter/widgets.dart';

/// The one icon set (audit X4, Can 2 Oct 2026): Lucide, rounded strokes that
/// match Alpino and read the same on iOS and Android. Screens name an icon by
/// its role here, never by pack, so the pack changes in this file only.
///
/// Lucide's two fonts are bundled in `packages/core/fonts` as the families
/// `AppIcons` and `AppIconsHeavy` (its 2 px and 3 px stroke), with the codepoints
/// of the icons used below, instead of depending on the wrapper package: that
/// package declares seven fonts, and Flutter ships every one it cannot subset.
/// Icons are `const IconData`, so a release build subsets each font to just the
/// glyphs used. Licence: `fonts/Lucide-LICENSE.txt` (ISC).
///
/// A navigation entry has two forms: the plain stroke, and a heavier one
/// (`...Active`) for the selected entry, since Lucide has no filled twins.
abstract final class AppIcons {
  const AppIcons._();

  // Navigation
  static const IconData dashboard = IconData(
    0xe1c1,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData dashboardActive = IconData(
    0xe1c1,
    fontFamily: 'AppIconsHeavy',
    fontPackage: 'core',
  );
  static const IconData profile = IconData(
    0xe19f,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData profileActive = IconData(
    0xe19f,
    fontFamily: 'AppIconsHeavy',
    fontPackage: 'core',
  );
  static const IconData clients = IconData(
    0xe1a4,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData clientsActive = IconData(
    0xe1a4,
    fontFamily: 'AppIconsHeavy',
    fontPackage: 'core',
  );
  static const IconData appointments = IconData(
    0xe063,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData appointmentsActive = IconData(
    0xe063,
    fontFamily: 'AppIconsHeavy',
    fontPackage: 'core',
  );
  static const IconData messages = IconData(
    0xe116,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData messagesActive = IconData(
    0xe116,
    fontFamily: 'AppIconsHeavy',
    fontPackage: 'core',
  );
  static const IconData progress = IconData(
    0xe2a5,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData progressActive = IconData(
    0xe2a5,
    fontFamily: 'AppIconsHeavy',
    fontPackage: 'core',
  );
  static const IconData payments = IconData(
    0xe052,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData paymentsActive = IconData(
    0xe052,
    fontFamily: 'AppIconsHeavy',
    fontPackage: 'core',
  );
  static const IconData home = IconData(
    0xe0f5,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData homeActive = IconData(
    0xe0f5,
    fontFamily: 'AppIconsHeavy',
    fontPackage: 'core',
  );

  // Actions
  static const IconData add = IconData(
    0xe13d,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData remove = IconData(
    0xe11c,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData close = IconData(
    0xe1b2,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData check = IconData(
    0xe06c,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData search = IconData(
    0xe151,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData filter = IconData(
    0xe29a,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData reset = IconData(
    0xe148,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData send = IconData(
    0xe152,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData logout = IconData(
    0xe10e,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData invite = IconData(
    0xe1a2,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData pdf = IconData(
    0xe0cc,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData chevronRight = IconData(
    0xe06f,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData chevronDown = IconData(
    0xe06d,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData back = IconData(
    0xe048,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData arrowDown = IconData(
    0xe042,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData arrowUp = IconData(
    0xe04a,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData show = IconData(
    0xe0ba,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData hide = IconData(
    0xe0bb,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );

  // Things and states
  static const IconData notifications = IconData(
    0xe059,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData video = IconData(
    0xe1a5,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData callEnd = IconData(
    0xe138,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData mic = IconData(
    0xe118,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData mail = IconData(
    0xe10f,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData lock = IconData(
    0xe10b,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData clock = IconData(
    0xe087,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData waiting = IconData(
    0xe296,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData info = IconData(
    0xe0f9,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData error = IconData(
    0xe077,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData appointmentMissed = IconData(
    0xe2be,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData announcement = IconData(
    0xe235,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData inPerson = IconData(
    0xe19f,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
  static const IconData settings = IconData(
    0xe29a,
    fontFamily: 'AppIcons',
    fontPackage: 'core',
  );
}
