import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_codec.dart';
import 'demo_models.dart';
import 'demo_store.dart';
import 'energy.dart';

/// The platform's cut of every human-dietitian session, per PLANNING.md §2
/// #3 (commission-based revenue). Open Question #1 — the real rate is still
/// unset — so this number is itself a conversation piece for the Ödemeler
/// screen, not a decision.
const kCommissionRate = 0.15;

/// Local data for the discovery prototype. No Supabase, no network: the panel
/// is driven live in front of a dietitian, and everything they change is
/// mirrored into browser storage so a reload does not wipe the conversation.
class DemoState {
  DemoState({
    required this.clients,
    required this.plans,
    required this.exchangePlans,
    required this.appointments,
    required this.weights,
    required this.measurements,
    required this.macros,
    required this.reminders,
    required this.conversations,
  });

  final List<DemoClient> clients;
  final List<DietPlan> plans;

  /// The same days as [plans], counted as exchanges instead. Seeded for one
  /// client only: this is an interview instrument, not a second product.
  final List<ExchangePlan> exchangePlans;
  final List<Appointment> appointments;
  final Map<String, List<WeightEntry>> weights;

  /// Everything taken at a session that is not the scale. Seeded for three
  /// clients only — not every dietitian measures every client, and the gaps
  /// are as much a conversation piece as the readings.
  final Map<String, List<BodyMeasurement>> measurements;
  final Map<String, Macros> macros;
  final ReminderSettings reminders;
  final List<Conversation> conversations;

  List<Appointment> get upcoming =>
      appointments.where((a) => !a.isPast).toList()
        ..sort((a, b) => a.at.compareTo(b.at));

  List<Appointment> get completed =>
      appointments.where((a) => a.isPast && _billable(a)).toList()
        ..sort((a, b) => b.at.compareTo(a.at));

  /// Whether a session that already happened is one the dietitian earns from.
  /// A no-show is excluded alongside a cancellation, which is a guess: whether
  /// you charge for a no-show is Open Question territory, not a decision.
  static bool _billable(Appointment a) =>
      a.status != AppointmentStatus.cancelled &&
      a.status != AppointmentStatus.noShow;

  List<Appointment> get unpaid =>
      appointments.where((a) => a.isPast && !a.paid && _billable(a)).toList();

  int get unpaidCount => unpaid.length;

  int get unpaidTotal => unpaid.fold(0, (sum, a) => sum + a.fee);

  List<BodyMeasurement> measurementsOf(String clientId) =>
      measurements[clientId] ?? const [];

  int get grossEarnings => completed.fold(0, (sum, a) => sum + a.fee);

  int get commissionTotal => (grossEarnings * kCommissionRate).round();

  int get netEarnings => grossEarnings - commissionTotal;

  DemoClient clientOf(String id) => clients.firstWhere((c) => c.id == id);

  DietPlan planFor(String clientId) =>
      plans.firstWhere((p) => p.clientId == clientId);

  /// Null for every client without an exchange-list version of their plan.
  ExchangePlan? exchangePlanFor(String clientId) {
    for (final plan in exchangePlans) {
      if (plan.clientId == clientId) return plan;
    }
    return null;
  }

  Conversation conversationOf(String clientId) =>
      conversations.firstWhere((c) => c.clientId == clientId);

  int get draftCount => plans.where((p) => p.isDraft).length;

  int get unreadConversationCount =>
      conversations.where((c) => c.hasUnread).length;
}

class DemoNotifier extends Notifier<DemoState> {
  static const _store = DemoStore();

  @override
  DemoState build() {
    final stored = _store.read();
    if (stored == null) return _seedState();

    final restored = decodeDemoState(stored);
    if (restored == null) {
      // Unreadable leftovers from an older build: drop them rather than let
      // them fail again on the next load.
      _store.clear();
      return _seedState();
    }
    return restored;
  }

  /// Back to the seed data — the between-interviews button.
  void resetDemo() {
    _store.clear();
    state = _seedState();
  }

  /// Every mutator edits the objects in place, so listeners need waking by
  /// hand; storage is written from the same place so the two cannot drift.
  void _changed() {
    _store.write(encodeDemoState(state));
    ref.notifyListeners();
  }

  void sendReminder(String appointmentId) {
    _appointment(appointmentId).status = AppointmentStatus.reminderSent;
    _changed();
  }

  void cancelAppointment(String appointmentId) {
    _appointment(appointmentId).status = AppointmentStatus.cancelled;
    _changed();
  }

