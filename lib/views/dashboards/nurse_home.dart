import 'package:flutter/material.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/doctor_data.dart';
import '../screens/nurse_case_detail.dart';
import '../widgets/common.dart';
import '../widgets/nurse_widgets.dart';

/// Nurse > Home tab.
class NurseHome extends StatelessWidget {
  const NurseHome({super.key});

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];
  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final c = DashboardController.I;
    final p = c.profileFor('Nurse');
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning,'
        : now.hour < 18
            ? 'Good Afternoon,'
            : 'Good Evening,';
    final critical = DoctorData.cases.first;
    final next = DoctorData.cases[1];

    return ListView(padding: const EdgeInsets.only(bottom: 110), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Row(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(greeting, style: const TextStyle(fontSize: 11)),
            Text(p.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(p.subtitle,
                style: const TextStyle(fontSize: 9, color: Colors.black54)),
          ])),
          CircleAvatar(
              radius: 14,
              backgroundColor: kNurse,
              child: Text(p.initial,
                  style: const TextStyle(color: Colors.white, fontSize: 12))),
        ]),
      ),
      // On-duty card
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), gradient: kNurseGradient),
        child: Row(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('On Duty',
                style: TextStyle(fontSize: 9, color: Colors.white70)),
            const SizedBox(height: 14),
            Text(now.day.toString().padLeft(2, '0'),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('${_months[now.month - 1]} ${now.year}, ${_days[now.weekday - 1]}',
                style: const TextStyle(fontSize: 9, color: Colors.white)),
            Text(TimeOfDay.fromDateTime(now).format(context),
                style: const TextStyle(fontSize: 9, color: Colors.white70)),
          ])),
        ]),
      ),
      const Section('Incoming patients'),
      GestureDetector(
        onTap: () => Nav.push(context, NurseCaseDetail(item: critical)),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: kNurse, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text.rich(TextSpan(children: [
                const TextSpan(
                    text: 'ETA ',
                    style: TextStyle(fontSize: 9, color: Colors.white70)),
                TextSpan(
                    text: '${critical.eta.replaceAll(' min', '')} MINS',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: kSos)),
              ])),
            ),
            const Text('Vehicular collision — Patient 1',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const Text('Purok 3, near covered court',
                style: TextStyle(fontSize: 9, color: Colors.white70)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                _vital('Heart Rate', critical.pulse, 'bpm'),
                const SizedBox(
                    height: 34, child: VerticalDivider(color: Colors.white38)),
                _vital('SpO2', critical.spo2, '%'),
                const SizedBox(
                    height: 34, child: VerticalDivider(color: Colors.white38)),
                _vital('BP', critical.bp, 'mmHg'),
              ]),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => Nav.push(context, NurseCaseDetail(item: next)),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: kNurseMid, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Expanded(
                child: Text('Fall injury — Aling Nena\nETA ${next.eta}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white))),
            const Pill('Stable', Color(0xFF8DB59A), Colors.white),
          ]),
        ),
      ),
      const Section('Case review'),
      Box(Column(children: [
        for (int i = 0; i < c.reviewCases.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(c.reviewCases[i].title,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            subtitle: Text(c.reviewCases[i].detail,
                style: const TextStyle(fontSize: 9)),
            trailing: const Icon(Icons.chevron_right, size: 16),
            onTap: () => Nav.push(
                context, NurseCaseDetail(item: DoctorData.review.first)),
          ),
        ]
      ])),
    ]);
  }

  Widget _vital(String label, String value, String unit) => Expanded(
        child: Column(children: [
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(unit, style: const TextStyle(fontSize: 8, color: Colors.white70)),
        ]),
      );
}