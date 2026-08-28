import 'dart:convert';

import 'demo_models.dart';
import 'demo_repository.dart';

/// Bumped whenever the shape below changes. A stored state written by an older
/// build is discarded rather than half-read — a live interview is the worst
/// place to debug a migration.
///
/// v2 added `conversations` (the Mesajlar screen).
const _schemaVersion = 2;

String encodeDemoState(DemoState state) => jsonEncode({
  'version': _schemaVersion,
  'clients': [
    for (final c in state.clients)
      {
        'id': c.id,
        'name': c.name,
        'age': c.age,
        'heightCm': c.heightCm,
        'weightKg': c.weightKg,
        'goal': c.goal,
        'note': c.note,
        'startedOn': c.startedOn.toIso8601String(),
      },
  ],
  'plans': [
    for (final p in state.plans)
      {
        'clientId': p.clientId,
        'day': p.day,
        'kcal': p.kcal,
        'state': p.state.name,
        'aiNote': p.aiNote,
        'meals': [
          for (final m in p.meals)
            {
              'name': m.name,
              'time': m.time,
              'items': [
                for (final i in m.items) {'food': i.food, 'amount': i.amount},
              ],
            },
        ],
      },
  ],
  'appointments': [
    for (final a in state.appointments)
      {
        'id': a.id,
        'clientId': a.clientId,
        'at': a.at.toIso8601String(),
        'kind': a.kind.name,
        'status': a.status.name,
        'fee': a.fee,
        'paid': a.paid,
      },
  ],
  'weights': {
    for (final e in state.weights.entries)
      e.key: [
        for (final w in e.value) {'date': w.date.toIso8601String(), 'kg': w.kg},
      ],
  },
  'macros': {
    for (final e in state.macros.entries)
      e.key: {
        'proteinG': e.value.proteinG,
        'carbG': e.value.carbG,
        'fatG': e.value.fatG,
      },
  },
  'reminders': {
    'dayBefore': state.reminders.dayBefore,
    'hoursBefore': state.reminders.hoursBefore,
    'paymentReminder': state.reminders.paymentReminder,
    'channel': state.reminders.channel,
  },
  'conversations': [
    for (final c in state.conversations)
      {
        'clientId': c.clientId,
        'messages': [
          for (final m in c.messages)
            {
              'id': m.id,
              'sender': m.sender.name,
              'text': m.text,
              'sentAt': m.sentAt.toIso8601String(),
            },
        ],
      },
  ],
});

/// Returns null for anything unreadable — wrong version, corrupt JSON, a field
/// that moved. The caller falls back to the seed data.
DemoState? decodeDemoState(String raw) {
  try {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    if (json['version'] != _schemaVersion) return null;

    return DemoState(
      clients: [
        for (final c in json['clients'] as List)
          DemoClient(
            id: c['id'] as String,
            name: c['name'] as String,
            age: c['age'] as int,
            heightCm: c['heightCm'] as int,
            weightKg: (c['weightKg'] as num).toDouble(),
            goal: c['goal'] as String,
            note: c['note'] as String,
            startedOn: DateTime.parse(c['startedOn'] as String),
          ),
      ],
      plans: [
        for (final p in json['plans'] as List)
          DietPlan(
            clientId: p['clientId'] as String,
            day: p['day'] as String,
            kcal: p['kcal'] as int,
            state: PlanState.values.byName(p['state'] as String),
            aiNote: p['aiNote'] as String?,
            meals: [
              for (final m in p['meals'] as List)
                Meal(
                  name: m['name'] as String,
                  time: m['time'] as String,
                  items: [
                    for (final i in m['items'] as List)
                      MealItem(
                        food: i['food'] as String,
                        amount: i['amount'] as String,
                      ),
                  ],
                ),
            ],
          ),
      ],
      appointments: [
        for (final a in json['appointments'] as List)
          Appointment(
            id: a['id'] as String,
            clientId: a['clientId'] as String,
            at: DateTime.parse(a['at'] as String),
            kind: AppointmentKind.values.byName(a['kind'] as String),
            status: AppointmentStatus.values.byName(a['status'] as String),
            fee: a['fee'] as int,
            paid: a['paid'] as bool,
          ),
      ],
      weights: {
        for (final e in (json['weights'] as Map<String, dynamic>).entries)
          e.key: [
            for (final w in e.value as List)
              WeightEntry(
                DateTime.parse(w['date'] as String),
                (w['kg'] as num).toDouble(),
              ),
          ],
      },
      macros: {
        for (final e in (json['macros'] as Map<String, dynamic>).entries)
          e.key: Macros(
            proteinG: e.value['proteinG'] as int,
            carbG: e.value['carbG'] as int,
            fatG: e.value['fatG'] as int,
          ),
      },
      reminders: ReminderSettings(
        dayBefore: json['reminders']['dayBefore'] as bool,
        hoursBefore: json['reminders']['hoursBefore'] as bool,
        paymentReminder: json['reminders']['paymentReminder'] as bool,
        channel: json['reminders']['channel'] as String,
      ),
      conversations: [
        for (final c in json['conversations'] as List)
          Conversation(
            clientId: c['clientId'] as String,
            messages: [
              for (final m in c['messages'] as List)
                ChatMessage(
                  id: m['id'] as String,
                  sender: MessageSender.values.byName(m['sender'] as String),
                  text: m['text'] as String,
                  sentAt: DateTime.parse(m['sentAt'] as String),
                ),
            ],
          ),
      ],
    );
  } catch (_) {
    return null;
  }
}