  void markPaid(String appointmentId) {
    _appointment(appointmentId).paid = true;
    _changed();
  }

  void toggleReminder(String which, bool value) {
    final r = state.reminders;
    switch (which) {
      case 'dayBefore':
        r.dayBefore = value;
      case 'hoursBefore':
        r.hoursBefore = value;
      case 'payment':
        r.paymentReminder = value;
    }
    _changed();
  }

  void setChannel(String channel) {
    state.reminders.channel = channel;
    _changed();
  }

  Appointment _appointment(String id) =>
      state.appointments.firstWhere((a) => a.id == id);

  void approve(String clientId) {
    state.planFor(clientId).state = PlanState.approved;
    _changed();
  }

  void editItem(
    String clientId,
    int mealIndex,
    int itemIndex,
    String food,
    String amount,
  ) {
    final item = state.planFor(clientId).meals[mealIndex].items[itemIndex];
    item.food = food;
    item.amount = amount;
    _changed();
  }

  void removeItem(String clientId, int mealIndex, int itemIndex) {
    state.planFor(clientId).meals[mealIndex].items.removeAt(itemIndex);
    _changed();
  }

  void addItem(String clientId, int mealIndex) {
    state
        .planFor(clientId)
        .meals[mealIndex]
        .items
        .add(MealItem(food: '', amount: ''));
    _changed();
  }

  void setMealTime(String clientId, int mealIndex, String time) {
    state.planFor(clientId).meals[mealIndex].time = time;
    _changed();
  }

  void setKcal(String clientId, int kcal) {
    state.planFor(clientId).kcal = kcal;
    _changed();
  }

  void setExchangeCount(
    String clientId,
    int mealIndex,
    int lineIndex,
    int count,
  ) {
    final plan = state.exchangePlanFor(clientId);
    if (plan == null) return;
    plan.meals[mealIndex].lines[lineIndex].count = count.clamp(0, 20);
    _changed();
  }

  void approveExchangePlan(String clientId) {
    final plan = state.exchangePlanFor(clientId);
    if (plan == null) return;
    plan.state = PlanState.approved;
    _changed();
  }

  /// The intake form's only job. Everything the panel needs for a client is
  /// created here in one go — including a first AI draft, because "I filled in
  /// the anamnez and a plan appeared" is the claim the product is making and
  /// an interview should get to react to it rather than hear it described.
  void addClient(DemoClient client) {
    final kcal = targetEnergy(client);
    state.clients.add(client);
    state.plans.add(
      DietPlan(
        clientId: client.id,
        day: 'Pazartesi',
        kcal: kcal,
        state: PlanState.aiDraft,
        draftedAt: DateTime.now(),
        aiNote:
            'Anamnez formundaki bilgilerden üretilen ilk taslak. Hedef '
            'enerji $kcal kcal olarak hesaplandı; öğün dağılımını ve '
            'besinleri onaylamadan önce düzenleyebilirsiniz.',
        meals: _standardDay(),
      ),
    );
    state.weights[client.id] = [WeightEntry(DateTime.now(), client.weightKg)];
    state.macros[client.id] = Macros(
      proteinG: (kcal * 0.25 / 4).round(),
      carbG: (kcal * 0.45 / 4).round(),
      fatG: (kcal * 0.30 / 9).round(),
    );
    state.conversations.add(Conversation(clientId: client.id, messages: []));
    _changed();
  }

  void markNoShow(String appointmentId) {
    _appointment(appointmentId).status = AppointmentStatus.noShow;
    _changed();
  }

  void sendMessage(String clientId, String text) {
    if (text.trim().isEmpty) return;
    state
        .conversationOf(clientId)
        .messages
        .add(
          ChatMessage(
            id: 'm${DateTime.now().microsecondsSinceEpoch}',
            sender: MessageSender.dietitian,
            text: text.trim(),
            sentAt: DateTime.now(),
          ),
        );
    _changed();
  }
}

final demoProvider = NotifierProvider<DemoNotifier, DemoState>(
  DemoNotifier.new,
);

/// Seeds are built fresh on every call: the objects are mutable and a reset
/// that handed back the same instances would hand back the edits too.
DemoState _seedState() => DemoState(
  clients: _seedClients(),
  plans: _seedPlans(),
  exchangePlans: _seedExchangePlans(),
  appointments: _seedAppointments(),
  weights: _seedWeights(),
  measurements: _seedMeasurements(),
  macros: _seedMacros(),
  reminders: ReminderSettings(
    dayBefore: true,
    hoursBefore: true,
    paymentReminder: false,
    channel: 'push',
  ),
  conversations: _seedConversations(),
);

