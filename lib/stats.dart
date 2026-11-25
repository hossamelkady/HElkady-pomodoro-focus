/// Daily focus-session statistics (pure Dart, easy to test).
class SessionStats {
  SessionStats([Map<String, int>? byDay]) : byDay = byDay ?? {};

  /// Completed focus sessions per day, keyed by `yyyy-MM-dd`.
  final Map<String, int> byDay;

  static String keyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void addSession(DateTime when) {
    final k = keyFor(when);
    byDay[k] = (byDay[k] ?? 0) + 1;
  }

  int sessionsOn(DateTime d) => byDay[keyFor(d)] ?? 0;

  /// Sessions for the last [n] days, oldest first, ending at [today].
  List<MapEntry<DateTime, int>> lastDays(DateTime today, int n) {
    final base = DateTime(today.year, today.month, today.day);
    return [
      for (var i = n - 1; i >= 0; i--)
        MapEntry(DateTime(base.year, base.month, base.day - i),
            sessionsOn(DateTime(base.year, base.month, base.day - i))),
    ];
  }

  int get total => byDay.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => byDay;

  static SessionStats fromJson(Map<String, dynamic> j) =>
      SessionStats({for (final e in j.entries) e.key: (e.value as num).toInt()});
}
