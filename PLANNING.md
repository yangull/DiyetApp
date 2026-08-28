# Diyetisyenlik App — Proje Planlama & Context Dosyası

> **Bu dosyanın amacı:** Claude Code ile geliştirmeye başlarken projenin tüm bağlamını tek yerde tutmak.
> Yaşayan bir doküman — her seansta güncellenir, sıfırdan yazılmaz.
> **Durum:** Baseline (v0.1) — 1 günlük beyin fırtınasına dayanıyor, her şey değişebilir.
> **Son güncelleme:** 28 Ağustos 2026 (tasarım sistemi kilitlendi, koda işlendi)

---

## 1. Ürün Özeti

Türkiye pazarı için iki taraflı bir diyetisyen marketplace uygulaması.

**İki kitle:**
- **Diyetisyenler** → yönetim paneli + marketplace'te görünürlük + müşteri kazanımı
- **Müşteriler (danışanlar)** → uygun fiyatlı diyetisyen erişimi VEYA sadece-AI diyet planı

**Gelir modeli (taslak):**
- Diyetisyen-müşteri eşleşmelerinden **komisyon** (oran henüz belirlenmedi)
- AI-only tier için **aylık subscription** (fiyat henüz belirlenmedi)
- İleride B2B: catering firmaları, yemek kartı entegrasyonları, kurumsal satış

**İsim, renk paleti, marka:** Daha sonra seçilecek. Şimdilik kod adı "Diyetisyenlik App".

---

## 2. Kilitlenen Ürün Kararları

Bunlar tartışıldı ve şimdilik sabit:

1. **AI taslak hazırlar, diyetisyen onaylar.** Müşteri, diyetisyen onayından geçmemiş AI planı görmez (insan-hizmet tarafında).
2. **Tüm görüşmeler uygulama içinde kalır.** Chat + gömülü video. WhatsApp/Instagram'a kaçış = komisyon kaybı riski.
3. **Build sırası:** Ortak çekirdek (shared core) → Diyetisyen marketplace → AI-only tier.

## 2.1 Kilitlenen Teknik Kararlar — Faz 0 İskeleti

> 26 Ağustos 2026 grill seansında karara bağlandı.
> Kapsam: **sadece iskelet** — Supabase şeması bu dilime dahil değil.

**Ortam ve araçlar**

1. Flutter stable, **WSL2 içine resmî yöntemle** kurulur. Şimdilik FVM yok: Codemagic kendi Flutter sürümünü sabitleyebiliyor, gerekirse FVM sonradan eklenir (10 dakikalık değişiklik).
2. Günlük geliştirme **web öncelikli**: `flutter run -d web-server`, Windows tarayıcısından açılır. Böylece WSL içine Chrome kurmak gerekmez.
3. Windows tarafındaki **Android emulator + adb köprüsü Faz 1'in erken bir dilimi** — bu dilimde yok. "Sonra" değil erken, çünkü Chrome mobile özgü sorunları gizler.
4. Bağımlılık çözümü için **Dart pub workspaces**, script'ler için üstünde **Melos 7**. Kilitli "Melos" kararını modern mekanikle karşılar.
5. Melos script'leri: `analyze`, `format`, `test`.
6. Lint temeli **flutter_lints**, workspace kökünden üç paketçe paylaşılır. Sıkılık sonradan artırılabilir.

**Repo yapısı**