// The health facts below used to sit inside `note` as prose. They are seeded
// as fields now so the list can filter on them and a plan can be checked
// against them; `note` keeps only what stayed genuinely free-form.
List<DemoClient> _seedClients() => [
  DemoClient(
    id: 'c1',
    name: 'Elif Aydın',
    age: 34,
    sex: Sex.kadin,
    heightCm: 165,
    weightKg: 72.4,
    goal: 'Kilo verme',
    targetWeightKg: 65.0,
    activityLevel: ActivityLevel.ortaAktif,
    dietType: 'standart',
    allergies: ['Laktoz'],
    chronicConditions: [],
    medications: [],
    note: 'Ofiste çalışıyor, öğle yemeğini dışarıda yiyor.',
    startedOn: DateTime(2026, 7, 14),
  ),
  DemoClient(
    id: 'c2',
    name: 'Merve Yılmaz',
    age: 28,
    sex: Sex.kadin,
    heightCm: 171,
    weightKg: 63.0,
    goal: 'Sporcu beslenmesi',
    targetWeightKg: null,
    activityLevel: ActivityLevel.cokAktif,
    dietType: 'standart',
    allergies: [],
    chronicConditions: [],
    medications: [],
    note: 'Haftada 4 gün antrenman. Akşam geç saatte acıkıyor.',
    startedOn: DateTime(2026, 8, 2),
  ),
  DemoClient(
    id: 'c3',
    name: 'Ahmet Demir',
    age: 45,
    sex: Sex.erkek,
    heightCm: 178,
    weightKg: 94.8,
    goal: 'Tip 2 diyabet yönetimi',
    targetWeightKg: 85.0,
    activityLevel: ActivityLevel.sedanter,
    dietType: 'standart',
    allergies: [],
    chronicConditions: ['Tip 2 diyabet'],
    medications: ['Metformin'],
    note: 'Doktor takibinde. Kan değerleri her ay güncelleniyor.',
    startedOn: DateTime(2026, 6, 21),
  ),
  DemoClient(
    id: 'c4',
    name: 'Zeynep Kaya',
    age: 31,
    sex: Sex.kadin,
    heightCm: 160,
    weightKg: 58.2,
    goal: 'Kilo koruma',
    targetWeightKg: 58.0,
    activityLevel: ActivityLevel.ortaAktif,
    dietType: 'vejetaryen',
    allergies: [],
    chronicConditions: [],
    medications: ['Demir takviyesi'],
    note: '',
    startedOn: DateTime(2026, 8, 11),
  ),
  DemoClient(
    id: 'c5',
    name: 'Burak Şahin',
    age: 39,
    sex: Sex.erkek,
    heightCm: 183,
    weightKg: 88.1,
    goal: 'Kilo verme',
    targetWeightKg: 80.0,
    activityLevel: ActivityLevel.hafifAktif,
    dietType: 'standart',
    allergies: [],
    chronicConditions: [],
    medications: [],
    note: 'Vardiyalı çalışıyor, öğün saatleri düzensiz.',
    startedOn: DateTime(2026, 5, 30),
  ),
];

