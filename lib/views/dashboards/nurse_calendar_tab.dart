import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/doctor_data.dart';
import '../widgets/doctor_widgets.dart';
import '../widgets/nurse_widgets.dart';

class NurseCalendarTab extends StatefulWidget {
  const NurseCalendarTab({super.key});

  @override
  State<NurseCalendarTab> createState() => _NurseCalendarTabState();
}

class _NurseCalendarTabState extends State<NurseCalendarTab> {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];
  static const _dow = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  DateTime _month = DateTime(2026, 10);
  int _selected = 5;

  Color _shiftColor(ShiftType t) => switch (t) {
        ShiftType.day => kNurse,
        ShiftType.night => kNurseLight,
        ShiftType.onCall => kSos,
        ShiftType.off => const Color(0xFFD9D9D9),
      };

  String _shiftTitle(ShiftType t) => switch (t) {
        ShiftType.day => 'Day shift · ER',
        ShiftType.night => 'Night shift · ER',
        ShiftType.onCall => 'On call · ER',
        ShiftType.off => 'Off duty',
      };

  void _shift(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_month.year, _month.month, 1);
    final daysIn = DateTime(_month.year, _month.month + 1, 0).day;
    final lead = first.weekday - 1; // Monday-first
    final rows = ((lead + daysIn) / 7).ceil();
    final selDay = _selected > daysIn ? daysIn : _selected;
    final selDate = DateTime(_month.year, _month.month, selDay);

    return ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 110), children: [
      const Text('Calendar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Text('Your duty schedule · District Hospital',
          style: TextStyle(fontSize: 9, color: Colors.black54)),
      const SizedBox(height: 16),
      Row(children: [
        IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _shift(-1)),
        Expanded(
            child: Center(
                child: Text('${_months[_month.month - 1]} ${_month.year}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)))),
        IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _shift(1)),
      ]),
      Row(children: [
        for (final d in _dow)
          Expanded(
              child: Center(
                  child: Text(d,
                      style: const TextStyle(
                          fontSize: 8, color: Colors.black54)))),
      ]),
      const SizedBox(height: 8),
      for (int r = 0; r < rows; r++)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            for (int col = 0; col < 7; col++) _cell(r * 7 + col - lead + 1, daysIn),
          ]),
        ),
      const SizedBox(height: 6),
      Wrap(spacing: 12, runSpacing: 6, children: [
        _legend('Day', kNurse),
        _legend('Night', kNurseLight),
        _legend('On Call', kSos),
        _legend('Off', const Color(0xFFD9D9D9)),
      ]),
      const SizedBox(height: 18),
      Text('${_weekdays[selDate.weekday - 1]} ${selDate.day} ${_months[selDate.month - 1]}',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      DCard(Column(children: [
        Row(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_shiftTitle(DoctorData.shiftFor(selDate.day)),
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            const Text('06:00 to 14:00 · Bay 1 to 4',
                style: TextStyle(fontSize: 8, color: Colors.black54)),
          ])),
          const SmallPill('On Duty', (bg: kStableBg, fg: Colors.white)),
        ]),
        const Divider(height: 18),
        const Align(
          alignment: Alignment.centerLeft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('With you',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            Text('Nurse Reyes, Nurse Cruz, Dr. Santos',
                style: TextStyle(fontSize: 8, color: Colors.black54)),
          ]),
        ),
      ])),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black26, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shift swap requested.'))),
        child: const Text('REQUEST SHIFT SWAP',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      ),
    ]);
  }

  Widget _cell(int day, int daysIn) {
    if (day < 1 || day > daysIn) {
      return const Expanded(child: SizedBox(height: 34));
    }
    final sel = day == _selected;
    final t = DoctorData.shiftFor(day);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selected = day),
        child: SizedBox(
          height: 34,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: sel ? kNurse : Colors.transparent,
                  borderRadius: BorderRadius.circular(5)),
              child: Text('$day',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : Colors.black)),
            ),
            const SizedBox(height: 3),
            Container(width: 16, height: 3, color: _shiftColor(t)),
          ]),
        ),
      ),
    );
  }

  Widget _legend(String t, Color c) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 14, height: 3, color: c),
        const SizedBox(width: 4),
        Text(t, style: const TextStyle(fontSize: 8)),
      ]);
}