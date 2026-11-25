import 'package:flutter_test/flutter_test.dart';
import 'package:helkady_pomodoro/stats.dart';
import 'package:helkady_pomodoro/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('counts sessions per day and totals', () {
    final s = SessionStats();
    s.addSession(DateTime(2026, 11, 25, 9));
    s.addSession(DateTime(2026, 11, 25, 15));
    s.addSession(DateTime(2026, 11, 24, 10));
    expect(s.sessionsOn(DateTime(2026, 11, 25)), 2);
    expect(s.total, 3);
  });

  test('lastDays is oldest first, zero filled, crosses month boundary', () {
    final s = SessionStats()..addSession(DateTime(2026, 11, 30));
    final d = s.lastDays(DateTime(2026, 12, 2), 4);
    expect(d.map((e) => SessionStats.keyFor(e.key)).toList(),
        ['2026-11-29', '2026-11-30', '2026-12-01', '2026-12-02']);
    expect(d.map((e) => e.value).toList(), [0, 1, 0, 0]);
  });

  test('json round trip', () {
    final s = SessionStats()..addSession(DateTime(2026, 1, 5));
    expect(SessionStats.fromJson(s.toJson()).sessionsOn(DateTime(2026, 1, 5)), 1);
  });

  testWidgets('timer counts down, completes a session and records it', (t) async {
    SharedPreferences.setMockInitialValues({});
    var fake = DateTime(2026, 11, 25, 10);
    await t.pumpWidget(MaterialApp(home: TimerPage(focusSeconds: 2, breakSeconds: 1, clock: () => fake)));
    await t.pump();
    expect(find.text('00:02'), findsOneWidget);
    await t.tap(find.byKey(const Key('startPause')));
    for (var i = 0; i < 11; i++) {
      fake = fake.add(const Duration(milliseconds: 250));
      await t.pump(const Duration(milliseconds: 250));
    }
    expect(find.textContaining('1 sessions'), findsOneWidget);
    // now on break
    expect(find.text('00:01'), findsOneWidget);
    // dispose cleanly
    await t.pumpWidget(const SizedBox());
  });
}
