enum VerificationStatus { pending, approved, rejected }

enum PlanState { aiDraft, approved }

/// Dart identifiers cannot carry the dotless i, so the names are transliterated
/// and the Turkish labels live with the screens that show them.
enum Sex { kadin, erkek }

/// Five levels, not four, because the dietitian's own energy sheet has five
/// activity factors (1.2 – 1.6) and the levels exist to pick one.
enum ActivityLevel { sedanter, hafifAktif, ortaAktif, aktif, cokAktif }

class DemoClient {
  DemoClient({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.targetWeightKg,
    required this.activityLevel,
    required this.dietType,
    required this.allergies,
    required this.chronicConditions,
    required this.medications,
    required this.note,
    required this.startedOn,
  });

  final String id;
  final String name;
  final int age;
  final Sex sex;
  final int heightCm;
  double weightKg;
  final String goal;

  /// Null where the goal is not a number ('Sporcu beslenmesi'). The chart
  /// draws a target line only when there is one, which is itself a question:
  /// do you agree a hedef kilo on every client, or only on some?
  final double? targetWeightKg;
  final ActivityLevel activityLevel;

  /// Open vocabulary on purpose ('standart', 'vejetaryen', ...): the real list
  /// is an interview answer, and an enum would have to change to learn it.
  final String dietType;
  final List<String> allergies;
  final List<String> chronicConditions;

  /// Medication and supplement in one list; a dietitian reads them together.
  final List<String> medications;

  /// What is left once the structured facts above are pulled out. May be empty.
  final String note;
  final DateTime startedOn;
}

class MealItem {
  MealItem({required this.food, required this.amount});

  String food;
  String amount;
}

class Meal {
  Meal({required this.name, required this.time, required this.items});

  final String name;
  String time;
  final List<MealItem> items;
}

class DietPlan {
  DietPlan({
    required this.clientId,
    required this.day,
    required this.kcal,
    required this.state,
    required this.draftedAt,
    required this.meals,
    this.aiNote,
  });

  final String clientId;
  final String day;
  int kcal;
  PlanState state;

  /// When the AI put this draft in front of the dietitian. Only interesting
  /// while it is still a draft: it is what "3 gündür bekliyor" counts from.
  final DateTime draftedAt;
  final List<Meal> meals;

  /// Why the draft looks the way it does. Shown only while unapproved.
  final String? aiNote;

  bool get isDraft => state == PlanState.aiDraft;
}

/// `cancelled` is the dietitian calling it off; `noShow` is the client not
/// turning up. They are separated because they almost certainly differ on
/// payment and on the client's record — how, exactly, is an interview answer.
enum AppointmentStatus { planned, reminderSent, completed, cancelled, noShow }

enum AppointmentKind { online, inPerson }

class Appointment {
  Appointment({
    required this.id,
    required this.clientId,
    required this.at,
    required this.kind,
    required this.status,
    required this.fee,
    required this.paid,
  });

  final String id;
  final String clientId;
  final DateTime at;
  final AppointmentKind kind;
  AppointmentStatus status;
  final int fee;
  bool paid;

  bool get isPast => at.isBefore(DateTime.now());
}

class WeightEntry {
  const WeightEntry(this.date, this.kg);

  final DateTime date;
  final double kg;
}

/// Everything measured at a session that is not the scale reading. Which of
/// these a dietitian actually takes, how often, and with what device is an
/// open question — these four are a guess put on screen so it can be
/// corrected. Body fat and muscle mass imply a BIA/Tanita device; if that
/// guess is right, `energy.dart` could use the Cunningham formula it
/// currently cannot.
class BodyMeasurement {
  const BodyMeasurement({
    required this.date,
    required this.waistCm,
    required this.hipCm,
    required this.bodyFatPct,
    required this.muscleMassKg,
  });

  final DateTime date;
  final double waistCm;
  final double hipCm;
  final double bodyFatPct;
  final double muscleMassKg;

  /// Bel/kalça oranı — the number that carries cardiometabolic risk in a way
  /// scale weight does not.
  double get waistHipRatio => waistCm / hipCm;
}

/// Targets a dietitian sets, and what the current draft actually adds up to.
class Macros {
  const Macros({
    required this.proteinG,
    required this.carbG,
    required this.fatG,
  });

  final int proteinG;
  final int carbG;
  final int fatG;
}

enum MessageSender { dietitian, client }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final MessageSender sender;
  final String text;
  final DateTime sentAt;
}

class Conversation {
  Conversation({required this.clientId, required this.messages});

  final String clientId;
  final List<ChatMessage> messages;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  /// The dietitian hasn't replied to the client's most recent message yet.
  bool get hasUnread =>
      lastMessage != null && lastMessage!.sender == MessageSender.client;
}

class ReminderSettings {
  ReminderSettings({
    required this.dayBefore,
    required this.hoursBefore,
    required this.paymentReminder,
    required this.channel,
  });

