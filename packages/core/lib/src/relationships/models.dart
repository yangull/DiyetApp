/// Mirrors `public.relationship_status`. Values match the Postgres enum
/// labels exactly, so `name` round-trips through Supabase.
enum RelationshipStatus { pending, active, declined }

/// Mirrors `public.dietitian_client_relationships`. A row is created by a
/// dietitian with only an email address to go on, so [clientId] stays null
/// until the invited person signs up and accepts.
class ClientRelationship {
  const ClientRelationship({
    required this.id,
    required this.dietitianId,
    required this.invitedEmail,
    required this.status,
    required this.createdAt,
    this.clientId,
  });

  final String id;
  final String dietitianId;
  final String? clientId;
  final String invitedEmail;
  final RelationshipStatus status;
  final DateTime createdAt;

  bool get isPending => status == RelationshipStatus.pending;

  bool get isActive => status == RelationshipStatus.active;
}

/// One row of `list_my_clients()`: enough to label a matched client in a list,
/// and deliberately no more. The function exists instead of a profiles read
/// policy so this column set stays an explicit decision — see migration 4.
class ClientName {
  const ClientName({required this.clientId, required this.fullName});

  final String clientId;
  final String fullName;
}
