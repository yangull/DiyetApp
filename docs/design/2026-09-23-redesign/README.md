# Redesign mockups, 23 Sep 2026

Input for the "Sıcak" redesign (PLANNING #131, #132; `docs/design-system.md`,
"Redesign Sıcak"). A record of what Can compared, not a spec: the values that hold are
in `docs/design-system.md`.

- `screenshots/`: the apps as they were on the Android emulator (Pixel 8a, 1080×2400)
  before the redesign. `client-home.png` and `client-profil.png` are the real client
  app; `panel-demo-phone.png` is the panel's interview demo (`lib/main_demo.dart`) on a
  phone, showing the desktop layout that the mobile panel slice replaces.
- `mockups/`: three directions, three screens each, as HTML (390 px wide phone frames;
  open in a browser). All values in them are examples.
  - **A** "Serin, canlı": today's palette plus a tinted hero. The fewest rule changes.
  - **B** "Sıcak": Lifesum-like. **Chosen by Can** (PLANNING #131). Its colours were
    re-measured after the choice; the file has the measured values.
  - **C** "Net": MyFitnessPal-like, bold sans headings, week strip.
  - Per direction: `*-Bugun` (the client's day once a plan exists), `*-Baslangic`
    (what the client home can show today with real data only), `*-Panel` (the panel's
    Genel Bakış on a phone).
- The live canvas with all of these side by side (Can's account only):
  https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn

Can's references are **Lifesum** and **MyFitnessPal**; he has no screenshots of his own.
Their App Store listings (apps.apple.com, ids 286906691 and 341232718) were the source
for the comparison.
