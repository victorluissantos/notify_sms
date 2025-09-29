class SMSQueueItem {
  final String status;
  final String message;
  final String number;

  SMSQueueItem({
    required this.status,
    required this.message,
    required this.number,
  });

  factory SMSQueueItem.fromJson(Map<String, dynamic> json) {
    return SMSQueueItem(
      status: json['status'] ?? json['situacao'] ?? '',
      message: json['msg'] ?? '',
      number: (json['number'] ?? '').toString(), // Converte int ou String para String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': message,
      'number': number,
    };
  }

  @override
  String toString() {
    return 'SMSQueueItem(status: $status, message: $message, number: $number)';
  }
}
