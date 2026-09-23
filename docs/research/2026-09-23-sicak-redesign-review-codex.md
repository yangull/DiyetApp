# Sıcak redesign — independent Codex review

## 1. Verdict

**Keep Sıcak; revise its information hierarchy and measurement claims before implementation.**
Cream, green and restrained warmth suit the intended experience; suitability for Turkish users remains a hypothesis to test.
Give clients their next meal and dietitians their next task, rather than identical dashboards.
The visual direction is approved; the mockups are not yet an implementation specification.

Reviewed `b0776e8`: required docs, all nine mockup sources, three supplied screenshots, current theme and client home. Mockups were source-inspected, not browser-tested. The panel screenshot is the **demo**, not the real panel. No implementation changed.

## 2. Findings, ranked

**1. High · correctness — The ring overstates the observation. Change.** [B-Bugun:40](/home/can/projects/dietician-app-codex/docs/design/2026-09-23-redesign/mockups/B-Bugun.dc.html:40) shows exchanges, but P7 records meals marked eaten, not consumed portions. Even the example denominators disagree: four group cards total 13, the ring says 12. Recommend meal counts; derived exchanges must explicitly mean planned amounts associated with marked meals. **Can leaves the ring choice open.**

**2. High · clinical trust — “Alerji kontrolü temiz” promises too much. Change.** [B-Panel:50](/home/can/projects/dietician-app-codex/docs/design/2026-09-23-redesign/mockups/B-Panel.dc.html:50) already preserves violet, a dashed edge and “Taslağı incele”: keep these. But #126 requires a check, not an unexplained safety clearance. Require checked inputs, missing-data state and dietitian verification; never equate absent allergy records with no allergies. This is a proposed-copy defect, not an existing automated check.

**3. High · specification — Contrast is measured against incomplete backgrounds. Change.** [Design-system:40](/home/can/projects/dietician-app-codex/docs/design-system.md:40): primary on subtle is **4.474:1**, borderStrong on subtle **2.938:1**; prohibit these for ordinary text/essential boundaries. B’s yellow ring against its actual track is **2.219:1**; vegetable green against the shared bar track would be **2.837:1**. Başlangıç’s informative step “3” is **3.61:1**: use `#E4F2EC` (**4.64:1**). Redundant visible numbers can exempt decorative graphics; these are not blanket WCAG failures. [W3C text](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), [non-text guidance](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html).

