# "Sıcak" redesign: outside design review (Claude subagent, 23 Sep 2026)

Review mode. Read: AGENTS.md, CLAUDE.md, HANDOFF.md, `docs/design-system.md`, PLANNING P1–P8, #54–#67, #131–#132, QUESTIONS C20–C22, the B mockups, the before-screenshots, `packages/core/lib/src/theme/**`, `apps/client/lib/home/client_home_screen.dart`. I re-measured every contrast value with the WCAG 2.x formula. Label widths are measured with the bundled `Figtree-SemiBold.ttf`.

## 1. Verdict

Yes, keep "Sıcak". A warm ground, one flat green block carrying today's number and colour-coded exchange groups suit Turkish clients who want a friendly daily companion. They carry over to a dietitian's phone if the panel keeps its lists dense. But the mockups break some of their own new rules. The hero number is partly inferred rather than logged. The tab bar changes with the user's state. Group colours leak into avatars and icons. And cream + Fraunces + forest green + mustard is already a stock look. Fix these before slice 1. None of this reopens a locked decision.

## 2. Findings (by severity)

**F1. Wrong: the hero shows numbers nobody logged.** `B-Bugun.dc.html`: the ring reads "7/12 değişim" and the tiles read "Süt 1/2 … Meyve 1/2", while the side labels count "3 öğün / 2 öğün". P7 logs **whole meals only** (per-group logging was rejected). So exchange counts can only be *inferred* from "meal marked eaten". That breaks rule 5, and it puts two units in one hero. Exact per-group fractions are also the numbers-fixation pattern the eating-disorder studies describe (Eikey 2021, https://www.cambridge.org/core/journals/bjpsych-open/article/effects-of-diet-and-fitness-apps-on-eating-disorder-behaviours-qualitative-study/2D1EE739D97AB3EFC6573835E4C527BD). **Change:** the hero counts meals ("3/5 öğün"). The group tiles show today's *plan* ("Et · 4 değişim"), not eaten fractions.

**F2. Wrong: an action in the tab bar, and tabs that change with the user's state.** In B-Bugun the centre button "Öğün işaretle" is a verb inside the tab bar. B-Baslangic has tabs Bugün/Profil; B-Bugun has Bugün/Planım/İlerleme/Mesajlar and Profil disappears. Apple HIG: "Use a tab bar to support navigation, not to provide actions" and "Don't disable or hide tab bar buttons, even when their content is unavailable" (https://developer.apple.com/design/human-interface-guidelines/tab-bars). **Change:** drop the centre button; the next-meal card's "Öğünü yedim" is the single action. Add tabs per **release**, not per user state. An empty tab says something true ("Diyetisyenin planı gelince burada"), which still satisfies rule 4.

**F3. Wrong: contrast failures in the mockups.** Your token numbers reproduce to ±0.01, with one exception below. My measurements:

| Pair (where) | Ratio | Needed |
|---|---|---|
| step "3" text `#B9DCCD` on hero (B-Baslangic) | **3.61** | 4.5 (13 px bold is not large text) |
| ring arc `#F2C14E` vs its track `#3E9376` (B-Bugun) | **2.22** | 3.0 for legibility (1.4.11 exempts it only because the value is also in text) |
| step border `#6FAF97` vs hero | 2.10 | decorative only if the label carries the state |
| secondary button `#F1EADF` on a white card ("Reddet") | 1.19 | passes 1.4.11 (the text identifies it), but it is a weak signifier |

The design doc measured the highlight against the hero (3.19). But the arc touches the track, not the hero. WCAG's Understanding page says to measure against adjacent colours (https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html). A weak signifier costs time: NN/g found users spent 22 % more time on pages with weak ones (https://www.nngroup.com/articles/flat-ui-less-attention-cause-uncertainty/). The doc's "textPrimary 12.42" on `surfaceSubtle` is really the mockup's `#1F2A24`; the token `#16211D` gives 13.84. The mockups use a text colour and three greys (`#1F2A24 #4F5A52 #5A5348 #6A6254`) that aren't tokens. **Change:** see §5.

**F4. Wrong: group colours leak into other meanings.** B-Baslangic: the "Hedeflerin" icon tile uses the A-grubu-sebze tint (`#E1EFDC/#2F6A22`) and "Diyetisyen bul" uses a Süt-like blue. Avatars in B-Bugun and B-Panel reuse group tints. That breaks the #132 rule that a group colour "only identifies one of the eight groups". Separately, a simulation for colour-blind users (Machado 2009, ΔE76) collapses these pairs: protan Meyve/Yağ 7 and Et/Kuru baklagil 7, deutan B-sebze/Yağ 6. Rule 10 (always label) is what saves this. **Keep** rule 10. **Change:** avatars and icon tiles become neutral (`#F1EADF` with `#46534D`, 6.75).

**F5. Wrong (rules 4, 8 and 15): B-Baslangic trips its own bans.** It shows three identical rows of tinted icon square + bold title + grey subtitle. Two are "Yakında" non-actions, yet they look exactly like the tappable Hedeflerin row. That is rule 4 (never draw unbuilt as clickable), and it is the "identical icon cards" tell that rule 15 bans. The invite card also has a `box-shadow` while it isn't floating (rule 8). **Change:** make Hedeflerin a whole-row tap target with a chevron. Put the Yakında items in one quiet text block with no icon tiles. Remove the invite card's shadow.

**F6. Judgement call, but important: the type pairing is the AI look.** Warm cream plus a soft display serif plus forest green plus mustard was a 2021–24 wellness look. It is now also what LLM front-ends produce when told "not Inter, not purple". Anthropic itself notes that models steered away from one default "default to other common choices" (https://claude.com/blog/improving-frontend-design-through-skills; vendor blog, weak evidence). These mockups were themselves generated by Claude. Two facts from the repo: the bundled `Fraunces-SemiBold.ttf` has no `tnum` feature (GSUB is only `liga, rvrn`), so "7/12" → "10/12" will shift sideways. And only Figtree 400/600 ship, while the mockups use 700/800, so the app will look lighter than the mockups. **Change:** keep the cream, and keep Fraunces for greetings and screen titles only. Every number becomes Figtree 700 with tabular figures; bundle `Figtree-Bold.ttf`.

**F7. Wrong: the main action sits below the fold.** In B-Bugun, "Öğünü yedim" is the fourth block, at about y≈720 in a 390×900 frame that has **no** status bar or gesture inset. On a 360×740 dp Android phone it ends up under the floating bar. **Change:** order the screen hero → next meal → dietitian's message → today's plan → week. Shrink the ring from 150 to about 120 px.

**F8. Wrong: Turkish label length and text scaling.** "Genel Bakış" measures 58 px at 11 px and 75 px at 1.3× text scale, but its B-Panel slot is 70 px. "danışan dikkat istiyor" measures 115 px against about 87 px of tile content (about 77 px at 360 dp): 2 lines, 3 at 1.3×. The before-screenshot `panel-demo-phone.png` already shows "Ölçümleri incele" broken over 4 lines and a 44 px overflow. WCAG 1.4.4 requires text to resize to 200 % (https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html). **Change:** add widget tests at 360 and 412 dp with textScaler 1.0, 1.3 and 2.0, and let nav labels take 2 lines.

**F9. Wrong (clinical trust): "alerji kontrolü temiz" on the approval card.** In B-Panel, an automated all-clear next to "Taslağı incele" invites rubber-stamp approval. That is automation bias, the tendency to over-trust machine output (Goddard et al., JAMIA 2012, https://pubmed.ncbi.nlm.nih.gov/21685142/). P1's gate is only as strong as the review behind it. **Change:** show the inputs, not a verdict ("Kayıtlı alerji: fıstık · planda yok"). **Keep** "incele" rather than "Onayla".

**F10. Judgement call: the panel hero is too tall for a work tool.** The green greeting block takes about 200 px before the first client row, and its stat tiles aren't tappable. **Change:** a slim green header, with tiles that work as filters (48 dp).

**F11. Wrong: some touch targets are too small or only look tappable.** Nav items are fine (58–72 × 68). "Düzenle" in B-Baslangic is a 13 px text link. Flutter's `MaterialTapTargetSize.padded` (app_theme.dart:48–50) only pads Material buttons, not custom `GestureDetector` rows. Targets: Material 48 dp, Apple 44 pt (https://developer.apple.com/design/human-interface-guidelines/accessibility), WCAG 2.5.8 at least 24 px (https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html). **Change:** make whole rows `InkWell`s at least 48 dp tall.

**F12. Implementation risk: reduced motion and the floating bar.** Nothing reads `MediaQuery.disableAnimationsOf` today (grep over apps/ and packages/). Flutter web only honours `prefers-reduced-motion` since PR #180041, merged 14 Jan 2026 (https://github.com/flutter/flutter/pull/180041), so the panel on web needs checking on 3.47. A custom floating bar costs work: `extendBody`, bottom padding on every scroll view (bar + 16 + `viewPadding.bottom`), and your own `Semantics(selected:, button:)`, because `NavigationBar` gives these for free. **Keep** the floating bar: iOS 26 tab bars float by default (HIG, same page as F2). Without glass, it reads as native rather than trendy.

**The #132 rule changes, one by one.** Rule 1 (flat hero): keep. Rule 6 (one centred number): keep, per F1. Rule 8 (shadow on floating elements only): keep, but enforce it (F5). Rule 12 (fill once, 400 ms): keep, gated by the OS setting. #55 (`highlight` + group colours): keep, with F4's restriction.

## 3. What makes health apps feel alive, mapped to our limits

- **One thing that matters right now.** Oura's Today tab surfaces "one big thing" by time of day (https://ouraring.com/blog/new-oura-app-experience/, company blog). For us: Bugün shows the next meal from the plan's times. That is real data.
- **A person, not a mascot.** The dietitian's name, photo and last message are our strongest real content (P2 chat), and nothing an AI-coded page can fake.
- **Immediate response to an action.** A check pop and the ring advancing (rule 12). Motion only after the client does something.
- **Food as content.** Meal names and group chips from the plan; illustrations are C20. No stock photos.
- **Flexible goals.** Apple added "pause rings… without affecting award streaks" and goals per weekday (https://www.apple.com/newsroom/2024/06/watchos-11-brings-powerful-health-and-fitness-insights/). For us: a dietitian-set rest day.
- **Glanceable surfaces later.** Lifesum was early with iOS widgets (https://shortyawards.com/13th/lifesum-draft, award entry). KVKK: anything on the lock screen must hide health data by default.

The App Store listings confirm the references are logging-heavy and are moving to AI: Lifesum sells "photo snapping, voice", and its recent reviews complain of being "forced to talk to an ai" (https://apps.apple.com/us/app/lifesum-calorie-counter-diet/id286906691). MyFitnessPal's subtitle is "AI Nutrition & Macros Tracker" (https://apps.apple.com/us/app/myfitnesspal-calorie-counter/id341232718). A dietitian who approves the plan is our differentiator, so the UI should show that person, not copy their calorie maths.

## 4. Risks

- **Eating disorders and shame (P7).** In Levinson 2017, about 75 % of 105 eating-disorder patients used MyFitnessPal, and 73 % of those felt it contributed (https://pubmed.ncbi.nlm.nih.gov/28843591/). Calorie trackers show more dietary restraint (Simpson & Mazzeo 2017, https://pubmed.ncbi.nlm.nih.gov/28214452/). Eikey 2021 names streaks, red/green feedback and goal gamification (link in F1). The copy "üst üste planına uydun" and a reset-to-zero streak turn one missed meal into failure. Evidence-based alternatives: goals with slack ("emergency reserves") keep people going after a miss (Sharif & Shu 2021, https://www.sciencedirect.com/science/article/abs/pii/S0749597818304187); Headspace lets users hide the streak (https://help.headspace.com/hc/en-us/articles/215730567-How-does-the-run-streak-feature-work). Also, B-Bugun's example message "Dünkü tartın harika!" praises weight. It is example copy, but it sets the tone.
- **Clinical trust:** F9. Also, never show kcal to clients unless the dietitian turns it on.
- **Accessibility:** F3, F8 and F11. Light theme only (#59) is fine.
- **Rule 15 can't be enforced as written.** "Must not look AI-generated" is a taste test, and the mockups pass their author's eye while failing F4 and F5. **Change:** make it a checklist. (a) Every block names a real food, person, time or number from our data. (b) No tinted icon tile without a meaning. (c) No colour used outside its token's meaning. (d) Numbers in the sans. (e) Cover the logo: if the screen could belong to any wellness app, it fails.

## 5. Concrete changes to "Redesign Sıcak"

| Change | Value | Measured |
|---|---|---|
| New `heroTrack` (ring and step tracks) | `#0F4D3B` | highlight on it 5.83; vs hero 1.83 (decorative) |
| Pending step number and border | `#E4F2EC` (= onHeroSecondary) | 4.64 on hero |
| Neutrals | keep `#16211D #46534D #5F6B64`; fix the mockups; correct "12.42" to **13.84** | on `#F6F1E8`: 14.70 / 7.17 / 4.95 |
| Avatars and icon tiles | `#F1EADF` fill, `#46534D` text | 6.75 |
| Group colours | only in group chips, bars and rings; never avatars, icons or status | (unchanged) |
| Numbers | Figtree 700 tabular; bundle `Figtree-Bold.ttf`; Fraunces for greetings and titles only | none (type change) |
| Radius scale (comfortable) | 14 control · 18 card · 28 hero bottom · pill | none (shape change) |
| Motion | 400 / 200 ms; `Duration.zero` when `MediaQuery.disableAnimationsOf` is true | none (motion change) |
| Streak | "Bu hafta 5/7 gün", no reset to zero; the client can hide it | none (behaviour change) |
| Layout tests | 360×740 and 412×915 dp × textScaler 1.0 / 1.3 / 2.0 | none (test setup) |

## 6. Questions for Can

1. **Hero unit:** meals ("3/5 öğün", what the client logs), or exchanges (what the plan is written in, but inferred)?
2. **Streak (C22):** "days this week" with slack, or consecutive days? Can the client hide it, and can the dietitian turn off the streak or weight display for a client with an eating-disorder history?
3. **Tabs:** add Planım, İlerleme and Mesajlar when each ships for everyone, with a true empty state until data exists. Where does Profil live then?
4. **Fraunces:** only greetings and titles (my advice), or also the big numbers?
5. **Panel on phones:** a slim green header with tappable counts, or the full green hero from B-Panel?
