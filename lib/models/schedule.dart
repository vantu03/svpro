class Schedule {
  final String date;
  final String timeRange;
  final String scheduleType;
  final String className;
  final Map<String, dynamic> detail;
  final Map<String, dynamic> hidden;

  Schedule({
    required this.date,
    required this.timeRange,
    required this.scheduleType,
    required this.className,
    required this.detail,
    required this.hidden,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      date: json['date'],
      timeRange: json['timeRange'],
      scheduleType: json['scheduleType'],
      className: json['className'],
      detail: Map<String, dynamic>.from(json['detail']),
      hidden: Map<String, dynamic>.from(json['hidden']),
    );
  }
}
