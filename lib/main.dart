import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i18n.dart';
import 'stats.dart';

const focusMinutes = 25;
const breakMinutes = 5;
const _prefsKey = 'sessions_v1';

void main() => runApp(const PomodoroApp());

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: tr('Focus Timer', 'مؤقت التركيز'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
          useMaterial3: true),
      builder: (context, child) => Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key, this.focusSeconds = focusMinutes * 60, this.breakSeconds = breakMinutes * 60, this.clock = DateTime.now});
  final DateTime Function() clock;
  final int focusSeconds;
  final int breakSeconds;

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  SessionStats stats = SessionStats();
  bool onBreak = false;
  bool running = false;
  late int remaining = widget.focusSeconds;
  DateTime? _end;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_prefsKey);
    if (raw != null && mounted) {
      setState(() => stats = SessionStats.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsKey, jsonEncode(stats.toJson()));
  }

  int get _modeSeconds => onBreak ? widget.breakSeconds : widget.focusSeconds;

  void _start() {
    _end = widget.clock().add(Duration(seconds: remaining));
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    setState(() => running = true);
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => running = false);
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      running = false;
      remaining = _modeSeconds;
    });
  }

  void _switchMode(bool toBreak) {
    _ticker?.cancel();
    setState(() {
      onBreak = toBreak;
      running = false;
      remaining = _modeSeconds;
    });
  }

  void _tick() {
    final left = _end!.difference(widget.clock()).inMilliseconds;
    if (left <= 0) {
      _ticker?.cancel();
      if (!onBreak) {
        stats.addSession(widget.clock());
        _save();
      }
      setState(() {
        onBreak = !onBreak;
        running = false;
        remaining = _modeSeconds;
      });
    } else {
      final s = (left / 1000).ceil();
      if (s != remaining) setState(() => remaining = s);
    }
  }

  String get _clock {
    final m = (remaining ~/ 60).toString().padLeft(2, '0');
    final s = (remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final today = widget.clock();
    final days = stats.lastDays(today, 7);
    final maxV = days.fold<int>(1, (a, e) => e.value > a ? e.value : a);
    final todayCount = stats.sessionsOn(today);
    final progress = 1 - remaining / _modeSeconds;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Focus Timer', 'مؤقت التركيز'))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(tr('Focus', 'تركيز'))),
              ButtonSegment(value: true, label: Text(tr('Break', 'راحة'))),
            ],
            selected: {onBreak},
            onSelectionChanged: (s) => _switchMode(s.first),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox.expand(
                  child: CircularProgressIndicator(value: progress, strokeWidth: 10)),
              Text(_clock,
                  key: const Key('clock'),
                  style: Theme.of(context).textTheme.displayLarge),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FilledButton.icon(
            key: const Key('startPause'),
            onPressed: running ? _pause : _start,
            icon: Icon(running ? Icons.pause : Icons.play_arrow),
            label: Text(running ? tr('Pause', 'إيقاف مؤقت') : tr('Start', 'ابدأ')),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            key: const Key('reset'),
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt),
            label: Text(tr('Reset', 'إعادة')),
          ),
        ]),
        const SizedBox(height: 32),
        Text(tr('Today', 'اليوم'), style: Theme.of(context).textTheme.titleMedium),
        Text(
            tr('$todayCount sessions, ${todayCount * focusMinutes} min focused',
                '$todayCount جلسات، ${todayCount * focusMinutes} دقيقة تركيز'),
            key: const Key('todayStats')),
        const SizedBox(height: 16),
        Text(tr('Last 7 days', 'آخر ٧ أيام'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (final e in days)
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('${e.value}'),
                  Container(
                    height: 6 + 70.0 * e.value / maxV,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Text('${e.key.day}/${e.key.month}',
                      style: const TextStyle(fontSize: 10)),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        Text(tr('All time: ${stats.total} sessions', 'الإجمالي: ${stats.total} جلسة')),
      ]),
    );
  }
}
