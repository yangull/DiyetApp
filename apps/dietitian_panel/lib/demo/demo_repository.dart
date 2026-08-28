import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_codec.dart';
import 'demo_models.dart';
import 'demo_store.dart';

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
  final Map<String, Macros> macros;
  final ReminderSettings reminders;
  final List<Conversation> conversations;

  List<Appointment> get upcoming =>
      appointments.where((a) => !a.isPast).toList()
        ..sort((a, b) => a.at.compareTo(b.at));

  List<Appointment> get completed =>
      appointments
          .where((a) => a.isPast && a.status != AppointmentStatus.cancelled)
          .toList()
        ..sort((a, b) => b.at.compareTo(a.at));

  int get unpaidCount => appointments.where((a) => a.isPast && !a.paid).length;

  int get unpaidTotal => appointments
      .where((a) => a.isPast && !a.paid)
      .fold(0, (sum, a) => sum + a.fee);

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

List<DietPlan> _seedPlans() => [
  DietPlan(
    clientId: 'c1',
    day: 'Pazartesi',
    kcal: 1600,
    state: PlanState.aiDraft,
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
    aiNote: 'Antrenman günleri için karbonhidrat öğün öncesine kaydırıldı.',
    meals: _standardDay(),
  ),
  DietPlan(
    clientId: 'c3',
    day: 'Pazartesi',
    kcal: 1800,
    state: PlanState.approved,
    meals: _standardDay(),
  ),
  DietPlan(
    clientId: 'c4',
    day: 'Pazartesi',
    kcal: 1700,
    state: PlanState.aiDraft,
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

List<WeightEntry> _series(int startDay, List<double> kg) => [
  for (var i = 0; i < kg.length; i++)
    WeightEntry(DateTime(2026, 6, startDay).add(Duration(days: i * 7)), kg[i]),
];

Map<String, List<WeightEntry>> _seedWeights() => {
  'c1': _series(2, [78.4, 77.1, 76.5, 75.8, 75.0, 74.2, 73.6, 73.1, 72.4]),
  'c2': _series(2, [64.2, 63.8, 63.9, 63.4, 63.1, 63.3, 63.0, 63.2, 63.0]),
  'c3': _series(2, [99.6, 98.8, 98.1, 97.2, 96.9, 96.0, 95.5, 95.1, 94.8]),
  'c4': _series(2, [59.8, 59.4, 59.1, 58.9, 58.6, 58.5, 58.3, 58.4, 58.2]),
  'c5': _series(2, [95.2, 94.1, 93.0, 92.4, 91.5, 90.8, 89.9, 89.0, 88.1]),
};

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
    Conversation(clientId: 'c5', messages: []),
  ];
}
