import 'demo_models.dart';
import 'demo_repository.dart';

/// Thresholds are named rather than inlined because every one of them is a
/// guess. "How many days without a tartım before you chase someone?" is a
/// question for the interview, and the answer changes these three numbers.
const kStaleWeighInDays = 7;
const kUnansweredMessageHours = 24;
const kNoShowLookbackDays = 14;

/// How long a draft may sit before the badge turns amber.
const kPlanWaitingWarningHours = 48;

enum TriageKind { staleWeighIn, unansweredMessage, noShow }

/// One reason a client needs attention this morning. Deliberately *not* an
/// aggregate score: HANDOFF's own warning is that any number we invent will be
/// wrong, and a dietitian who distrusts the score distrusts the panel. Each
/// signal states the raw fact it came from instead.
class TriageSignal {
  const TriageSignal({
    required this.client,
    required this.kind,
    required this.detail,
    required this.overdueBy,
  });

  final DemoClient client;
  final TriageKind kind;

  /// Rendered as-is; the screens do not reformat it.
  final String detail;

  /// How far past the threshold this is. Sorting on it puts the worst first.
  final Duration overdueBy;
}

/// Pending drafts are excluded on purpose: they already have their own row and
/// their own waiting badge under "Sıradaki işler", and a client appearing twice
/// on one screen reads as a bug rather than as urgency.
List<TriageSignal> triageSignals(DemoState state, {DateTime? now}) {
  final at = now ?? DateTime.now();
  final signals = <TriageSignal>[];

  for (final client in state.clients) {
    final weights = state.weights[client.id] ?? const <WeightEntry>[];
    if (weights.isNotEmpty) {
      final since = at.difference(weights.last.date);
      if (since.inDays > kStaleWeighInDays) {
        signals.add(
          TriageSignal(
            client: client,
            kind: TriageKind.staleWeighIn,
            detail: '${since.inDays} gündür tartım girmedi',
            overdueBy: since - const Duration(days: kStaleWeighInDays),
          ),
        );
      }
    }

    final conversation = state.conversationOf(client.id);
    final last = conversation.lastMessage;
    if (conversation.hasUnread && last != null) {
      final waiting = at.difference(last.sentAt);
      if (waiting.inHours >= kUnansweredMessageHours) {
        signals.add(
          TriageSignal(
            client: client,
            kind: TriageKind.unansweredMessage,
            detail: '${waiting.inHours} saattir mesajı yanıtsız',
            overdueBy: waiting - const Duration(hours: kUnansweredMessageHours),
          ),
        );
      }
    }

    for (final appointment in state.appointments) {
      if (appointment.clientId != client.id) continue;
      if (appointment.status != AppointmentStatus.noShow) continue;
      final since = at.difference(appointment.at);
      if (since.inDays > kNoShowLookbackDays) continue;
      signals.add(
        TriageSignal(
          client: client,
          kind: TriageKind.noShow,
          detail: '${since.inDays} gün önce randevusuna gelmedi',
          overdueBy: since,
        ),
      );
    }
  }

  signals.sort((a, b) => b.overdueBy.compareTo(a.overdueBy));
  return signals;
}

/// "3 gün", "26 saat", "40 dakika" — the longest unit that is not zero, so a
/// draft's age reads the way a person would say it out loud.
String formatAge(Duration age) {
  if (age.inDays >= 1) return '${age.inDays} gün';
  if (age.inHours >= 1) return '${age.inHours} saat';
  return '${age.inMinutes.clamp(1, 59)} dakika';
}