// Elif's day, counted as exchanges instead of written out, so the two editors
// can be put side by side in an interview. Adds up to roughly her 1600 kcal.
// Only c1: the point is to show the model, not to maintain it five times.
List<ExchangePlan> _seedExchangePlans() => [
  ExchangePlan(
    clientId: 'c1',
    day: 'Pazartesi',
    state: PlanState.aiDraft,
    draftedAt: _daysAgo(3),
    aiNote:
        'Aynı gün, değişim listesiyle kurulmuş hâli. Grup değerleri örnektir; '
        'sizin kullandığınız tabloyu öğrenmek istiyoruz.',
    meals: [
      ExchangeMeal(
        name: 'Kahvaltı',
        time: '08:00',
        lines: [
          ExchangeLine(group: ExchangeGroup.et, count: 1),
          ExchangeLine(group: ExchangeGroup.nisasta, count: 2),
          ExchangeLine(group: ExchangeGroup.sebzeA, count: 1),
          ExchangeLine(group: ExchangeGroup.yag, count: 1),
        ],
      ),
      ExchangeMeal(
        name: 'Ara Öğün',
        time: '11:00',
        lines: [
          ExchangeLine(group: ExchangeGroup.meyve, count: 1),
          ExchangeLine(group: ExchangeGroup.yag, count: 1),
        ],
      ),
      ExchangeMeal(
        name: 'Öğle Yemeği',
        time: '13:00',
        lines: [
          ExchangeLine(group: ExchangeGroup.et, count: 2),
          ExchangeLine(group: ExchangeGroup.nisasta, count: 2),
          ExchangeLine(group: ExchangeGroup.sebzeA, count: 2),
          ExchangeLine(group: ExchangeGroup.yag, count: 1),
        ],
      ),
      ExchangeMeal(
        name: 'İkindi',
        time: '16:30',
        lines: [
          ExchangeLine(group: ExchangeGroup.meyve, count: 1),
          ExchangeLine(group: ExchangeGroup.sut, count: 1),
        ],
      ),
      ExchangeMeal(
        name: 'Akşam Yemeği',
        time: '19:30',
        lines: [
          ExchangeLine(group: ExchangeGroup.et, count: 2),
          ExchangeLine(group: ExchangeGroup.baklagil, count: 1),
          ExchangeLine(group: ExchangeGroup.sebzeA, count: 2),
          ExchangeLine(group: ExchangeGroup.yag, count: 1),
        ],
      ),
      ExchangeMeal(
        name: 'Gece',
        time: '22:00',
        lines: [ExchangeLine(group: ExchangeGroup.sut, count: 1)],
      ),
    ],
  ),
];

List<Meal> _standardDay() => [
  Meal(
    name: 'Kahvaltı',
    time: '08:00',
    items: [
      MealItem(food: 'Yumurta (haşlanmış)', amount: '2 adet'),
      MealItem(food: 'Tam buğday ekmeği', amount: '2 ince dilim'),
      MealItem(food: 'Beyaz peynir', amount: '1 kibrit kutusu'),
      MealItem(food: 'Domates, salatalık, yeşillik', amount: 'serbest'),
    ],
  ),
  Meal(
    name: 'Ara Öğün',
    time: '11:00',
    items: [
      MealItem(food: 'Elma', amount: '1 orta boy'),
      MealItem(food: 'Çiğ badem', amount: '10 adet'),
    ],
  ),
  Meal(
    name: 'Öğle Yemeği',
    time: '13:00',
    items: [
      MealItem(food: 'Izgara tavuk göğsü', amount: '120 g'),
      MealItem(food: 'Bulgur pilavı', amount: '4 yemek kaşığı'),
      MealItem(food: 'Mevsim salata (1 tk zeytinyağı)', amount: '1 porsiyon'),
      MealItem(food: 'Yoğurt', amount: '1 kase'),
    ],
  ),
  Meal(
    name: 'İkindi',
    time: '16:30',
    items: [
      MealItem(food: 'Kefir', amount: '1 su bardağı'),
      MealItem(food: 'Kuru kayısı', amount: '3 adet'),
    ],
  ),
  Meal(
    name: 'Akşam Yemeği',
    time: '19:30',
    items: [
      MealItem(food: 'Zeytinyağlı sebze yemeği', amount: '1 porsiyon'),
      MealItem(food: 'Mercimek çorbası', amount: '1 kase'),
      MealItem(food: 'Tam buğday ekmeği', amount: '1 ince dilim'),
    ],
  ),
  Meal(
    name: 'Gece',
    time: '22:00',
    items: [MealItem(food: 'Süt (laktozsuz)', amount: '1 su bardağı')],
  ),
];

/// Draft ages are staggered so the waiting badge on Genel Bakış has a range
/// to show rather than one value: Elif's has been sitting for three days.
DateTime _daysAgo(int days) => DateTime.now().subtract(Duration(days: days));

DateTime _hoursAgo(int hours) =>
    DateTime.now().subtract(Duration(hours: hours));

