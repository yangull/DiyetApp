enum VerificationStatus { pending, approved, rejected }

enum PlanState { aiDraft, approved }

class DemoClient {
  DemoClient({
    required this.id,
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.note,
    required this.startedOn,
  });

  final String id;
  final String name;
  final int age;
  final int heightCm;
  double weightKg;
  final String goal;
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
    required this.meals,
    this.aiNote,
  });

  final String clientId;
  final String day;
  int kcal;
  PlanState state;
  final List<Meal> meals;

  /// Why the draft looks the way it does. Shown only while unapproved.
  final String? aiNote;

  bool get isDraft => state == PlanState.aiDraft;
}

enum AppointmentStatus { planned, reminderSent, completed, cancelled }

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
