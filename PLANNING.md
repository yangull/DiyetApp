# Wellkit — Proje Planlama & Context Dosyası

> **Bu dosyanın amacı:** Claude Code ile geliştirmeye başlarken projenin tüm bağlamını tek yerde tutmak.
> Yaşayan bir doküman — her seansta güncellenir, sıfırdan yazılmaz.
> **Durum:** Baseline (v0.1) — 1 günlük beyin fırtınasına dayanıyor, her şey değişebilir.
> **Son güncelleme:** 30 Ağustos 2026 (görüşme öncesi panel hazırlığı, §2.13)

---

## 1. Ürün Özeti

Türkiye pazarı için iki taraflı bir diyetisyen marketplace uygulaması. Ürün adı: **Wellkit**.

**İki kitle:**
- **Diyetisyenler** → yönetim paneli + marketplace'te görünürlük + müşteri kazanımı
- **Müşteriler (danışanlar)** → uygun fiyatlı diyetisyen erişimi VEYA sadece-AI diyet planı

**Gelir modeli (taslak):**
- Diyetisyen-müşteri eşleşmelerinden **komisyon** (oran henüz belirlenmedi)
- AI-only tier için **aylık subscription** (fiyat henüz belirlenmedi)
- İleride B2B: catering firmaları, yemek kartı entegrasyonları, kurumsal satış

