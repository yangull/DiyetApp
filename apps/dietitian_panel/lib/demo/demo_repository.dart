import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_codec.dart';
import 'demo_models.dart';
import 'demo_store.dart';

/// Local data for the discovery prototype. No Supabase, no network: the panel
/// is driven live in front of a dietitian, and everything they change is
/// mirrored into browser storage so a reload does not wipe the conversation.
class DemoState {
  DemoState({
    required this.clients,
    required this.plans,
    required this.appointments,
    required this.weights,
    required this.macros,
    required this.reminders,
  });

  final List<DemoClient> clients;
  final List<DietPlan> plans;
  final List<Appointment> appointments;
  final Map<String, List<WeightEntry>> weights;
  final Map<String, Macros> macros;
  final ReminderSettings reminders;

  List<Appointment> get upcoming =>
      appointments.where((a) => !a.isPast).toList()
        ..sort((a, b) => a.at.compareTo(b.at));

  int get unpaidCount => appointments.where((a) => a.isPast && !a.paid).length;

  int get unpaidTotal => appointments
      .where((a) => a.isPast && !a.paid)
      .fold(0, (sum, a) => sum + a.fee);

  DemoClient clientOf(String id) => clients.firstWhere((c) => c.id == id);

  DietPlan planFor(String clientId) =>
      plans.firstWhere((p) => p.clientId == clientId);

  int get draftCount => plans.where((p) => p.isDraft).length;
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
}

final demoProvider = NotifierProvider<DemoNotifier, DemoState>(
  DemoNotifier.new,
);

/// Seeds are built fresh on every call: the objects are mutable and a reset
/// that handed back the same instances would hand back the edits too.
DemoState _seedState() => DemoState(
  clients: _seedClients(),
  plans: _seedPlans(),
  appointments: _seedAppointments(),
  weights: _seedWeights(),
  macros: _seedMacros(),
  reminders: ReminderSettings(
    dayBefore: true,
    hoursBefore: true,
    paymentReminder: false,
    channel: 'push',
  ),
);

List<DemoClient> _seedClients() => [
  DemoClient(
    id: 'c1',
    name: 'Elif Aydın',
    age: 34,
    heightCm: 165,
    weightKg: 72.4,
    goal: 'Kilo verme',
    note: 'Ofiste çalışıyor, öğle yemeğini dışarıda yiyor. Laktoz hassasiyeti.',
    startedOn: DateTime(2026, 7, 14),
  ),
  DemoClient(
    id: 'c2',
    name: 'Merve Yılmaz',
    age: 28,
    heightCm: 171,
    weightKg: 63.0,
    goal: 'Sporcu beslenmesi',
    note: 'Haftada 4 gün antrenman. Akşam geç saatte acıkıyor.',
    startedOn: DateTime(2026, 8, 2),
  ),
  DemoClient(
    id: 'c3',
    name: 'Ahmet Demir',
    age: 45,
    heightCm: 178,
    weightKg: 94.8,
    goal: 'Tip 2 diyabet yönetimi',
    note: 'Doktor takibinde. Kan değerleri her ay güncelleniyor.',
    startedOn: DateTime(2026, 6, 21),
  ),
  DemoClient(
    id: 'c4',
    name: 'Zeynep Kaya',
    age: 31,
    heightCm: 160,
    weightKg: 58.2,
    goal: 'Kilo koruma',
    note: 'Vejetaryen. Demir takviyesi kullanıyor.',
    startedOn: DateTime(2026, 8, 11),
  ),
  DemoClient(
    id: 'c5',
    name: 'Burak Şahin',
    age: 39,
    heightCm: 183,
    weightKg: 88.1,
    goal: 'Kilo verme',
    note: 'Vardiyalı çalışıyor, öğün saatleri düzensiz.',
    startedOn: DateTime(2026, 5, 30),
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