List<DietPlan> _seedPlans() => [
  DietPlan(
    clientId: 'c1',
    day: 'Pazartesi',
    kcal: 1600,
    state: PlanState.aiDraft,
    draftedAt: _daysAgo(3),
    aiNote:
        'Laktoz hassasiyeti nedeniyle süt ürünleri laktozsuz seçildi; '
        'öğle öğünü dışarıda yenmeye uygun olacak şekilde sadeleştirildi.',
    meals: _standardDay(),
  ),
  DietPlan(
    clientId: 'c2',
    day: 'Pazartesi',
    kcal: 2200,
    state: PlanState.aiDraft,
    draftedAt: _hoursAgo(6),
    aiNote: 'Antrenman günleri için karbonhidrat öğün öncesine kaydırıldı.',
    meals: _standardDay(),
  ),
  DietPlan(
    clientId: 'c3',
    day: 'Pazartesi',
    kcal: 1800,
    state: PlanState.approved,
    draftedAt: _daysAgo(10),
    meals: _standardDay(),
  ),
  DietPlan(
    clientId: 'c4',
    day: 'Pazartesi',
    kcal: 1700,
    state: PlanState.aiDraft,
    draftedAt: _hoursAgo(26),
    aiNote:
        'Vejetaryen; protein kaynakları baklagil ve süt ürünlerinden '
        'kuruldu. Demir emilimi için C vitamini eşliği önerildi.',
    meals: _standardDay(),
  ),
  DietPlan(
    clientId: 'c5',
    day: 'Pazartesi',
    kcal: 1900,
    state: PlanState.approved,
    draftedAt: _daysAgo(12),
    meals: _standardDay(),
  ),
];

/// Anchored to the moment the panel is opened, not a fixed calendar date —
/// an interview run weeks after this was written must still see a plausible
/// mix of upcoming and past appointments instead of an empty or absurd list.
List<Appointment> _seedAppointments() {
  final today = DateTime.now();
  DateTime at(int dayOffset, int hour, [int minute = 0]) =>
      DateTime(today.year, today.month, today.day + dayOffset, hour, minute);

  return [
    Appointment(
      id: 'a1',
      clientId: 'c1',
      at: at(0, 16, 30),
      kind: AppointmentKind.online,
      status: AppointmentStatus.planned,
      fee: 900,
      paid: false,
    ),
    Appointment(
      id: 'a2',
      clientId: 'c3',
      at: at(1, 10),
      kind: AppointmentKind.inPerson,
      status: AppointmentStatus.planned,
      fee: 1200,
      paid: false,
    ),
    Appointment(
      id: 'a3',
      clientId: 'c2',
      at: at(1, 14),
      kind: AppointmentKind.online,
      status: AppointmentStatus.reminderSent,
      fee: 900,
      paid: true,
    ),
    Appointment(
      id: 'a4',
      clientId: 'c4',
      at: at(3, 11, 30),
      kind: AppointmentKind.online,
      status: AppointmentStatus.planned,
      fee: 900,
      paid: false,
    ),
    Appointment(
      id: 'a5',
      clientId: 'c5',
      at: at(-2, 15),
      kind: AppointmentKind.inPerson,
      status: AppointmentStatus.completed,
      fee: 1200,
      paid: false,
    ),
    Appointment(
      id: 'a7',
      clientId: 'c4',
      at: at(-5, 12),
      kind: AppointmentKind.online,
      status: AppointmentStatus.noShow,
      fee: 900,
      paid: false,
    ),
    Appointment(
      id: 'a6',
      clientId: 'c1',
      at: at(-7, 16, 30),
      kind: AppointmentKind.online,
      status: AppointmentStatus.completed,
      fee: 900,
      paid: false,
    ),
  ];
}

/// Weekly readings ending [daysSinceLast] days ago. Anchored to today for the
/// same reason the appointments are: a series hard-coded to June 2026 turns
/// every chart stale, and "son tartım" is now a signal the panel acts on.
List<WeightEntry> _series(int daysSinceLast, List<double> kg) {
  final today = DateTime.now();
  final last = DateTime(today.year, today.month, today.day - daysSinceLast);
  return [
    for (var i = 0; i < kg.length; i++)
      WeightEntry(
        last.subtract(Duration(days: (kg.length - 1 - i) * 7)),
        kg[i],
      ),
  ];
}

// The gaps are deliberate: Ahmet and Burak have stopped weighing in, so the
// Genel Bakış triage list has something true to point at.
Map<String, List<WeightEntry>> _seedWeights() => {
  'c1': _series(3, [78.4, 77.1, 76.5, 75.8, 75.0, 74.2, 73.6, 73.1, 72.4]),
  'c2': _series(6, [64.2, 63.8, 63.9, 63.4, 63.1, 63.3, 63.0, 63.2, 63.0]),
  'c3': _series(12, [99.6, 98.8, 98.1, 97.2, 96.9, 96.0, 95.5, 95.1, 94.8]),
  'c4': _series(5, [59.8, 59.4, 59.1, 58.9, 58.6, 58.5, 58.3, 58.4, 58.2]),
  'c5': _series(21, [95.2, 94.1, 93.0, 92.4, 91.5, 90.8, 89.9, 89.0, 88.1]),
};