  bool dayBefore;
  bool hoursBefore;
  bool paymentReminder;

  /// 'push' costs nothing; 'sms' needs a paid provider.
  String channel;
}

// ---------------------------------------------------------------------------
// Exchange lists (değişim listesi)
//
// The second, competing answer to "what is a diet plan". Research says Turkish
// dietitians do not write food + amount; they write how many exchanges from
// which group, and the client picks the food from a substitution list, where
// everything in a group is equivalent at its household measure. HANDOFF §2
// calls this an unconfirmed hypothesis: this model exists to be shown to a
// dietitian next to the freeform editor, not because the question is settled.
// ---------------------------------------------------------------------------

enum ExchangeGroup { sut, et, nisasta, baklagil, sebzeA, sebzeB, meyve, yag }

/// Kilocalories in one exchange. Placeholder values from the published ADA
/// tables; the numbers a dietitian actually uses are an interview answer.
const kExchangeKcal = <ExchangeGroup, int>{
  ExchangeGroup.sut: 120,
  ExchangeGroup.et: 75,
  ExchangeGroup.nisasta: 80,
  ExchangeGroup.baklagil: 110,
  ExchangeGroup.sebzeA: 0,
  ExchangeGroup.sebzeB: 25,
  ExchangeGroup.meyve: 60,
  ExchangeGroup.yag: 45,
};

const kExchangeGroupLabels = <ExchangeGroup, String>{
  ExchangeGroup.sut: 'Süt',
  ExchangeGroup.et: 'Et',
  ExchangeGroup.nisasta: 'Nişastalı yiyecek',
  ExchangeGroup.baklagil: 'Kuru baklagil',
  ExchangeGroup.sebzeA: 'A grubu sebze',
  ExchangeGroup.sebzeB: 'B grubu sebze',
  ExchangeGroup.meyve: 'Meyve',
  ExchangeGroup.yag: 'Yağ',
};

/// One exchange, in household measures rather than grams. Shown as the
/// substitution sheet: the part that makes the model recognisable.
const kExchangeFoods = <ExchangeGroup, List<String>>{
  ExchangeGroup.sut: [
    '1 su bardağı süt',
    '1 su bardağı yoğurt',
    '1 kase ayran',
    '2 kibrit kutusu beyaz peynir',
  ],
  ExchangeGroup.et: [
    '1 köfte kadar kırmızı et',
    '1 köfte kadar tavuk',
    '1 yumurta',
    '1 kibrit kutusu beyaz peynir',
    '2 yemek kaşığı ton balığı',
  ],
  ExchangeGroup.nisasta: [
    '1 ince dilim ekmek',
    '4 yemek kaşığı pilav',
    '4 yemek kaşığı makarna',
    '1 küçük patates',
    '3 yemek kaşığı yulaf',
  ],
  ExchangeGroup.baklagil: [
    '4 yemek kaşığı nohut',
    '4 yemek kaşığı kuru fasulye',
    '4 yemek kaşığı mercimek',
  ],
  ExchangeGroup.sebzeA: [
    'Salatalık',
    'Marul',
    'Domates',
    'Biber',
    'Ispanak',
    'Kabak',
  ],
  ExchangeGroup.sebzeB: [
    '2 yemek kaşığı bezelye',
    '1 küçük havuç',
    '2 yemek kaşığı mısır',
  ],
  ExchangeGroup.meyve: [
    '1 küçük elma',
    '2 küçük mandalina',
    '1 orta dilim karpuz',
    '10 tane çilek',
    '3 tane kayısı',
  ],
  ExchangeGroup.yag: [
    '1 çay kaşığı zeytinyağı',
    '6 tane badem',
    '2 tane ceviz içi',
    '1 tatlı kaşığı tahin',
  ],
};

class ExchangeLine {
  ExchangeLine({required this.group, required this.count});

  final ExchangeGroup group;
  int count;

  int get kcal => count * (kExchangeKcal[group] ?? 0);
}

class ExchangeMeal {
  ExchangeMeal({required this.name, required this.time, required this.lines});

  final String name;
  final String time;
  final List<ExchangeLine> lines;

  int get kcal => lines.fold(0, (sum, line) => sum + line.kcal);
}

/// The same plan as [DietPlan], counted instead of written out. Reuses
/// [PlanState] so the AI-draft and approval mechanics are identical in both.
class ExchangePlan {
  ExchangePlan({
    required this.clientId,
    required this.day,
    required this.state,
    required this.draftedAt,
    required this.meals,
    this.aiNote,
  });

  final String clientId;
  final String day;
  PlanState state;
  final DateTime draftedAt;
  final List<ExchangeMeal> meals;
  final String? aiNote;

  bool get isDraft => state == PlanState.aiDraft;

  /// Derived, not stored: every stepper tap moves this number.
  int get kcal => meals.fold(0, (sum, meal) => sum + meal.kcal);
}
