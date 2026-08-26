# Diyetisyenlik App — Proje Planlama & Context Dosyası

> **Bu dosyanın amacı:** Claude Code ile geliştirmeye başlarken projenin tüm bağlamını tek yerde tutmak.
> Yaşayan bir doküman — her seansta güncellenir, sıfırdan yazılmaz.
> **Durum:** Baseline (v0.1) — 1 günlük beyin fırtınasına dayanıyor, her şey değişebilir.
> **Son güncelleme:** 26 Ağustos 2026 (Faz 0 iskelet grill seansı)

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
- [ ] Monorepo iskeleti kur (aşağıdaki yapı) — İLK ADIM
- [ ] Supabase projesi aç (EU) + şema taslağı — henüz açılmadı, birlikte açılacak
- [ ] Auth: e-posta + telefon (Supabase Auth)
- [ ] Roller: `client`, `dietitian`, `admin`
- [ ] Temel profil modelleri
- [ ] Flutter monorepo iskeleti (customer app + dietitian panel, ortak `core` paketi)

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
| 11 | State management kütüphanesi hangisi (Riverpod / Bloc / …)? | Auth dilimi — ihtiyacı doğuran ilk kod orada |
| 12 | l10n/ARB altyapısı kurulacak mı? | Şimdilik Türkçe metinler hardcode; ikinci bir dil gerçekten gündeme gelirse (retrofit maliyeti kabul edildi) |
| 13 | `client` app'te web hedefi kalacak mı? | Yayından önce |
| 14 | Nihai bundle id / org tanımlayıcı (`com.dietapp` placeholder) | Marka adı belirlenince — **ilk store yüklemesinden önce** |

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