/// Three clients, three readings each, roughly monthly — a guess at both the
/// measurements and the cadence. Merve and Zeynep have none on purpose.
Map<String, List<BodyMeasurement>> _seedMeasurements() {
  final today = DateTime.now();
  DateTime ago(int days) => DateTime(today.year, today.month, today.day - days);

  return {
    'c1': [
      BodyMeasurement(
        date: ago(66),
        waistCm: 92.0,
        hipCm: 108.0,
        bodyFatPct: 36.4,
        muscleMassKg: 46.1,
      ),
      BodyMeasurement(
        date: ago(38),
        waistCm: 88.5,
        hipCm: 106.0,
        bodyFatPct: 34.8,
        muscleMassKg: 46.4,
      ),
      BodyMeasurement(
        date: ago(3),
        waistCm: 85.0,
        hipCm: 104.5,
        bodyFatPct: 33.1,
        muscleMassKg: 46.8,
      ),
    ],
    'c3': [
      BodyMeasurement(
        date: ago(70),
        waistCm: 114.0,
        hipCm: 112.0,
        bodyFatPct: 32.8,
        muscleMassKg: 62.4,
      ),
      BodyMeasurement(
        date: ago(41),
        waistCm: 111.5,
        hipCm: 111.0,
        bodyFatPct: 31.9,
        muscleMassKg: 62.0,
      ),
      BodyMeasurement(
        date: ago(12),
        waistCm: 109.0,
        hipCm: 110.0,
        bodyFatPct: 31.2,
        muscleMassKg: 61.7,
      ),
    ],
    'c5': [
      BodyMeasurement(
        date: ago(56),
        waistCm: 106.0,
        hipCm: 105.0,
        bodyFatPct: 29.5,
        muscleMassKg: 60.2,
      ),
      BodyMeasurement(
        date: ago(21),
        waistCm: 101.5,
        hipCm: 103.0,
        bodyFatPct: 27.6,
        muscleMassKg: 60.9,
      ),
    ],
  };
}

Map<String, Macros> _seedMacros() => {
  'c1': const Macros(proteinG: 95, carbG: 165, fatG: 55),
  'c2': const Macros(proteinG: 130, carbG: 250, fatG: 70),
  'c3': const Macros(proteinG: 110, carbG: 170, fatG: 62),
  'c4': const Macros(proteinG: 88, carbG: 190, fatG: 58),
  'c5': const Macros(proteinG: 105, carbG: 195, fatG: 64),
};

/// Anchored to now like the appointments, for the same reason: a message
/// timeline dated August 2026 would look stale in an interview run later.
List<Conversation> _seedConversations() {
  final now = DateTime.now();
  DateTime ago(int hours) => now.subtract(Duration(hours: hours));
  var counter = 0;
  ChatMessage msg(MessageSender sender, String text, int hoursAgo) {
    counter++;
    return ChatMessage(
      id: 'seed-m$counter',
      sender: sender,
      text: text,
      sentAt: ago(hoursAgo),
    );
  }

  return [
    Conversation(
      clientId: 'c1',
      messages: [
        msg(
          MessageSender.client,
          'Merhaba, bugünkü öğle yemeğini dışarıda yiyeceğim, mercimek '
          'çorbası + salata olur mu?',
          20,
        ),
        msg(
          MessageSender.dietitian,
          'Merhaba Elif, olur — yanına 1 dilim tam buğday ekmeği ekleyebilirsin.',
          19,
        ),
        msg(MessageSender.client, 'Süper, teşekkürler!', 19),
      ],
    ),
    Conversation(
      clientId: 'c2',
      messages: [
        msg(
          MessageSender.client,
          'Bu akşam antrenmandan sonra çok acıktım, planın dışında bir şey '
          'yiyebilir miyim?',
          3,
        ),
      ],
    ),
    Conversation(clientId: 'c3', messages: []),
    Conversation(
      clientId: 'c4',
      messages: [
        msg(
          MessageSender.dietitian,
          'Zeynep, demir takviyeni C vitaminiyle birlikte almayı unutma.',
          48,
        ),
        msg(MessageSender.client, 'Tamamdır, unutmuyorum.', 47),
      ],
    ),
    Conversation(
      clientId: 'c5',
      messages: [
        msg(
          MessageSender.client,
          'Hocam vardiyam değişti, öğün saatlerini nasıl kaydırayım?',
          31,
        ),
      ],
    ),
  ];
}
