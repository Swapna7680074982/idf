class SupportIssueType {
  final int id;
  final String name;

  const SupportIssueType({
    required this.id,
    required this.name,
  });

  factory SupportIssueType.fromJson(Map<String, dynamic> json) {
    return SupportIssueType(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class SupportTicket {
  final int id;
  final String ticketNo;
  final String status;
  final String? message;
  final String? createdAt;

  const SupportTicket({
    required this.id,
    required this.ticketNo,
    required this.status,
    this.message,
    this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      ticketNo: json['ticket_no']?.toString() ?? json['ticketNo']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      message: json['message']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class CreateTicketResult {
  final SupportTicket ticket;
  final String message;

  const CreateTicketResult({
    required this.ticket,
    required this.message,
  });

  factory CreateTicketResult.fromJson(Map<String, dynamic> json) {
    final msg = json['message']?.toString() ?? 'Your message has been sent.';
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final ticketJson = data['ticket'] is Map<String, dynamic>
        ? data['ticket'] as Map<String, dynamic>
        : data;

    return CreateTicketResult(
      ticket: SupportTicket.fromJson(ticketJson),
      message: msg,
    );
  }
}
