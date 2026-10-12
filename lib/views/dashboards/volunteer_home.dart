import 'package:flutter/material.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/role.dart';
import '../widgets/common.dart';
import '../widgets/volunteer_widgets.dart';

/// Volunteer > Request tab.
class VolunteerHome extends StatelessWidget {
  final Role role;
  final VoidCallback? onOpenMap;
  const VolunteerHome({super.key, required this.role, this.onOpenMap});

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
    final p = DashboardController.I.profileFor('Volunteer');
    final name = p.title.replaceFirst('Hi, ', '');
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning,'
        : now.hour < 18
            ? 'Good Afternoon,'
            : 'Good Evening,';

    return ListView(padding: const EdgeInsets.only(bottom: 110), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Row(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(greeting, style: const TextStyle(fontSize: 11)),
            Text(name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(p.subtitle,
                style: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.bold)),
          ])),
          CircleAvatar(
              radius: 14,
              backgroundColor: kVol,
              child: Text(p.initial,
                  style: const TextStyle(color: Colors.white, fontSize: 12))),
        ]),
      ),
      // On-duty card
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), gradient: kVolGradient),
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
          const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('4.8',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              SizedBox(width: 4),
              Icon(Icons.star, size: 22, color: Colors.white),
            ]),
            Text('31 assists',
                style: TextStyle(fontSize: 8, color: Colors.white70)),
          ]),
        ]),
      ),
      const Section('Available requests near you'),
      // Vehicle request
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            gradient: kVolGradient, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Vehicle needed — ambulance\nunavailable',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 2),
          const Text('Purok 7 · Fall injury, elderly · 1.2 km',
              style: TextStyle(fontSize: 8, color: Colors.white70)),
          const SizedBox(height: 10),
          VolButton('OFFER MY VEHICLE', light: true, onTap: onOpenMap),
        ]),
      ),
      const SizedBox(height: 8),
      // Report assist request
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: kVolMid, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Report assist requested',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 2),
          const Text('Purok 2 · Family needs help filing SOS',
              style: TextStyle(fontSize: 8, color: Colors.white70)),
          const SizedBox(height: 10),
          VolButton('Assist now',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assist request accepted.')))),
        ]),
      ),
      const Section('Recent feedback'),
      const Box(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.star, size: 14, color: Colors.black87),
        SizedBox(width: 6),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('5.0',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            SizedBox(height: 2),
            Text(
                'Family of Aling Nena: "Rina got us to the health center fast when no ambulance was free. Grateful."',
                style: TextStyle(fontSize: 8, color: Colors.black54)),
          ]),
        ),
      ])),
    ]);
  }
}