**4. Medium · design judgment — Bugün prioritizes summaries over doing. Change.** [B-Bugun:49](/home/can/projects/dietician-app-codex/docs/design/2026-09-23-redesign/mockups/B-Bugun.dc.html:49) places four counters and a message before the meal action. Move the next meal immediately below the hero; subordinate counters. Drop the ambiguous central check from navigation: it duplicates logging without identifying a meal. Material navigation represents destinations; preserve visible labels and add a non-colour selected indicator. [Material component guidance](https://github.com/material-components/material-components-android/blob/master/docs/components/BottomNavigation.md).

**5. Medium · correctness — Başlangıç needs honest unavailable states. Change.** [B-Baslangic:28](/home/can/projects/dietician-app-codex/docs/design/2026-09-23-redesign/mockups/B-Baslangic.dc.html:28) promises “two steps” before a plan that cannot yet be delivered. Keep the named invite, consent explanation and real goal editing, all already supported. Derive completion from saved data; label the unavailable first-plan stage “Yakında.” Specify no-invite, loading and failure variants. Do not make the illustrated invite universal.

**6. Medium · design judgment — Panel is substantially better, but needs actionable density. Change.** [B-Panel:31](/home/can/projects/dietician-app-codex/docs/design/2026-09-23-redesign/mockups/B-Panel.dc.html:31) replaces the screenshot’s broken rail with readable task rows. Keep that. Make counts open filtered tasks, shorten the header, and add “Tümünü gör” when four alerts have only three preview rows. Keep #110’s guessed thresholds visibly qualified until validated; “seven days” is not automatically clinical urgency.

**7. Medium · accessibility — Fixed mockup geometry is not a mobile contract. Change.** B has a **40×40** profile button, **46px** review button, **72px fixed** rows and **11px** navigation labels. Specify ≥48 logical-pixel hit areas and growing rows; test “Diyetisyenine bağlan,” long names and 200% text at 320/360/390 widths. Preserve sen/siz. Android recommends 48dp; current Apple HIG lists 44pt default, 28pt minimum; WCAG AA’s 24 CSS-pixel criterion is different. [Android](https://support.google.com/accessibility/android/answer/7101858), [Apple](https://developer.apple.com/design/human-interface-guidelines/accessibility?changes=latest_maj_6_3&language=objc), [WCAG](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html).

**8. Medium · consistency — Keep most #132 relaxations.** [Design-system:67](/home/can/projects/dietician-app-codex/docs/design-system.md:67): **keep** flat hero (rule 1), one centred number (6), named radius roles and floating-only shadow (8). **Drop** Başlangıç’s extra card shadow and decorative blue/amber avatars: group colours are reserved for groups. **Keep** highlight/group semantics (#55), with text labels; yellow must not become warning. Floating navigation needs safe-area/content clearance, not copied absolute positioning.

**9. Medium · judgment, explicitly reconsidering #132 — Change arrival motion.** [Design-system:71](/home/can/projects/dietician-app-codex/docs/design-system.md:71) already requires reduced motion: retain it. Prefer immediate existing values and animate actual changes only; repeated zero-to-value filling suggests new progress. This recommendation reopens the arrival exception, not the whole direction. If retained, never delay actions; reduced motion renders the final state immediately. [Apple motion](https://developer.apple.com/design/human-interface-guidelines/motion?changes=l_9_3), [Flutter setting](https://api.flutter.dev/flutter/widgets/MediaQuery/disableAnimationsOf.html).

**10. Low · taste/specification — Fraunces is not evidence of AI authorship. Keep, selectively.** [Typography:10](/home/can/projects/dietician-app-codex/packages/core/lib/src/theme/tokens/app_typography.dart:10) already bundles both fonts and reserves serif for headings. B extends it to metrics: use Figtree tabular numerals. Binary inspection confirms Fraunces has proportional digits and no `tnum`; Figtree supports it. Only 400/600 Figtree assets ship: use 600 or bundle 700 explicitly. No credible evidence found establishes “serif + cream = AI-generated.” Rule 15’s concrete bans are testable; its authorship impression requires Can’s visual sign-off.

**11. Low · implementation risk — Theme work is small; custom behaviour is not. Keep the staged rollout.** [AppTheme:47](/home/can/projects/dietician-app-codex/packages/core/lib/src/theme/app_theme.dart:47) already centralizes density and tap padding. Extend palette/copyWith/lerp, preserve bundled fonts, and use standard navigation semantics. Both panel entry points still select compact density; changing colours will not fix their shells. Test keyboard insets, screen readers, text scaling, reduced motion and failed saves before shipping custom rings/navigation. [Flutter accessibility](https://docs.flutter.dev/ui/accessibility).

## 3. What makes health apps feel alive

- **Useful daily change:** MyFitnessPal now opens on the Today diary; Lifesum reduces logging steps. Apply this to P7’s real meal action, not extra dashboards. [MFP support](https://support.myfitnesspal.com/hc/en-us/articles/39985611667341-Your-Today-tab), [Lifesum release notes](https://help.lifesum.com/en/article/what-is-new-these-are-the-latest-additions-to-our-app-1vy6mk1/).
- **Personal context:** Oura separates today from longer-term trends. Show actual messages, approved plans and dated measurements; no synthetic encouragement attributed to a dietitian. [Oura company blog](https://ouraring.com/blog/new-app-design/).
- **Responsive feedback:** visible saved/pending/error states and undo make actions understandable. Keep health details inside authorized views, with neutral notification previews. [NN/g professional guidance](https://www.nngroup.com/articles/ten-usability-heuristics/).

The [Lifesum listing](https://apps.apple.com/us/app/lifesum-ai-calorie-counter/id286906691) and [MyFitnessPal listing](https://apps.apple.com/us/app/myfitnesspal-calorie-counter/id341232718) market logging/personalization, not evidence that their aesthetics improve health. Company blogs are directional, not independent validation. [Google’s M3 research write-up](https://design.google/library/expressive-material-design-google-research) supports purposeful emphasis, not copying every expressive component. My forecast: exaggerated pills, omnipresent rings and bouncy entrances will date faster than legibility, stable navigation and relevant content.

## 4. Risks

Tracking is not inherently harmful or inherently therapeutic. A [38-study review](https://pubmed.ncbi.nlm.nih.gov/39671845/) associates diet/fitness app use with disordered eating and reports guilt; it cannot establish causality. [Streak experiments](https://academic.oup.com/jcr/article/49/6/1095/6623414) show motivation depends on intact versus broken logs, but are not clinical evidence about Turkish clients. Coaching-plus-tracking has [some trial evidence](https://pmc.ncbi.nlm.nih.gov/articles/PMC10155083/), not proof for rings.

**Can confirmed optional streaks and numbers.** Recommend neutral “recorded” language, no punishment/reset pressure, and replace “Dünkü tartın harika”/“planına uydun” sample praise. Missing logging is not failure. Approval remains P1; KVKK review remains QUESTIONS X3. Accessibility needs interaction testing, not palette certification. Rule 15 should judge coherent task flows and identifiable component roles, not purported AI detection.

## 5. Concrete specification changes

Independent calculation: opaque sRGB, WCAG linearization and luminance weights 0.2126/0.7152/0.0722; ratio `(lighter+.05)/(darker+.05)`; rounded only for display.

Keep ground `#F6F1E8`: primary/secondary/muted text **14.70/7.17/4.95**; brand **4.75**, warning **5.26**, error **6.72**, violet **7.33**, border **3.12**. Correct textPrimary/subtle from **12.42 to 13.85**. White/hero **5.35**; secondary hero text **4.64**; warning/tint **5.19**; yellow/hero **3.19**, dark text/yellow **8.25**.

| Proposed role | Pair | Ratio |
|---|---|---:|
| Text on subtle | `#135F49 / #F1EADF` | 6.37 |
| Essential border on subtle | `#78867F / #F1EADF` | 3.19 |
| Vegetable bar/track | `#478B37 / #EFE8DC` | 3.44 |
| Yellow fill/darker track | `#F2C14E / #135F49` | 4.53 |

Keep visible numeric alternatives; the darker ring track itself is not a high-contrast boundary against the hero.

All eight original group colours pass on white: süt **4.19**, et **4.48**, nişastalı **3.69**, baklagil **4.94**, A-sebze **3.45**, B-sebze **3.88**, meyve **4.26**, yağ **4.37**. These are graphic colours, not general text colours.

Complete the missing chip pairs:

| Group | Text / tint | Ratio |
|---|---|---:|
| Süt | `#2B5EA8 / #DCE8F7` | 5.18 |
| Baklagil | `#624A2D / #EEE5D8` | 6.64 |
| B-sebze | `#1D6662 / #DCF0EC` | 5.66 |
| Meyve | `#983055 / #F8E0E9` | 5.83 |
| Yağ | `#46546A / #E7ECF2` | 6.46 |

Existing et/nişastalı/A-sebze chip pairs verify at **6.27/5.71/5.48**. Specify 48px minimum targets, 72px **minimum** rows, 14–16px task text, 12–13px navigation labels, 18/14/28 radius roles; retain font scaling rather than forcing everything into 900px.

## 6. Questions for Can

1. Main ring: meals marked or explicitly derived planned exchanges? **Left open by Can.**
2. C21: must full weekly editing work on phones, or review and small edits?
3. C20: commission consistent group illustrations, use a licensed set, or keep text chips?

**Claude cross-check:** Read the [completed review](/home/can/projects/dietician-app/docs/research/2026-09-23-sicak-redesign-review-claude.md). Confirmed its font and step-contrast findings. Its “AI look” assertion remains taste, not established evidence. Its claim that navigation targets are 68px high mistakes the parent’s height for each child’s hit area. Add destinations when features ship; do not add unbuilt tabs merely to copy Apple. Once shipped, keep navigation stable across empty/populated states. Product answers here have not changed tracked decision documents.