7. `apps/client` — platformlar: **android, ios, web**. Web hedefi *sadece geliştirme içindir* (Android/iOS toolchain'leri kurulana kadar Chrome önizlemesi); kaldırılıp kaldırılmayacağı yayından önce tekrar değerlendirilir. ⚠️ RevenueCat/IAP ve video SDK web'de çalışmayabilir — web bir duman testi, doğrulama ortamı değil.
8. `apps/dietitian_panel` — **sadece web**.
9. `packages/core` — ortak paket.
10. `supabase/migrations/` ve `supabase/functions/` — `.gitkeep` ile **boş** oluşturulur; bu dilimde şema/Edge Function işi yapılmaz ama iskelet planlanan ağaca uyar.
11. Dart paket adları tam olarak: `client`, `dietitian_panel`, `core`.
12. Org tanımlayıcı placeholder: **`com.dietapp`** (örn. `com.dietapp.client`). Gerçek marka adı belirlenince, herhangi bir TestFlight/Play yüklemesinden **önce** değiştirilir → Açık Soru #14.

**Bu dilimde `packages/core` içeriği**

13. Material 3 teması (açık + koyu), tek bir placeholder seed renginden. Seed'e `// TODO: replace with brand color` işareti konur.
14. Derleme zamanı değerlerini `--dart-define-from-file` ile okuyan tipli **`AppConfig`** sınıfı. Gerçek değerler `.gitignore`'daki `env/dev.json`'da; şablon commit'lenen `env/dev.example.json`'da.
15. `AppConfig`'in doc comment'i üç şeyi açıkça yazar: **Supabase anon key tasarım gereği publictir**; veriyi asıl koruyan **Row Level Security**'dir; **`service_role` anahtarı client tarafında asla yer almaz.**
16. Paket başına bir adet basit smoke test — `melos run test` ilk günden yeşil.
17. **Henüz mock Supabase client wrapper yok** — o bir sonraki dilim (§12 adım 2).
18. Her iki app de temayı ve config'i `core`'dan import eder — monorepo bağlantısının çalıştığını kanıtlayan şey budur.

**İskelet sonrası**

19. Özel (private) **GitHub reposu** açılır ve push edilir. Push öncesi Can'a sorulur.

**Durum: §12 adım 1 tamamlandı (28 Ağu 2026)**

- Flutter **3.47.2** / Dart **3.13.2** WSL'e kuruldu (`~/development/flutter`, PATH `~/.bashrc`'de).
- İskelet kuruldu: `apps/client` (android+ios+web), `apps/dietitian_panel` (sadece web), `packages/core`. Org: `com.dietapp`.
- `packages/core`: `AppConfig` (#14, #15 doc comment'i dahil) ve `AppTheme` (M3 açık/koyu, `// TODO: replace with brand color`). Her iki app de ikisini de import ediyor (#18 kanıtlandı).
- Yeşil: `dart run melos run analyze` (3 pakette sorun yok) ve `dart run melos run test` (4 test).
- `flutter build web --dart-define-from-file=../../env/dev.json` çalışıyor; bundle'da sadece "yapılandırma yüklendi" dalı kalıyor → dart-define değerleri derlemeye gerçekten ulaşıyor.
- `flutter run -d web-server` 8080'de servis ediyor (HTTP 200), Windows tarayıcısından açılıyor.

**Karara sadık kalınamayan iki nokta (bilinçli sapma):**

- **#4 "Melos 7" yerine Melos 8.5.0 kuruldu.** Melos 7 geride kaldı; 8.5.0 Dart ^3.9.0 istiyor, elimizde 3.13.2 var. Aynı pub workspaces mekanizması.
- **§11'deki `melos.yaml` dosyası yok.** Melos 8, kök `pubspec.yaml` bir pub workspace tanımlıyorsa `melos.yaml`'ı görmezden geliyor (`NoScriptException`); config `pubspec.yaml` içindeki `melos:` anahtarına taşındı. Script'ler de `melos` değil `dart run melos` çağırıyor (global activate yok).

**Bilinen tuhaflık:** `flutter devices` bu WSL kurulumunda `web-server` cihazını listelemiyor, ama `-d web-server` çalışıyor. Zaman kaybetme.


---

## 2.2 Kilitlenen Teknik Kararlar — Veri & Auth Dilimi

> 28 Ağustos 2026'da karara bağlandı. Kapsam: §12 adım 2–4 (mock wrapper, ilk şema, auth).

**Auth ve state**

20. İlk auth diliminde **sadece e-posta + parola**. Supabase telefon/SMS OTP'si ücretli bir SMS sağlayıcısı (Twilio vb.) gerektiriyor → ertelendi, muhtemelen hiç yapılmayacak. §7'deki "e-posta + telefon" bu şekilde daraltıldı.
21. Geliştirmede e-posta doğrulama (confirmation) **kapalı** — deep-link işi bu dilime girmez.
22. State management: **Riverpod**. Açık Soru #11 kapandı.
23. `admin` rolü uygulama içinden oluşturulmaz; MVP'de Supabase dashboard'undan elle atanır.

**Veri ve güvenlik**

24. SQL tanımlayıcıları (tablo/kolon adları) **İngilizce**. §8'deki Türkçe adlar taslak kısaltmasıdır; Türkçe sadece UI metinlerinde kalır.
25. Kilitli karar §2 #1 (onaysız AI planı müşteriye görünmez) **RLS politikasıyla** zorunlu kılınır — sadece uygulama kodunda değil. Faz 1'de `diet_plans` üzerinde uygulanır.
26. Şema **Supabase CLI** ile yönetilir: `supabase migration new` + `supabase db push`, EU'daki bulut projesine link'li. Yerel Docker stack (`supabase start`) şimdilik kurulmaz.
27. Şema asla dashboard UI'ından elle oluşturulmaz — her değişiklik `supabase/migrations/` altında SQL olarak versiyonlanır.

**Mock wrapper (§12 adım 2)**

28. `packages/core` içinde soyut repository arayüzleri (`AuthRepository` vb.) + in-memory sahte implementasyonlar. `supabase_flutter` bağımlılığı adım 3'e kadar `core`'a girmez.

**Komutlar**

29. `format` script'i dosyaları **yazar**; check modu (`--set-exit-if-changed`) CI kurulunca değerlendirilir.
30. Kanonik çalıştırma komutu, app dizininden: `flutter run -d web-server --dart-define-from-file=../../env/dev.json`. Gerçek komutlar CLAUDE.md'ye işlenir.

**Rol modeli ve ilk migration**

31. Rol `public.profiles.role` kolonunda durur (enum: `client|dietitian|admin`). Satır, `auth.users` üzerindeki signup trigger'ı ile oluşur. Şimdilik özel JWT claim yok; politikalar tabloyu `security definer` yardımcı fonksiyonlarla okur.
32. Rol **tek ve değişmez** — üç veritabanı mekanizmasıyla zorunlu kılınır: (a) `profiles` üzerinde `UPDATE` yetkisi sadece zararsız kolonlara verilir, `role` API üzerinden hiç güncellenemez; (b) `dietitians`/`clients` composite FK ile `profiles(id, role)`'e bağlıdır; (c) signup trigger'ı istemciden gelen rol metadata'sında sadece `dietitian`'ı kabul eder, gerisini (sahte `admin` dahil) `client`e çevirir.
33. İlk migration kapsamı: iki enum, `profiles`, `dietitians`, `clients`, signup trigger'ı, `is_admin()` ve `is_approved_dietitian()` yardımcıları, `updated_at` trigger'ları, kolon bazlı grant'ler ve tüm RLS politikaları. Başka tablo yok.
34. **Danışan sağlık verisine hiçbir diyetisyen erişemez.** `clients` satırını sadece sahibi ve admin okur. Diyetisyen↔danışan ilişki tablosu Faz 1'de gelene kadar politika yazmak için güvenli bir anahtar yok; erişim o zaman kendi açık politikasıyla eklenir. ⚠️ Sağlık verisini sessizce sızdıracak hata: `clients` üzerine `dietitians` tarzı "authenticated görebilir" politikası kopyalamak.
35. Diyetisyen **kendini onaylayamaz**: `verification_status` kolonu `authenticated` rolüne grant edilmez; onay dashboard veya `service_role` üzerinden yapılır. Uygulama içi admin paneli geldiğinde bilinçli olarak açılır.
36. Migration dosyası hazır: `supabase/migrations/20260828120000_init_identity_and_rls.sql` — §12 adım 3'te yazılır. İskelet diliminde `supabase/` boş kalır (§2.1 #10).

**Durum: §12 adım 3 tamamlandı (28 Ağu 2026)**

- Supabase projesi açıldı: `yangull's Project`, ref **`jpkvulcszsutacritttk`**, region **eu-central-1 (Frankfurt)** — KVKK gereği EU. Postgres 17.6.
- Supabase CLI (v2.116) WSL'e kuruldu (`~/.local/bin/supabase`), hesap `supabase login` ile bağlandı, repo `supabase link` ile projeye bağlandı → `supabase/config.toml` commit'lendi.
- İlk migration **uygulandı**: `supabase migration list` yerel ve uzak tarafta `20260828120000` gösteriyor.
- `env/dev.json` gerçek değerlerle dolduruldu (git'te değil). Anahtar olarak legacy `anon` JWT'si yerine yeni **publishable key** (`sb_publishable_...`) kullanılıyor; ikisi de aynı `anon` Postgres rolüne düşer, legacy anahtarlar zamanla kaldırılacak.
- ⚠️ Yerel Docker stack hâlâ kurulu değil (§2.2 #26): `config.toml` sadece `supabase start` içindir, uzak projeyi etkilemez. Uzak auth ayarları dashboard'dan yönetilir.


---

## 2.3 Kilitlenen Kararlar — Auth & İlk Ekranlar

> 28 Ağustos 2026 beyin fırtınası. Kapsam: §12 adım 2–5.

**Rol ve uygulama ayrımı**

37. **Rol seçimi ekranı yok.** Rol, kayıt olunan uygulamadan gelir: mobil client app her zaman `client`, web panel `role: dietitian` metadata'sı gönderir. Gerekçe: tüketici kayıt hunisinin başındaki rol sorusu dönüşümü düşürür; diyetisyen zaten masabaşında, belge yükleyerek giriyor; signup trigger'ı da zaten `dietitian` dışındaki her şeyi `client`e çeviriyor (§2.2 #32), yani güvenli varsayılan mobil taraf. ⚠️ Bu, §12 adım 4'teki "rol seçimi" ifadesini değiştirir — aynı sonuç, farklı mekanizma.
38. Diyetisyen paneli **sadece web**; mobil diyetisyen deneyimi ertelendi.
39. Ters durumlar gerçek ve ele alınmalı: diyetisyen mobil app'e girerse ve **danışan panele girerse** yönlendirme ekranı görür (tam ekran mesaj + çıkış). Otomatik logout yok — hata gibi görünüyor.
40. Admin MVP'de panelde tek kartlık bir ekran görür: uygulama içi yönetim yok, onaylar Supabase dashboard'undan. Bu bir tasarım tercihi değil, §2.2 #35'in zorunlu sonucu — `authenticated` JWT'sinde `UPDATE(verification_status)` yetkisi yok, yani onay butonu **çalışamaz**.

**Auth davranışı**

41. Kayıt alanları: **e-posta, parola, ad soyad**.
42. Parola minimum **8 karakter**, karmaşıklık kuralı yok. Uzunluk sembol salatasından iyidir; sonradan artırılabilir.
43. **Parola sıfırlama bu dilimde yok.** Gerçek e-posta göndermek özel SMTP gerektiriyor (Supabase'in yerleşik SMTP'si saatte birkaç mailde sınırlı, prodüksiyon için değil). E-posta doğrulama (§2.2 #21) ile birlikte, lansman öncesi SMTP kurulunca gelir.
44. Auth hata mesajları şimdilik **İngilizce** (Supabase'den geldiği gibi). Türkçeleştirme l10n kararıyla birlikte (Açık Soru #12).
45. Giriş sonrası yönlendirmeyi `packages/core` içindeki bir **AuthGate/role router** yapar: `profiles.role` + diyetisyense `verification_status` okunur. Router, loading ve hata durumları kalıcı ürün kodudur.
46. State management detayı: **Riverpod codegen YOK**, elle yazılmış provider'lar. Gerekçe: `build_runner` adımı, framework'ü yeni öğrenirken bozulacak fazladan bir parça; Riverpod da codegen'i tekrar opsiyonel yaptı.

**Dil ve ton**

47. **Uygulama Türkçe.** Tüm UI metinleri Türkçe.
48. **Hitap:** client app'te samimi **"sen"** (Getir/Trendyol normu), diyetisyen panelinde resmî **"siz"**.
49. Danışan için kullanılacak kelime **"danışan"** — "müşteri" değil. Bu doküman ikisini de kullanıyordu; bundan sonra tek terim.

**Ekranlar (ilk milestone)**

50. Her ekranda kural: görünen her şey **gerçek veri veya gerçek aksiyon**. Yapılmamış olan bir kez "Yakında" etiketiyle anılır, asla tıklanabilir sahte UI olarak çizilmez.
51. Danışan ana sayfası: **2 sekmeli** bottom nav (Ana Sayfa, Profil) + gerçek isimle selamlama + iki tıklanamaz kart (diyetisyen yolu / AI yolu). Kartlar ürünün değer önerisini taşıdığı için tutuluyor; sadece selamlama gösteren bir ekran kullanıcıya hiçbir şey öğretmez. Faz 1'de kartların "Yakında" etiketi kalkar ve marketplace'e giriş noktası olurlar.
52. Onay bekleyen diyetisyen: **panel çerçevesi olmadan** tek kart — "Başvurunuz İnceleniyor" + çalışan "Durumu Yenile" butonu. Panel kabuğunun bilinçli olarak gösterilmemesi, onayı gerçek bir kilit açma hissine dönüştürür. `rejected` durumu aynı düzende ele alınır.
53. Onaylı diyetisyen: solda **NavigationRail**, şimdilik 2 hedef (Genel Bakış, Profil) + dürüst boş durum ("Henüz danışanınız yok…"). Faz 1'in danışan listesi tam bu bölüme gelir. Boş rail hedefleri şimdiden eklenmez.

---

## 3. Teknoloji Stack'i (kararlaştırıldı)

| Katman | Seçim | Not |
|---|---|---|
| Müşteri uygulaması | **Flutter** (iOS + Android) | Can'ın biraz Dart geçmişi var |
| Diyetisyen paneli | **Flutter Web** | Ayrı hedef, ortak kod tabanı |
| Backend | **Supabase (EU region)** | Auth, Postgres, Storage, Realtime |
| AI çağrıları | **Supabase Edge Functions** | LLM API key'leri asla client'ta olmaz |
| Ödeme (insan hizmeti) | **iyzico** | Komisyon kesintili marketplace ödemesi |
| Ödeme (AI subscription) | **RevenueCat + in-app purchase** | Apple/Google IAP zorunluluğu için |
| Video | Gömülü video SDK | SDK seçimi henüz yapılmadı (aday: Agora / 100ms / Daily) |

---

## 4. Kullanıcı Akışı (Miro USER FLOW'dan)

```
Kişi kaydoldu
  → Planını seçti
      → Diyetisyen ile ilerleyebilir
      → AI ile ilerleyebilir
      → (Spor PT — İPTAL/askıda, kırmızı kutu)
  → Kan değerlerini ve gerekli testlerini girdi
      (hangi değerlerin isteneceği diyetisyen görüşmelerinde netleşecek)
  → Maddi imkânlarını sıraladı (bütçe filtresi)
  → Yol ayrımı:
      A) Diyetisyen seçip birebir ilerledi → müşteri başına diyetisyenden komisyon
      B) AI ile besin listesi çıkarma + düzenli takip → ay başına subscription
  → Catering paketleri (ileriki faz)
```

## 5. Diyetisyen Tarafı (Miro GENEL MANTIK'tan)

- Diyetisyenler nasıl ekranlar görmek ister → **öğün saatlerinde bilgilendirme**, hangi saatte yenildiği önemli
- **Kan tahlili:** hasta yükleyebilir; ancak diyetisyenler tanı veremiyor, bazı işlemler için **doktor onaylı belge** gerekiyor → ⚠️ regülasyon, görüşmelerde doğrulanacak
- Diyet listesi tarzları öğrenilmeli: Akdeniz, oruç (aralıklı), karb vb.
- Diyet listeleri şu an Excel'den oluşturuluyor (Kutay'ın workflow'u) → uygulamada bunun dijital karşılığı gerekecek
- Diyetisyen tipleri: spor diyetisyeni, hastalığa özgü olanlar (lipödem, diyabet, iğne kullananlar, bariatri)
- **Karar (kırmızı not):** Her diyetisyen tipi için ayrı ekran YOK — genel bir yönetim paneli yeterli
- Müşterilerle birebir görüşülecek panel
- Müşterilerin diyetisyenle konuşmadan soru sorabileceği **AI chatbot** imkânı
- Pazar yeri (marketplace) imkânı

## 6. Müşteri Tarafı Değer Önerisi

- İnsanlara **ucuz ve ulaşılabilir** diyetisyenlik hizmeti
- Diyetisyenle çalışmak istemeyenlere **AI ile diyet oluşturma** (subscription)
- GTM stratejisi: "neden gelsinler?" sorusu hâlâ açık → görüşmelerde ve landing testleriyle netleşecek

---

## 7. MVP Kapsamı (önerilen ilk dilim)

> Amaç: Uçtan uca ÇALIŞAN en küçük akış. Cila yok.

**Faz 0 — Shared Core** *(← BURADAN BAŞLIYORUZ)*
- [x] Monorepo iskeleti kur (aşağıdaki yapı) — kuruldu (§2.1 Durum)
- [x] Supabase projesi aç (EU) + şema taslağı — açıldı, ilk migration uygulandı (§2.2 Durum)
- [ ] Auth: e-posta + parola (Supabase Auth) — telefon/SMS ertelendi, bkz. §2.2 #20
- [ ] Roller: `client`, `dietitian`, `admin`
- [ ] Temel profil modelleri
- [x] Flutter monorepo iskeleti (customer app + dietitian panel, ortak `core` paketi)

**Faz 1 — Diyetisyen Marketplace (insan hizmeti)**
- [ ] Diyetisyen onboarding + doğrulama (diploma/belge yükleme)
- [ ] Müşteri onboarding: hedef, sağlık bilgileri, kan değerleri (opsiyonel), bütçe
- [ ] Diyetisyen listeleme + filtreleme + seçim
- [ ] Uygulama içi chat (Supabase Realtime)
- [ ] Diyet planı: AI taslak (Edge Function) → diyetisyen düzenler/onaylar → müşteri görür
- [ ] iyzico ödeme + komisyon kesintisi
- [ ] Gömülü video görüşme (SDK seçilecek)

**Faz 2 — AI-only Tier**
- [ ] Subscription (RevenueCat + IAP)
- [ ] AI diyet planı üretimi + düzenli takip
- [ ] AI chatbot

**Faz 3+ — İleriki fazlar (şimdilik dokunma)**
- Catering paketleri, yemek kartı entegrasyonu, B2B kurumsal satış
- Spor PT konsepti (henüz keşfedilmedi)
- WhatsApp/Instagram entegrasyonu (otomasyonla, komisyonu koruyacak şekilde — soru işaretli)

---

## 8. Veri Modeli Taslağı (ilk şema fikri — Claude Code'da detaylanacak)

```
users            (id, role, ad, telefon, email, ...)
dietitians       (user_id, uzmanlık[], belge_url, onay_durumu, komisyon_orani?, ...)
clients          (user_id, hedef, bütçe_aralığı, sağlık_notları, ...)
blood_tests      (client_id, dosya_url, değerler_json, doktor_onay_belgesi?, ...)
diet_plans       (client_id, dietitian_id?, kaynak: ai|dietitian, durum: taslak|onaylı, içerik_json)
meals / meal_logs(plan_id, öğün, saat, yenilen, ...)
conversations    (client_id, dietitian_id | ai, ...)
messages         (conversation_id, sender, içerik, ...)
appointments     (client_id, dietitian_id, zaman, video_room_id, durum)
payments         (payer, tutar, komisyon, iyzico_ref, ...)
subscriptions    (client_id, revenuecat_ref, durum, ...)
```

⚠️ Kişisel sağlık verisi barındırıyoruz → **KVKK** uyumu (açık rıza, EU/TR veri lokasyonu, silme hakkı). Supabase EU bu yüzden seçildi; KVKK metinleri için ileride hukuki destek gerekecek.

---

## 9. iOS & Android Deployment Yol Haritası (ilk kez yayınlayanlar için)

**Hesaplar (erkenden aç, onaylar zaman alıyor):**
- [ ] **Apple Developer Program** — $99/yıl. Kayıt + onay birkaç gün sürebilir. Şirket olarak kayıt için D-U-N-S numarası gerekir (bireysel kayıt daha hızlı).
- [ ] **Google Play Console** — $25 tek seferlik. Yeni bireysel hesaplarda Google, prodüksiyona geçmeden önce 14 gün boyunca en az 12 testçiyle kapalı test şartı koyuyor → erken planla.

**Test dağıtımı (store'dan önce):**
- iOS: **TestFlight** (Apple hesabıyla, 100 internal / 10.000 external testçi)
- Android: Play Console **internal testing** track veya direkt APK paylaşımı

**Teknik gereksinimler:**
- ✅ **KARAR: Mac yok → iOS build'leri Codemagic (bulut CI) üzerinden alınacak.** Ücretsiz tier ile başla; TestFlight'a otomatik yükleme destekliyor. Günlük geliştirme Android emulator + Chrome (web) üzerinde yapılır, iOS sadece CI'da build edilir.
- Signing: iOS certificates/provisioning profiles, Android keystore (kaybetme! yedekle!)
- CI/CD önerisi: **Codemagic** (Flutter'a özel, ücretsiz tier var) veya GitHub Actions + Fastlane

**Store'a özel dikkat noktaları:**
- Sağlık verisi topluyoruz → App Store review'da **privacy policy zorunlu**, health data açıklaması gerekir
- AI subscription **mutlaka IAP üzerinden** (Apple/Google kuralı) → RevenueCat bu yüzden var
- İnsan hizmeti ödemesi (diyetisyen seansı) fiziksel dünyada tüketilen hizmet sayılır → **iyzico kullanılabilir**, IAP zorunlu değil (Uber/Airbnb modeli)

---

## 10. Açık Sorular (görüşmelerde / ileride netleşecek)

| # | Soru | Nerede çözülecek |
|---|---|---|
| 1 | Komisyon oranı % kaç? | Diyetisyen görüşmeleri + rakip analizi |
| 2 | AI subscription fiyatı? | Pazar testi |
| 3 | Kan tahlili incelemesi için doktor sevki/onayı hangi durumlarda zorunlu? | ⚠️ Diyetisyen görüşmeleri (CAN yürütüyor) |
| 4 | Hangi kan değerleri istenecek? | Diyetisyen görüşmeleri (Miro'da sarı not) |
| 5 | Video SDK hangisi? | Teknik POC |
| 6 | Spor PT konsepti dahil mi? | Keşfedilmedi, askıda |
| 7 | WhatsApp/IG entegrasyonu — otomasyonla mı, hiç mi? | Komisyon koruması öncelikli |
| 8 | İsim, logo, renk paleti | Daha sonra |
| 9 | "Diyetisyenlik hocaları" iptal fikri neydi? | Can açıklayacak (arşiv) |
| 10 | Excel diyet listesi workflow'unun (Kutay) uygulamadaki karşılığı | Kutay ile detaylandırılacak |
| 11 | ~~State management kütüphanesi hangisi?~~ | ✅ **Riverpod** (28 Ağu 2026, §2.2 #22) |
| 12 | l10n/ARB altyapısı kurulacak mı? | Şimdilik Türkçe metinler hardcode; ikinci bir dil gerçekten gündeme gelirse (retrofit maliyeti kabul edildi) |
| 13 | `client` app'te web hedefi kalacak mı? | Yayından önce |
| 14 | Nihai bundle id / org tanımlayıcı (`com.dietapp` placeholder) | Marka adı belirlenince — **ilk store yüklemesinden önce** |
| 15 | Telefon/SMS OTP hiç eklenecek mi? | Ertelendi — ücretli SMS sağlayıcı gerekiyor (§2.2 #20) |
| 16 | ~~`role` nerede duracak ve tek/değişmez mi?~~ | ✅ `profiles.role`, tek ve değişmez (§2.2 #31–32) |
| 17 | ~~İlk migration'ın kapsamı + RLS duruşu~~ | ✅ Karar verildi (§2.2 #33–36) |
| 18 | Diyetisyen↔danışan ilişki tablosu ve diyetisyenin sağlık verisine erişim politikası | Faz 1 — eşleşme dilimi |
| 19 | Marketplace'te diyetisyenin hangi alanları herkese açık? Doğrulama belgeleri (`certificate_url`) nerede durmalı? | Faz 1 — ilk diyetisyen onaylanmadan ÖNCE (bkz. §2.4) |
| 20 | Reddedilen diyetisyene verilecek destek iletişim kanalı (e-posta?) | Can bilgi verecek |
| 21 | Diyetisyen panelinin yayın adresi / hosting | Deploy dilimi; şimdilik UI'da URL yok |
| 22 | Hesap silme akışı (KVKK silme hakkı + Apple'ın uygulama içi hesap silme şartı) | Lansman öncesi |
| 23 | Fotoğraf kaynağı ve bütçesi. Öneri: **fotoğrafsız başla** — stok fotoğraf stok gibi görünür, YZ üretimi yemek fotoğrafı sahte gelir | Marka çalışmasıyla birlikte |
| 24 | Mobil uygulamanın web önizlemesinde maksimum genişlik sınırı (şu an masaüstünde tam ekrana yayılıyor) | Ekran dilimi |

---

## 2.5 Kilitlenen Kararlar — Tasarım Sistemi

> 28 Ağustos 2026. Tam doküman (canlı örnekler, ölçüm tabloları, anti-slop kuralları):
> https://claude.ai/code/artifact/1d9436dc-cd7c-4639-a4ec-9459de2d8ea3

**Renk**

54. Palet **B "Serin"**: zemin `#F7F9F8`, yüzey `#FFFFFF`, marka `#18795C` (canlı zümrüt). Üç seçenek (sıcak / serin / aydınlık) yan yana üretildi, B seçildi.
55. **Tek marka rengi kuralı.** Arayüzde tek bir marka hue'su vardır; yeşil dışındaki her renk bir anlam taşır (bekliyor / hata / YZ taslağı). Dekoratif ikinci vurgu rengi yoktur.
56. **Ayrı `success` rengi yok.** Planlanan başarı yeşili ile marka yeşili arasındaki kontrast ölçüldüğünde **1.19:1** çıktı — insan gözüne aynı renk. Onaylı durumlar marka yeşilini kullanır.
57. **Yapay zekâ taslağı kendi görsel durumudur:** mor `#514196` + 1.5px kesikli kenarlık + metin etiketi. Mor arayüzde **başka hiçbir yerde** kullanılmaz, böylece mor her zaman "makine üretti, onaylanmadı" demektir. Renk tek başına anlam taşımaz (§2 #1'in görsel karşılığı).
58. Bütün değerler **ölçüldü**, tahmin edilmedi: metin için WCAG AA (4.5:1), etkileşimli sınırlar için WCAG 1.4.11 (3:1). Oranlar `app_colors.dart` içinde her token'ın yanında yazılı. **Bir değeri yeniden ölçmeden değiştirme.**
59. Uygulama **şimdilik yalnızca açık tema**. Koyu palet ölçüldü ve dokümanda duruyor, kodda yok.

**Tipografi**

60. **Fraunces** (başlık) + **Figtree** (gövde/arayüz), ikisi de SIL OFL ve Google Fonts'ta. Serif **sadece** başlıklarda; gövde, tablo ve buton asla serif değil.
61. Türkçe glif kapsaması **font dosyalarının `cmap` tablosu okunarak** doğrulandı (CSS subset beyanına güvenilmedi): 12 kritik glifin tamamı mevcut.
62. **Syne / Satoshi düştü** (§ önceki soyut seçim): referanslarla çelişiyor ve Satoshi Google Fonts'ta değil. "Sharp geometry / hard shadows" yönü de aynı sebeple düştü.
63. ⚠️ `google_fonts` fontları **çalışma zamanında indiriyor**. Yayın öncesi font dosyaları asset olarak paketlenmeli — `app_typography.dart` içinde TODO olarak duruyor.

**Yoğunluk ve mimari**

64. **Tek token seti, iki yoğunluk profili:** `AppDensity.comfortable` (client) ve `AppDensity.compact` (panel). Renkler, font aileleri ve anlamlar **asla** değişmez; sadece boşluk, yarıçap, kontrol yüksekliği ve satır yüksekliği değişir.
65. **`ColorScheme.fromSeed` kullanılmaz.** Tek tohumdan kendi tonal rampalarını üretir ve ölçülen değerleri korumaz; `ColorScheme` her slot açıkça yazılarak kurulur.
66. Material'da karşılığı olmayan tokenlar `AppPalette`, yoğunluk metrikleri `AppDensity` ThemeExtension'ı ile taşınır; `context.palette` / `context.density` ile okunur.
67. Anti-slop kuralları (gradyan yok, emoji ikon yok, "✨ AI destekli" rozeti yok, karışık yarıçap yok, renk tek başına anlam taşımaz, …) yukarıdaki dokümanda 12 madde hâlinde duruyor ve ekran yazarken uyulur.

---

## 2.4 Güvenlik Gözden Geçirmesi — Migration 1 (28 Ağu 2026)

Bağımsız bir inceleme migration 1'i canlı veritabanına karşı denetledi. **Doğru yapılmış olanlar:**
rol değişmezliğinin üç mekanizması da gerçekten yerinde (§2.2 #32); `clients` üzerinde
diyetisyene açılan politika yok, yani §2.2 #34'ün uyardığı sağlık verisi sızıntısı tuzağına
düşülmemiş; her `security definer` fonksiyonda `search_path = ''` var; `(select auth.uid())`
kalıbı tutarlı kullanılmış.

**Bulunan üç açık → migration 2 (`20260828140000`):**

- `profiles.phone` **kolon bazında gizlenemez.** RLS satır filtreler, kolon değil; "onaylı
  diyetisyenleri oku" politikası tüm satırı veriyordu. Telefon numarasının her kullanıcıya
  açık olması §2 #2'ye (iletişim uygulama içinde kalır) doğrudan aykırı. Kolon kullanılmadığı
  ve SMS ertelendiği için politika değil **kolon kaldırıldı**.
- `authenticated` rolünde **`TRUNCATE`** yetkisi duruyordu (Supabase yeni tablolara varsayılan
  `ALL` veriyor). **RLS `TRUNCATE`'e uygulanmaz** — tablo seviyesinde, ya hep ya hiç. PostgREST
  `TRUNCATE` göndermediği için pratikte erişilebilir değildi, ama migration 1'in "iki katman da
  açık" iddiası bu haliyle doğru değildi.
- RLS yardımcı fonksiyonları **PUBLIC'e `EXECUTE`** ile açıktı: `anon`, `/rest/v1/rpc` üzerinden
  `is_approved_dietitian(<uuid>)` çağırıp boolean alabiliyordu.

⚠️ **Kapatılmayan, Faz 1'e bırakılan:** `dietitians.certificate_url` (diploma belgesi) aynı
sebeple her giriş yapmış kullanıcıya açık. Düzeltmesi şema tasarımı gerektiriyor (herkese açık
marketplace alanları ile özel alanları ayırmak) → Açık Soru #19. **İlk diyetisyen onaylanmadan
önce çözülmeli.**

---

## 11. Repo Yapısı (karar: tek monorepo)

En temiz yol: iki uygulama + ortak paket, tek repo. Kod tekrarı yok, tek PR'da her ikisi güncellenir.

```
diyetisyenlik-app/
├── PLANNING.md              ← bu dosya (repo köküne koy)
├── CLAUDE.md                ← Claude Code'un her seansta okuduğu kısa özet
├── .gitignore
├── apps/
│   ├── client/              ← Flutter (android + ios + web*)  *web sadece geliştirme
│   └── dietitian_panel/     ← Flutter Web (diyetisyen paneli)
├── packages/
│   └── core/                ← ortak modeller, Supabase client, auth, tema
├── env/
│   ├── dev.example.json     ← commit'lenir (şablon: hangi anahtarlar gerekiyor)
│   └── dev.json             ← .gitignore'da (gerçek değerler, asla commit'lenmez)
├── supabase/
│   ├── migrations/          ← SQL şema versiyonları
│   └── functions/           ← Edge Functions (AI çağrıları)
├── pubspec.yaml             ← pub workspace kökü (resolution: workspace)
└── melos.yaml               ← Melos 7 script'leri (analyze / format / test)
```

## 12. İlk Claude Code Seansı — Sıra

1. Monorepo iskeletini kur (üstteki yapı, Melos ile)
2. `packages/core`: model taslakları + Supabase client wrapper (henüz bağlanmadan, mock ile)
3. Supabase projesini birlikte aç (EU region) → migration olarak ilk şemayı yaz
4. Auth akışı: kayıt/giriş, rol seçimi (client/dietitian)
5. Her iki app'te "login → boş ana ekran" çalışır hale gelsin → bu ilk milestone

> Codemagic ve store hesapları acil değil — ilk milestone'dan sonra Apple/Google hesaplarını aç (onay süreleri için erken davran, ama kod önce).

## 13. Claude Code Çalışma Kuralları

- **Miro board kaynak-of-truth'tur** (ID: `uXjVH1k8Rq8=`) — ürün kararlarında çelişki varsa board'a bak / Can'a sor.
- Belirsizlikte **varsayma, sor.**
- Türkçe UI metinleri; kod ve commit mesajları İngilizce.
- Bu dosya her seansta güncellenir; büyük kararlar "Kilitlenen Kararlar" bölümüne taşınır.
- Küçük, çalışan dilimler halinde ilerle — büyük big-bang PR yok.