**İsim: Wellkit** (28 Ağu 2026'da belirlendi). Renk paleti §2.5'te kilitlendi. Logo henüz yok.
Bundle id: **`com.wellkit.client`** — Açık Soru #14, çözüldü.

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

## 2.6 Araştırma Bulgusu — Diyet Planı Gerçekte Nasıl Kurulur

> 28 Ağustos 2026 araştırma taraması. **Doğrulanmamış hipotez** — diyetisyen
> görüşmelerinde teyit edilecek, tek başına şema değiştirmek için yeterli değil.

Türk diyetisyenler planı "besin + miktar" olarak yazmıyor; **değişim listesi**
kullanıyorlar (ADA exchange system'in Türkçe hâli). Besinler sekiz gruba ayrılır —
**süt, et, nişastalı yiyecekler, kuru baklagil, A grubu sebze, B grubu sebze, meyve,
yağ** — ve bir grubun içindeki her besin, **standart ev ölçüsünde** (yemek kaşığı,
çay bardağı, kibrit kutusu; gram değil) kalori ve makro olarak eşdeğerdir. Plan,
hangi öğünde hangi gruptan **kaç değişim** olduğunu söyler; besin seçimi değişim
listesinden yapılır.

⚠️ **Mevcut prototip modeli bunu taşıyamaz.** `MealItem { food, amount }` yerine
gerçek primitive muhtemelen `(değişimGrubu, adet)` ve her plana ayrı yazılmayan,
**paylaşılan bir değişim tablosu**. Açık Soru #10'un cevabı bu olabilir — ilk
görüşmede doğrudan sorulacak.

**İkinci bulgu — kilitli kararla çelişiyor:** İncelenen tüm Türk diyetisyen
yazılımları hatırlatma ve randevu teyidini **WhatsApp üzerinden** yapıyor
(DiyetBulut bunu açıkça reklam ediyor; ayrıca e-Nabız aktarımı ve dijital onam
formları var). Kilitli karar §2 #2 iletişimin uygulama içinde kalmasını şart koşuyor.
Karar iş modeli açısından doğru, ama rakiplerin tamamı tersini yapıyor çünkü
danışanlar zaten orada. **Gerçek bir benimseme sürtünmesi** — görüşmelerde sorulacak,
Can'a sormadan değiştirilmeyecek.

Uluslararası araçlarda (Nutrium, Practice Better, Healthie, Kahunas) danışan portalı,
randevu, faturalama, mesajlaşma ve form/anamnez **standart**; ama hiçbiri plan
oluşturucuyu çözülmüş saymıyor. Ürünün kazanabileceği yer orası.

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
- [x] Auth: e-posta + parola (Supabase Auth) — telefon/SMS ertelendi, bkz. §2.2 #20 (§2.8, 3. seans)
- [x] Roller: `client`, `dietitian`, `admin` — `client`/`dietitian` uygulamada auth'lu; `admin` MVP'de dashboard'dan (§2.2 #23, değişmedi)
- [x] Temel profil modelleri (§2.8 #73)
- [x] Flutter monorepo iskeleti (customer app + dietitian panel, ortak `core` paketi)

**Faz 1 — Diyetisyen Marketplace (insan hizmeti)**
- [ ] Diyetisyen onboarding + doğrulama (diploma/belge yükleme)
- [~] Müşteri onboarding: hedef, sağlık bilgileri, kan değerleri (opsiyonel), bütçe
      — hedef/bütçe/sağlık notu formu var (§2.12); yapılandırılmış sağlık
      alanları ve kan değerleri yok
- [ ] Diyetisyen listeleme + filtreleme + seçim
      — yerine geçici olarak **e-posta ile davet** akışı var (§2.12); marketplace
      eşleşmesi bunun yerini alacak, tablo `origin` kolonuyla buna hazır
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
| 8 | ~~İsim~~ ✅ **Wellkit**. Logo ve ikon hâlâ açık; renk paleti §2.5'te kilitlendi | Logo: marka çalışması |
| 9 | "Diyetisyenlik hocaları" iptal fikri neydi? | Can açıklayacak (arşiv) |
| 10 | Excel diyet listesi workflow'unun (Kutay) uygulamadaki karşılığı | Kutay ile detaylandırılacak |
| 11 | ~~State management kütüphanesi hangisi?~~ | ✅ **Riverpod** (28 Ağu 2026, §2.2 #22) |
| 12 | l10n/ARB altyapısı kurulacak mı? | Şimdilik Türkçe metinler hardcode; ikinci bir dil gerçekten gündeme gelirse (retrofit maliyeti kabul edildi) |
| 13 | `client` app'te web hedefi kalacak mı? | Yayından önce |
| 14 | ~~Nihai bundle id~~ ✅ **`com.wellkit.client`** (3. seans, 28 Ağustos 2026). Android `applicationId`/`namespace`, Kotlin paketi ve iOS `PRODUCT_BUNDLE_IDENTIFIER` güncellendi. Panel web-only olduğu için bundle id'si yok (§2.3 #38). Kesin olmayan tek şey: Can'ın gerçekten sahip olduğu bir domain'e göre değiştirilebilir, ama şimdilik nihai. | ✅ Çözüldü |
| 15 | Telefon/SMS OTP hiç eklenecek mi? | Ertelendi — ücretli SMS sağlayıcı gerekiyor (§2.2 #20) |
| 16 | ~~`role` nerede duracak ve tek/değişmez mi?~~ | ✅ `profiles.role`, tek ve değişmez (§2.2 #31–32) |
| 17 | ~~İlk migration'ın kapsamı + RLS duruşu~~ | ✅ Karar verildi (§2.2 #33–36) |
| ~~18~~ | ~~Diyetisyen↔danışan ilişki tablosu ve diyetisyenin sağlık verisine erişim politikası~~ | ✅ **Kapandı** — Migration 4, §2.12 |
| ~~19~~ | ~~Marketplace'te diyetisyenin hangi alanları herkese açık?~~ | ✅ **Kapandı** — Migration 3, §2.11 |
| 20 | Reddedilen diyetisyene verilecek destek iletişim kanalı (e-posta?) | Can bilgi verecek |
| 21 | Diyetisyen panelinin yayın adresi / hosting | Deploy dilimi; şimdilik UI'da URL yok |
| 22 | Hesap silme akışı (KVKK silme hakkı + Apple'ın uygulama içi hesap silme şartı) | Lansman öncesi |
| 23 | Fotoğraf kaynağı ve bütçesi. Öneri: **fotoğrafsız başla** — stok fotoğraf stok gibi görünür, YZ üretimi yemek fotoğrafı sahte gelir | Marka çalışmasıyla birlikte |
| 24 | Mobil uygulamanın web önizlemesinde maksimum genişlik sınırı (şu an masaüstünde tam ekrana yayılıyor) | Ekran dilimi |
| 25 | Triage eşikleri: kaç gün tartım yoksa, kaç saat yanıtsız mesaj varsa "geride kalıyor"? | ⚠️ Diyetisyen görüşmeleri (§2.13 #110'daki üç sabit tahmin) |
| 26 | Anamnezde gerçekte hangi sorular soruluyor, ve hangi cevap planı değiştiriyor? | ⚠️ Diyetisyen görüşmeleri (§2.13 #111 — form uydurma) |
| 27 | Kilo dışında hangi ölçümler, hangi cihazla, ne sıklıkla alınıyor? BİA var mı? | ⚠️ Diyetisyen görüşmeleri — cevap `energy.dart`'ın formülünü değiştirebilir (Cunningham) |
| 28 | Seans başına mı, paket (aylık/3 aylık) satışı mı? Gelmeyen danışandan ücret alınıyor mu? | ⚠️ Diyetisyen görüşmeleri — Ödemeler, Randevular ve pazaryeri ilanının üçünü birden etkiliyor |

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
63. ~~⚠️ `google_fonts` fontları çalışma zamanında indiriyor.~~ **Çözüldü (2. seans, 28 Ağustos 2026):** üç font dosyası `packages/core/fonts/` altında asset olarak paketlendi, `google_fonts` bağımlılığı kaldırıldı. Türkçe glif kapsaması dosyalar üzerinden yeniden doğrulandı; bir core testi çözülen font ailesini denetleyerek çalışma zamanı indirmesinin geri gelmediğinden emin oluyor.

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

✅ **28 Ağustos 2026, migration 3 ile kapandı** — bkz. §2.11 #90.

---

## 2.7 İkinci Seans — Panel Sağlamlaştırma (28 Ağustos 2026)

> Aynı gün, HANDOFF.md yazıldıktan sonra. Kapsam: demo panelin güvenilirlik
> açıkları ve kalan yer tutucu ekranlar; veri modeli **bilinçli olarak
> değiştirilmedi** (bkz. §2.6).

68. **Panel verisi artık `localStorage`'a yazılıyor.** Görüşme sırasında sayfa
    yenilenirse diyetisyenin az önce yazdığı değişiklikler kaybolmuyordu — artık
    kaybolmuyor. Tek bir `_changed()` metodu hem durumu kaydediyor hem
    dinleyicileri uyarıyor; `demo_codec.dart` durumu şema sürümlü JSON'a çeviriyor,
    okunamayan/eski veri sessizce seed veriye düşüyor (canlı bir görüşme migration
    hatası ayıklamak için en kötü an).
69. Rayın altına **"Demoyu sıfırla"** butonu eklendi (onay diyaloglu) — görüşmeler
    arası sıfırlama ihtiyacının karşılığı.
70. Danışan detayındaki **"Ölçüm geçmişi: Yakında"** kartı tamamlandı: gerçek kilo
    grafiği, son dört ölçüm, "şu an yalnızca görüntüleniyor" notu. PLANNING §2.3
    #50'nin gerektirdiği son yer tutucu kart buydu.
71. `Appointment.isPast` ve randevu seed verisi **sabit 28 Ağustos 2026 tarihine**
    kilitliydi; görüşme haftalar sonra yapılırsa "yaklaşan randevu" listesi boş ya
    da anlamsız görünecekti. İkisi de `DateTime.now()`'a göre kuruldu.
72. `MacroSummary`'deki ilerleme çubukları **sabit, uydurma doluluk değerleri**
    taşıyordu (her danışan için aynı) ve var olmayan bir hedefin yüzdesi gibi
    sunuluyordu — §2.3 #50'ye ("her şey gerçek veri veya gerçek aksiyon") doğrudan
    aykırıydı. Kaldırıldı; rakamlar kaldı.

Bu seansta **değiştirilmeyenler, bilerek:** `MealItem { food, amount }` modeli
(§2.6'nın konusu — yalnızca bir diyetisyen görüşmesi değiştirebilir),
`packages/core`'un tema dışı hiçbir kısmı, ve auth/Supabase'e dokunan hiçbir şey.

---

## 2.8 Üçüncü Seans — Gerçek Auth ve Domain Katmanı (28 Ağustos 2026)

> Can'ın açık kararıyla: görüşmeler beklenmeden §12 adım 2–5 şimdi kuruldu.
> Gerekçe — bu dilim plan modeli sorusuna (§2.6) bağlı değil; risk düşük ve
> ertelemenin getirisi yok. Panelin danışan yönetimi ve plan editörü hâlâ
> görüşme sonrası bekliyor (bkz. §2.6, §2.7).

**Domain katmanı ve auth (§12 adım 2–4, tamamlandı)**

73. `packages/core/lib/src/auth/` altında soyut `AuthRepository` +
    `ProfileRepository`, her ikisinin Supabase implementasyonu
    (`supabase_flutter` artık `core`'un bağımlılığı — §2.2 #28'in
    öngördüğü adım 3 eşiği bu) ve in-memory sahteleri (`FakeAuthRepository`,
    `FakeProfileRepository`) eklendi. Modeller (`AppProfile`,
    `DietitianDetail`, `ClientDetail`, `UserRole`, `VerificationStatus`)
    migration 1'deki şemayı birebir yansıtıyor.
74. **`AuthGate`** widget'ı §2.3 #45'in tarif ettiği router: oturum akışını,
    profil + detay okumasını, yükleme/hata durumlarını ve ters uygulama
    kontrolünü (§2.3 #39 — yanlış roldeki kullanıcıya tam ekran mesaj +
    çıkış, otomatik logout yok) taşıyor. Hangi diyetisyen durumunun
    (`pending`/`approved`/`rejected`) hangi ekrana gideceğine **karar
    vermiyor** — o dallanma uygulamaya özgü kod olarak kalıyor, `AuthGate`
    sadece kimliği (`AuthedIdentity`) ve eylemleri (`refreshIdentity`,
    `signOut`) sağlıyor.
75. Riverpod provider'ları (`authRepositoryProvider`,
    `profileRepositoryProvider`, `sessionProvider`, `identityProvider`)
    varsayılan olarak gerçek Supabase implementasyonlarına bağlı; testler
    `ProviderScope(overrides: […])` ile sahtelerle değiştiriyor. Codegen yok
    (§2.2 #22'nin devamı).

**Her iki app gerçek auth akışına kavuştu (§12 adım 4–5)**

76. `apps/client`: giriş/kayıt ekranları ("sen" hitabı), gerçek isimle
    selamlayan 2 sekmeli ana ekran (Ana Sayfa/Profil) — kartlar §2.3 #51'in
    gerektirdiği tek "Yakında" etiketini taşıyor, tıklanamıyor.
    `apps/client` artık "temalı yer tutucu" değil.
77. `apps/dietitian_panel`: giriş/kayıt ekranları ("siz" hitabı), onay
    bekleyen/reddedilen için panel çerçevesiz tek kart (§2.3 #52, "Durumu
    Yenile" çalışıyor), onaylı diyetisyen için **2 hedefli** gerçek rail —
    Genel Bakış (dürüst boş durum: "Henüz danışanınız yok") ve Profil
    (§2.3 #53). Bu, demo panelin 5 hedefli rail'inden **kasıtlı olarak
    farklı**.
78. **Demo ile gerçek panel artık iki ayrı giriş noktası.** `lib/main.dart`
    gerçek, auth'lu panel; `lib/main_demo.dart` (yeni) görüşme demosu —
    `PanelShell` + `demo/` sahte verisi, login yok, değişmedi. `flutter run`
    komutu artık hedef belirtmeli:
    `flutter run -t lib/main_demo.dart -d web-server …` görüşme demosu için,
    `flutter run -d web-server …` (varsayılan `lib/main.dart`) gerçek panel
    için. HANDOFF.md güncellendi.
79. Şifre sıfırlama hâlâ yok (§2.2 #21, §2.3 #43 ile tutarlı — bilinçli
    kapsam dışı, unutulmuş değil). Auth hata metinleri hâlâ İngilizce
    (§2.3 #44).
80. `Supabase.initialize` artık `publishableKey:` parametresini kullanıyor,
    `anonKey:` değil — `supabase_flutter` 2.17'de ikincisi deprecated.
    `env/dev.json`'daki `sb_publishable_...` anahtarı zaten bu türdü
    (§2.2 "Durum" notu); sadece client kod tarafı güncellendi.

Bu seansta **değiştirilmeyenler:** migration şeması (auth kodu mevcut
tablolara birebir yazıldı, yeni migration yok), `MealItem` modeli, demo
panelin `lib/demo/` katmanı ve beş hedefli rail'i.

⚠️ **Faz 1 hâlâ yapılmadı.** Onaylı bir diyetisyen gerçek panelde danışan
göremiyor çünkü danışan-diyetisyen eşleştirmesi, `diet_plans` ve ilgili
tablolar henüz yok — bu bilerek böyle (§2.3 #53, boş rail hedefleri
eklenmez). "Tam panel" ancak görüşmelerden gelen plan modeli kararından
sonra anlamlı biçimde inşa edilebilir.

---

## 2.9 Dördüncü Seans — Demo Panelin Genişletilmesi (28 Ağustos 2026)

> Can'ın isteğiyle: gerçek Faz 1 backend'i değil, **görüşme demosuna** (§2.7)
> üç yeni fake-data ekranı eklendi — gösterilecek bir şeyin olması için,
> şema riski almadan. Gerçek backend/entegrasyon işi hâlâ görüşmeleri
> bekliyor (§2.8'in son notu).

81. **Mesajlar** eklendi: danışan başına sohbet geçmişi + gönderme kutusu.
    Kilitli karar §2 #2'nin (iletişim uygulama içinde kalır) somut karşılığı —
    HANDOFF.md §3'ün en çok itiraz beklediğini işaretlediği karar burada
    görüşmede canlı test edilebilir.
82. **Ödemeler** eklendi: brüt kazanç → komisyon → net kazanç dökümü,
    tamamlanan seans başına. Komisyon oranı (`kCommissionRate`, şu an %15)
    kasıtlı olarak bir yer tutucu — Açık Soru #1 hâlâ açık, bu ekran o
    soruyu görüşmede somutlaştırmak için var.
83. Randevular'daki online seanslara **"Görüşmeye başla"** butonu eklendi;
    temsili bir video görüşme ekranı açıyor. Video SDK'sı henüz seçilmedi
    (§3), ekranın kendisi bunu açıkça söylüyor.
84. `demo_codec.dart` şeması **v2**'ye çıktı (`conversations` eklendi).
    `_schemaVersion` bump kuralı (HANDOFF §7) burada uygulandı.

Bu seansta **değiştirilmeyenler:** gerçek Supabase şeması, `MealItem` modeli,
`lib/main.dart`'ın (gerçek panel) auth akışı — sadece `lib/main_demo.dart`
ve `lib/demo/` katmanı büyüdü.

---

## 2.10 Beşinci Seans — Agent Skill Kurulumu ve `demo_codec.dart` Sağlamlaştırması (28 Ağustos 2026)

> Kod değişikliği değil, **süreç ve test** seansı: mattpocock-skills eklentisi
> bu repoya ilk kez bağlandı, ve §2.9'da büyüyen `lib/demo/` katmanının en
> kırılgan köşesi (`demo_codec.dart`) yapılandırılmış bir mimari inceleme +
> "grilling" + bağımsız ikinci görüş akışından geçirildi.

85. **`docs/agents/*.md` + `CLAUDE.md`'de "## Agent skills" bölümü** eklendi
    (`setup-matt-pocock-skills`). Issue tracker: GitHub (`yangull/DiyetApp`).
    Triage etiketleri: varsayılanlar. Domain doküman düzeni: **tek bağlam**
    (`packages/core`, `apps/client`, `apps/dietitian_panel` ayrı Dart
    paketleri olsa da, danışan/diyetisyen/`AuthedIdentity` gibi domain
    kavramları hepsine yayılıyor — pakete göre bölünmüş bir domain değil).
    `CONTEXT.md` ve `docs/adr/` henüz yok; `/domain-modeling` ve
    `/improve-codebase-architecture` bunları terim/karar gerçekten ortaya
    çıktıkça tembel biçimde oluşturacak.
86. **Mimari inceleme** (`/improve-codebase-architecture`), commit geçmişindeki
    en sıcak alan olan `apps/dietitian_panel/lib/demo/`'ya odaklandı. Üç aday
    bulundu; en güçlüsü `demo_codec.dart`'ın `demo_models.dart`'taki her alanı
    elle aynalaması — hiçbir mekanizma ikisini senkron tutmuyor, `HANDOFF.md`
    bunu zaten bir tuzak olarak işaretlemişti.
87. **"Grilling" oturumu** beş kararı sırayla kilitledi: (a) `toJson`/`fromJson`
    modellere taşınsın, ayrı `demo_codec.dart` dosyası kalksın; `build_runner`
    tabanlı codegen hariç (§2.2 #46'nın zaten reddettiği gerekçeyle); (b) kapsam
    sadece `lib/demo/`; (c) `_schemaVersion` tek global int kalsın; (d) her
    model için elle alan-alan karşılaştıran round-trip testi; (e)
    `demo_codec.dart` ince bir dosya olarak kalsın (sürüm kontrolü + hataya
    dayanıklılık), model bazlı serileştirmeyi çağırsın.
88. ⚠️ **Bağımsız bir ikinci görüş (yüksek muhakeme seviyeli ajan) (a) ve
    (d)'yi reddetti — ve haklıydı.** Modele geçici bir zorunlu alan ekleyip
    `dart analyze` çalıştırarak doğruladı: **decode tarafı zaten derleyici
    tarafından zorlanıyor** (kurucular adlandırılmış zorunlu parametre
    alıyor). Gerçek sessiz risk daha dar: **opsiyonel alanlar** ve asla tip
    kontrolünden geçmeyen **encode tarafı** (bir `Map` literal'i). (a) hiçbir
    ek garanti getirmiyordu, sadece aynı elle-senkron sorununu üç dosyaya
    (model + üst-seviye `DemoState` birleştirme + `demo_repository.dart`)
    yayıyordu — üstelik tam da §2.6'nın yeniden yazılması muhtemel dediği
    dosyaya (`demo_models.dart`) dokunarak. (d) da aynı hastalığı üçüncü bir
    elle-tutulan alan listesi olarak yeniden üretiyordu.
89. **Gerçekte uygulanan (ve doğrulanan) çözüm — sıfır üretim kodu
    değişikliği, sadece `test/demo_codec_test.dart`'a iki test:**
    - **Simetri testi**: encode → decode → tekrar encode, birebir eşit mi.
    - **Tamlık testi**: `demo_models.dart`'ın kaynak kodundan alan adlarını
      **çalışma zamanında ayrıştırıp**, encode edilmiş JSON ağacında her
      sınıfın tüm alanlarını taşıyan bir nesne olup olmadığını denetliyor.
      İkinci bir alan listesi yazmıyor — modelin kendisini okuyor.
    Her iki test de modele geçici bir alan eklenerek/encode'dan
    düşürülerek gerçekten kırıldığı doğrulanmış; başarısızlık mesajı
    doğrudan `HANDOFF.md` §7'deki tuzağı ve düzeltmeyi tarif ediyor.
    Sonuç: `dietitian_panel` testleri **10 → 12**, toplam **19**.

⚠️ **Açık kalan, kasıtlı olarak dokunulmayan:** `localStorage` anahtarı
(`wellkit.demo.v1`) ile `_schemaVersion` (`2`) birbirini yansıtmıyor — zararsız,
ama anahtarı değiştirmek canlı bir görüşmedeki state'i sıfırlar, bilerek
dokunulmadı.

---

## 2.11 Altıncı Seans — Güvenlik Düzeltmesi ve Panel Genişlemesi (28 Ağustos 2026)

Yüksek muhakemeli bir ajanın panel özellik-boşluğu incelemesi, "görüşmelerin
cevabından bağımsız olarak şimdi yapılabilir" başlığında dört madde çıkardı;
dördü de bu seansta yapıldı. Görüşmelerin cevabına bağlı olan her şey (plan
modeli yeniden yazımı, AI planlayıcı, şablonlar, PDF çıktısı, anamnez formu)
bilerek yapılmadı.

90. **Açık Soru #19 kapandı — migration 3
    (`20260828200944_dietitians_public_projection.sql`).** RLS satır süzer,
    sütun süzmez: migration 1'in "onaylıysa herkes okur" politikası, onaylı her
    diyetisyenin **tüm satırını** — `certificate_url` dahil — giriş yapmış
    herkese veriyordu. Çözüm iki parçalı: (a) tablo politikası
    `own or admin`'e daraltıldı, (b) marketplace için `security definer` bir
    fonksiyon (`list_approved_dietitians()`) eklendi; `certificate_url` bu
    fonksiyonun **dönüş tipinde hiç yok**, süzülmüyor — yani `where` sonradan
    gevşetilse bile sızamaz. `EXECUTE` yalnızca `authenticated`'a verildi
    (migration 2'nin kalıbı). Uygulama kodunda takip işi yok: bugün başka bir
    diyetisyenin satırını okuyan tek bir çağrı bile yok. ⚠️ Bu fonksiyona sütun
    eklemek bir **yayınlama kararıdır**, refactor değil.
91. **Danışan kaydındaki sağlık bilgisi düzyazıdan alanlara taşındı.**
    `DemoClient`'a `sex`, `activityLevel`, `dietType`, `allergies`,
    `chronicConditions`, `medications` eklendi; bu bilgiler daha önce tek bir
    `note` metninin içine gömülüydü (Elif'in laktoz hassasiyeti, Ahmet'in Tip 2
    diyabeti, Zeynep'in vejetaryenliği). `note` duruyor ama sadece gerçekten
    serbest metin olan kısmı taşıyor — c4'te hiç kalmadı, o yüzden ekranda
    boş "NOT" başlığı görünmesin diye koşullu render var. `dietType` bilinçli
    olarak `String`: gerçek liste bir görüşme cevabı, enum onu öğrenmek için
    değişmek zorunda kalırdı. **Bu seansta sadece görüntüleniyor, düzenlenmiyor**
    — düzenleme UI'ı ayrı bir dilim. `_schemaVersion` → **3**.
92. **Danışan listesine arama + filtre.** İsimle arama, hedefe göre açılır menü,
    plan durumuna göre iki çip (Onay bekleyen / Onaylanan). Filtre durumu
    widget'ın kendi `State`'inde — `DemoState`'e girmiyor, dolayısıyla codec'i ve
    şema sürümünü ilgilendirmiyor. Alt başlıktaki sayı **filtrelenmemiş** toplamı
    göstermeye devam ediyor: filtre bir görüntüleme işi, "kaç aktif danışanım
    var" sorusunun cevabı değil.
93. **Değişim listesi editörü — §2.6 hipotezini sorulabilir olmaktan çıkarıp
    denenebilir hale getiriyor.** `ExchangePlan` / `ExchangeMeal` /
    `ExchangeLine` modelleri ve `screens/exchange_plan_editor_screen.dart`
    eklendi. Grilling kararları: **c1'e (Elif) özel**, ikinci bir "Değişim
    listesiyle dene" düğmesiyle danışan detayından açılıyor (mevcut editör
    hiç değişmedi — yan yana gösterilecekler); değişim sayıları **+/− ile canlı
    düzenlenebilir**; **değişim listesi referans tablosu dahil** (grup başına ev
    ölçüsüyle örnek besinler) çünkü sayılar tek başına bir diyetisyene "değişim
    listesi" gibi görünmez. Günlük kalori **türetiliyor** (`count × grup kcal`),
    her dokunuşta yeniden toplanıyor — mevcut editörün dekoratif makro
    sayılarının aksine. `PlanState` yeniden kullanıldı, yani AI-taslak ve onay
    mekaniği (§2 #1, §2.5 #57) her iki modelde de aynı. `_schemaVersion` → **4**.
95. **Enerji ihtiyacı hesabı — bir diyetisyenin kendi Excel'inden çözüldü.**
    Can, kalori hedefinin nasıl bulunduğunu gösteren bir hesap tablosu
    paylaştı; formüllerin tamamı hücre değerleriyle doğrulanarak çözüldü:
    - **Yetişkin:** Harris-Benedict (orijinal 1919 sabitleri). Tablodaki kadın
      satırı (47 yaş, 70 kg, 158 cm → 1397,11) birebir tutuyor.
    - **Çocuk:** WHO/FAO yaş aralıkları (erkek 0-3 `60,9×kg − 54`, 4-9
      `22,7×kg + 495`, 10-17 `17,5×kg + 651`; kız `61×kg − 51`,
      `22,5×kg + 499`, `12,2×kg + 746`). Altı sarı hücrenin altısı da tam
      tutuyor. **Uygulanmadı** — demo'daki beş danışan da yetişkin; çocuk görüp
      görmedikleri bir görüşme sorusu.
    - **Cunningham:** `500 + 22 × yağsız vücut kütlesi`. **Uygulanmadı** —
      yağsız kütle biyoelektrik impedans istiyor, biz sadece kilo ölçüyoruz.
      Bu da bir görüşme sorusu (Tanita kullanıyor musunuz?).
    - **FA (fiziksel aktivite) katsayısı:** 1,2 – 1,6, BMH ile çarpılıyor.
    `ActivityLevel` bu yüzden **dörtten beşe** çıkarıldı: seviyeler zaten
    katsayı seçmek için var, diyetisyenin kendi aracında beş tane.
    `demo/energy.dart` saf fonksiyon — state yok, codec'e girmiyor, şema
    sürümü değişmedi. `test/energy_test.dart` formülleri **tablonun kendi
    hücrelerine** karşı doğruluyor (panel testleri 12 → 17, toplam 24).
96. **Hesap, elle yazılan kcal alanının yerine geçmedi — yanına kondu.**
    Danışan detayında "Enerji ihtiyacı" kartı zinciri gösteriyor
    (BMH × katsayı = hedef), çünkü katılmayan bir diyetisyenin hangi adımın
    yanlış olduğunu görmesi gerekir. Her iki plan editöründe hedef bir referans
    satırı; serbest editörde alan hâlâ elle düzenlenebilir. **Diyetisyenin bu
    sayıyı ezip geçmesi başlı başına bir sinyal** — sürekli eziyorsa formül
    yanlış. Değişim listesi editöründe artık "planda X / hedef Y" yan yana:
    hedef danışandan, planda ise değişim sayılarından türüyor. Serbest editör
    bu döngüyü kapatamıyor çünkü satırlarında kalori verisi yok — iki model
    arasındaki farkın en somut hâli.
98. **Onaylı plan PDF olarak dışa aktarılıyor.** Diyetisyenin bugün elle
    yaptığı iş: danışana bir liste veriyor. `export/plan_pdf.dart` her iki
    plan modelini de basıyor (değişim listesi sürümü referans tablosunu da
    ekliyor, çünkü sayılar panelden uzakta tek başına işe yaramaz). PDF
    fontları `core`'un paketlenmiş Figtree dosyalarından geliyor — gömülü
    Helvetica'da Türkçe glif yok. `pdf` + `printing` paketleri eklendi.
    ⚠️ **Buton yalnızca onaylı planda açık.** PDF, panelden çıkıp danışana
    ulaşan tek nesne; §2 #1 (danışan onaylanmamış AI planı görmez) bu yüzden
    burada da uygulanıyor, sadece taslağı gösteren arayüzde değil. Model
    sorusundan bağımsız: hangi model kazanırsa kazansın çıktı gerekiyor.
99. **`localStorage` anahtarındaki sürüm kaldırıldı** (`wellkit.demo.v1` →
    `wellkit.demo`). §2.10'da bilinçli bırakılmıştı; sürüm zaten JSON'un
    içinde ve okunamayan state atılıyor, ikinci bir sürüm ya birinciden
    ayrışır ya da her bump'ta bir kayıt öksüz bırakırdı. Görüşmelerden önce
    yapıldı: state'i bir kez daha sıfırlaması artık bedava.
97. ⚠️ **Model kararı verilmedi.** `DietPlan` ve `ExchangePlan` bilerek yan yana
    duruyor. `kExchangeKcal` / `kExchangeFoods` değerleri yayımlanmış ADA
    tablolarından alınmış **örnek** değerler ve ekranda öyle etiketli — amaç
    diyetisyenin onlara güvenmesi değil, düzeltmesi. Referans tabloları `const`
    ve `DemoState` dışında: kimse düzenlemiyor. Diyetisyenin kendi değişim
    listesini düzenlemesine izin verildiği gün state'e taşınmaları gerekecek.

---

## 2.12 Yedinci Seans — Danışan Yönetimi ve İlişki Tablosu (29–30 Ağustos 2026)

Görüşmeler hâlâ yapılmadı. Bu seans bilerek **görüşmelerden bağımsız** olan
dilimi aldı: plan editörü değil, plan editörünün üstüne oturacağı ilişki.
Plan modeli sorusuna (§2.6) hiç dokunulmadı.

100. **Açık Soru #18 kapandı — migration 4
     (`20260829102252_dietitian_client_relationships.sql`).** §2.2 #34'ün
     söz verdiği "kendi açık politikası" yazıldı: `clients` satırını artık
     **aktif ilişkisi olan ve hâlâ onaylı** bir diyetisyen de okuyabiliyor.
     `is_approved_dietitian` koşulu kasıtlı — onayı sonradan kaldırılan bir
     diyetisyen eski eşleşmelerine de erişemez.
101. **Bağlantı modeli: e-posta ile davet.** Diyetisyen davet eder, danışan
     kendi uygulamasından kabul veya reddeder. Marketplace eşleşmesi
     (§7 Faz 1) daha büyük bir dilim; bu onun geçici yerine geçiyor.
     `origin` kolonu (`dietitian_invite` | ileride `client_request`) o akış
     geldiğinde bu satırların yeniden yorumlanmasını gerektirmesin diye var.
102. **Davet/kabul yetkisi JWT'nin `email` claim'ine dayanıyor.** Kabul ve
     ret politikaları `lower(invited_email) = lower(auth.jwt() ->> 'email')`
     karşılaştırması yapıyor. ⚠️ **Bu, Supabase'de e-posta doğrulamasının
     açık olmasına bağlı** — kapalıysa biri başkasının adresiyle kayıt olup
     davetini üstlenebilir. Dashboard ayarı, kod değil.
103. **Danışan adları politika ile değil, projeksiyon ile okunuyor.**
     `list_my_clients()` (`security definer`), tıpkı `list_approved_dietitians()`
     gibi. `profiles` üzerine düz bir SELECT politikası yazılsaydı tabloya
     ileride eklenen **her** kolon eşleşmiş diyetisyenlere otomatik açılırdı —
     migration 2 ve 3'ün `dietitians` üzerinde kapattığı sızıntı şekli. Ayrıca
     liste tek çağrıda geliyor, danışan başına bir istek değil.
104. **Danışan artık kendi verisini yazabiliyor.** `ProfileRepository`'ye
     `updateClientDetail` eklendi ve client app'in Profil sekmesine küçük bir
     "Hedeflerim" formu (hedef / bütçe / sağlık notu) kondu. Bunsuz panelin
     yeni danışan detay ekranı **her gerçek kullanıcı için boş** olurdu:
     migration 1'den beri bu üç kolonu yazan hiçbir şey yoktu. Bunu bağımsız
     bir Opus incelemesi yakaladı, planın ilk hâlinde yoktu.
105. **Davet kartı daveti göndereni adıyla gösteriyor**, `invited_email`'i
     değil — o adres zaten danışanın kendi adresi. Karşı taraf kendi sağlık
     verisine erişim izni veriyor; kimin istediği kartta yazmak zorunda
     (KVKK açık rıza mantığı). Diyetisyenin adı kabul öncesi de okunabiliyor,
     çünkü migration 1'in "profiles: read approved dietitians" politikası
     yürürlükte ve davet insert'ü zaten onaylı diyetisyen şartı koşuyor.
106. **Kapsam dışı bırakılanlar** (bilerek, eksik değil): ilişkiyi sonlandırma,
     `clients` tablosuna demo'daki yapılandırılmış sağlık alanları (yaş, kilo,
     aktivite, alerjiler) ve davet e-postasının **gerçekten gönderilmesi**.
     Sonuncusu arayüzde açıkça yazıyor: davet, danışan aynı e-posta ile kayıt
     olup uygulamayı açtığında görünüyor. Gerçek gönderim (Edge Function +
     `inviteUserByEmail`) sonraki iş.
107. Not: `relationship_status` enum'ı `declined`'ı **şimdi** içeriyor. İleride
     `ended` eklenecekse, `alter type ... add value` ile aynı transaction'da o
     etikete referans veren politika yazılamaz — ya iki migration'a bölünür ya
     da kolon `text` + check constraint'e çevrilir.

---

## 2.13 Sekizinci Seans — Görüşme Öncesi Panel Hazırlığı (30 Ağustos 2026)

Görüşmeler hâlâ yapılmadı ama **tarih yaklaştı**. Bu seansın tetikleyicisi Can'ın
paneli projeyi hiç bilmeyen bağımsız bir ajana eleştirtmesi oldu. Eleştirinin
öncülü doğruydu, madde listesi büyük ölçüde yanlıştı — ve bu ayrımın kendisi
bulgu oldu.

108. **Eleştirinin altı "P0"undan dördü zaten yapılmıştı; ajan onları
     göremediği için yok sandı.** Danışan kartı (`client_detail_screen.dart`),
     iki plan editörü, AI'ın gerekçesini gösteren `AiDraftBanner`, enerji
     hesabı — hepsi vardı. **Sebep gerçek bir hataydı:** Genel Bakış'taki
     "İncele" düğmesi `onOpenClients` çağırıyor, yani danışan *listesine*
     gidiyordu. Ürünün üzerine kurulduğu ekran, ana ekrandan erişilemiyordu.
     Ders: bir ekranın var olması yeterli değil, ana ekrandan bir tıkla
     ulaşılabilir olmalı — yoksa yok sayılıyor.
109. **"7 günlük plan tablosu" bilerek yapılmadı.** Eleştirinin en büyük
     talebiydi ama "besin + miktar" modelini varsayıyor; §2.6'daki değişim
     listesi hipotezi doğruysa haftalık tablo yanlış şekil. Görüşmede
     sorulacak, kod yazılmayacak. (Bu, tek cümlelik bir soruyu bir günlük
     işle cevaplama tuzağının somut örneği.)
110. **Genel Bakış'a "Dikkat gerekenler" listesi eklendi** (`demo/triage.dart`).
     Üç sinyal: 7 gündür tartım yok, 24 saattir yanıtsız mesaj, randevuya
     gelmedi. Üç eşik de **isimlendirilmiş sabit** ve ekranda "bu bizim
     tahminimiz" yazıyor — amaç doğru olmak değil, diyetisyene düzelttirmek.
     Onay bekleyen planlar bu listeye **girmiyor**: kendi satırları ve kendi
     bekleme rozetleri var, aynı danışanın tek ekranda iki kez çıkması hata
     gibi okunuyor.
111. **Anamnez formu eklendi** (`intake_form_screen.dart`, "Danışan ekle").
     Üst yarısı gerçek `DemoClient` alanları; alt yarısındaki dokuz soru
     (öğün düzeni, su, uyku, sigara/alkol, bağırsak düzeni, ailede hastalık,
     önceki diyetler, sevmediği besinler, tahlil) **hiçbir modelde yok** ve
     `note`'a metin olarak yazılıyor. Bu bilerek: formu üstüne kalem
     gezdirilsin diye yaptık. Kaydedince hesaplanan enerji hedefiyle bir AI
     taslağı üretiliyor — "anamnezi doldurdum, plan çıktı" iddiası görüşmede
     anlatılmak yerine gösterilebilsin diye.
112. **Hedefe duyarlı değerlendirme** (`demo/progress.dart`). Panel eskiden
     her kilo düşüşünü aynı gösteriyordu. Artık yön, hedef kilonun başlangıç
     kilosuna göre konumundan çıkarılıyor (hedef *metni*nden değil — o
     serbest metin), ve kilo koruma hedefindeki bir danışanın düşüşü
     "hedef aralığının dışında" olarak uyarı rengiyle çıkıyor. Hedef kilosu
     olmayan danışana (sporcu beslenmesi) **hiç yargı verilmiyor**.
113. **Vücut ölçümleri eklendi** (`BodyMeasurement`): bel, kalça, bel/kalça
     oranı, yağ yüzdesi, kas kütlesi, bir önceki seansa göre değişimiyle.
     Beş danışanın üçünde var — herkeste olmaması da konuşma malzemesi.
     Ekran metni açıkça soruyor: hangi cihaz, hangi sıklık. Yağsız vücut
     kütlesi ölçülüyorsa `energy.dart` Cunningham'a geçebilir.
114. **`AppointmentStatus.noShow` eklendi**, `cancelled`'dan ayrı. Gerekçe
     çift: triage sinyalinin işaret ettiği kayıt hiçbir ekranda görünmüyordu
     (bu yüzden "Geçmiş randevular" bölümü eklendi), ve "gelmedi" ile "iptal
     edildi" ücrete farklı etki edebilir. Şu anki varsayım — gelmeyen seans
     tahsil edilecekler listesine girmiyor — ekranda soru olarak yazılı.
115. **Storage şeması v5.** `targetWeightKg`, `measurements`, her iki plan
     tipinde `draftedAt`. Tohum veriler artık `DateTime.now()`'a bağlı:
     kilo serileri Haziran 2026'ya sabitlenmişti ve `weight_chart.dart`
     ekseninde **'Haz' / 'Ağu' etiketleri elle yazılıydı** — takvim ilerledikçe
     sessizce yanlışa dönecek bir hata.
116. **Ekran görüntüleri artık `flutter test` ile üretiliyor**
     (`test/screenshots_test.dart`, golden dosyalar). Tarayıcı otomasyonu yok;
     test gerçek demoyu sürüyor, sekmeleri geziyor ve 12 PNG yazıyor. Etiketli
     olduğu için normal `melos run test` çalıştırmasında **atlanıyor** —
     bunlar regresyon golden'ı değil, istendiğinde alınan çıktı.
117. **Bu görüntüleme turu üç gerçek hatayı ortaya çıkardı** — hiçbiri normal
     kullanımda görünmüyordu:
     - `AppBarTheme.titleTextStyle` renksizdi. Bu stili vermek
       `foregroundColor`'ın başlığa ulaşmasını engelliyor, dolayısıyla
       **push edilen her ekranın başlığı** (danışan kartı, plan editörü,
       anamnez formu) zeminde neredeyse görünmezdi.
     - `AppTypography.textTheme` **`labelMedium` slotunu hiç doldurmuyordu** —
       NavigationRail etiketlerinin kullandığı slot. Her iki uygulamanın sol
       menüsü Figtree değil Roboto ile çiziliyordu.
     - Anamnez formunda `_field` `Expanded` döndürüyordu; Column içine
       doğrudan konulunca bu **çökme** demek. Flex artık `_row`'da.
118. **Sunum artefaktı üretildi** (Claude Artifact, TR/EN seçicili): on iki
     ekran, her birinin altında görüşmede sorulacak açık soru. Bilerek
     "ürün tanıtımı" değil — HANDOFF §1'in "bu bir satış demosu değil"
     kuralı burada da geçerli: cilalı bir sunum diyetisyeni düzeltmek yerine
     beğenmeye iter. Anamnez sorularının uydurma, komisyonun yer tutucu ve
     değişim değerlerinin örnek olduğu artefaktta açıkça yazıyor.

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

✅ **1–5 tamamlandı (3. seans, 28 Ağustos 2026, §2.8).** İlk milestone'a
ulaşıldı: her iki app gerçek Supabase auth'una bağlı, login sonrası her
biri kendi "boş ana ekranına" düşüyor (client: 2 sekmeli Ana Sayfa/Profil;
panel: onay durumuna göre bekleme ekranı ya da 2 hedefli rail). Sıradaki
gerçek adım Faz 1 — bkz. §7.

> Codemagic ve store hesapları acil değil — ilk milestone'dan sonra Apple/Google hesaplarını aç (onay süreleri için erken davran, ama kod önce).

## 13. Claude Code Çalışma Kuralları

- **Miro board kaynak-of-truth'tur** (ID: `uXjVH1k8Rq8=`) — ürün kararlarında çelişki varsa board'a bak / Can'a sor.
- Belirsizlikte **varsayma, sor.**
- Türkçe UI metinleri; kod ve commit mesajları İngilizce.
- Bu dosya her seansta güncellenir; büyük kararlar "Kilitlenen Kararlar" bölümüne taşınır.
- Küçük, çalışan dilimler halinde ilerle — büyük big-bang PR yok.
