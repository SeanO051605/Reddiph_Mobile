import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../widgets/doctor_widgets.dart';

class _LogEntry {
  final String title, detail, when;
  const _LogEntry(this.title, this.detail, this.when);
}

/// Doctor > Reports tab: weekly emergency logs.
class DoctorReportsTab extends StatefulWidget {
  const DoctorReportsTab({super.key});

  @override
  State<DoctorReportsTab> createState() => _DoctorReportsTabState();
}

class _DoctorReportsTabState extends State<DoctorReportsTab> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _counts = [4, 6, 2, 4, 5, 6, 4]; // totals 31
  static const _recent = <_LogEntry>[
    _LogEntry('Vehicular collision — Dela Cruz, J.',
        'Admitted 11:26 · ER bay 3', 'Today'),
    _LogEntry('Fall injury — Aling Nena', 'Admitted 09:40 · Discharged', 'Today'),
    _LogEntry('Fever, child — Reyes household', 'Observed, released',
        'Yesterday'),
    _LogEntry('Dengue, day 2 — Santos, D.', 'Under observation', '2 days ago'),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final total = _counts.reduce((a, b) => a + b);
    final maxCount = _counts.reduce((a, b) => a > b ? a : b);

    return ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 110), children: [
      // Title row
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Emergency logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            SizedBox(height: 2),
            Text('District Hospital · This week',
                style: TextStyle(fontSize: 9, color: Colors.black54)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('This week',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16),
          ]),
        ),
      ]),
      const SizedBox(height: 18),

      // Weekly chart card
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF55627F), kSlate],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$total',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const Text('Cases this week',
                    style: TextStyle(color: Colors.white, fontSize: 9)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                _selected == 0
                    ? 'Today: ${_counts[0]}'
                    : '${_days[_selected]}: ${_counts[_selected]}',
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (int i = 0; i < _days.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selected = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            height: 20 + (_counts[i] / maxCount) * 90,
                            decoration: BoxDecoration(
                              color: i == _selected
                                  ? Colors.white
                                  : kSlateLight.withOpacity(.85),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(_days[i],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 8)),
                        ],
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),

      // Stat cards
      Row(children: [
        _stat('4', 'Critical', kSos),
        const SizedBox(width: 10),
        _stat('9m', 'Avg. door-to-doctor', Colors.black),
      ]),
      const SizedBox(height: 22),

      // Recent cases
      Row(children: [
        const Expanded(
          child: Text('Recent Cases',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Full case history coming soon.'))),
          child: const Text('View all',
              style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w800, color: kNavy)),
        ),
      ]),
      const SizedBox(height: 8),
      DCard(
        Column(children: [
          for (int i = 0; i < _recent.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_recent[i].title,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(_recent[i].detail,
                        style: const TextStyle(
                            fontSize: 8, color: Colors.black54)),
                  ]),
                ),
                Text(_recent[i].when,
                    style:
                        const TextStyle(fontSize: 8, color: Colors.black54)),
              ]),
            ),
          ],
        ]),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        margin: EdgeInsets.zero,
      ),
    ]);
  }

  Widget _stat(String value, String label, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 9, color: Colors.black54)),
          ]),
        ),
      );
}