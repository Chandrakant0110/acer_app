class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? dateTime,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      dateTime: dateTime ?? this.dateTime,
      isRead: isRead ?? this.isRead,
    );
  }
}

class Notification {
  String? get title => null;

  String? get message => null;

  bool get isRead => false;

  set isRead(bool isRead) {}
}
