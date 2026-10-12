import 'package:flutter/material.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/nav.dart';
import '../../services/open_street_map_api.dart';
import '../screens/case_detail_screen.dart';
import '../screens/transport_status_screen.dart';
import '../widgets/common.dart';
import '../widgets/open_street_map.dart';
import '../widgets/responder_widgets.dart';

class ResponderHome extends StatelessWidget {
  const ResponderHome({super.key});
  static const brown = kResponderBrown;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final c = DashboardController.I;
    final p = c.profileFor('Responder');
    final d = c.dispatch;
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning,'
        : now.hour < 18
            ? 'Good Afternoon,'
            : 'Good Evening,';

    return ListView(padding: const EdgeInsets.only(bottom: 90), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(greeting, style: const TextStyle(fontSize: 11)),
                Text(p.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(p.subtitle,
                    style: const TextStyle(fontSize: 9, color: Colors.black54)),
              ])),
          CircleAvatar(
              radius: 14,
              backgroundColor: brown,
              child: Text(p.initial,
                  style: const TextStyle(color: Colors.white, fontSize: 12))),
        ]),
      ),
      // On-duty card
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
              colors: [Color(0xFF7A3A22), Color(0xFF9A5238)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('On Duty',
                    style: TextStyle(fontSize: 9, color: Colors.white70)),
                const SizedBox(height: 14),
                Text(now.day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                    '${_months[now.month - 1]} ${now.year}, ${_days[now.weekday - 1]}',
                    style: const TextStyle(fontSize: 9, color: Colors.white)),
                Text(TimeOfDay.fromDateTime(now).format(context),
                    style: const TextStyle(fontSize: 9, color: Colors.white70)),
              ])),
          const Icon(Icons.shield, size: 34, color: Colors.white70),
        ]),
      ),
      const Section('Active case'),
      // Active case card
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: brown, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          Text(d.location,
              style: const TextStyle(fontSize: 9, color: Colors.white70)),
          const SizedBox(height: 10),
          const OpenStreetMapView(
            height: 90,
            markers: [
              OpenStreetMapMarker(
                point: OpenStreetMapApi.incidentOne,
                label: 'Active case',
                icon: Icons.emergency,
              ),
              OpenStreetMapMarker(
                point: OpenStreetMapApi.hospital,
                label: 'District Hospital',
                icon: Icons.local_hospital,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Btn('OPEN ROUTING', kResponderOrange,
              onTap: () => Nav.push(context, const TransportStatusScreen())),
        ]),
      ),
      const Section('Incoming SOS queue'),
      Box(Column(children: [
        for (int i = 0; i < c.sosQueue.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          InkWell(
            onTap: () =>
                Nav.push(context, CaseDetailScreen(item: c.sosQueue[i])),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                const Icon(Icons.circle, size: 8, color: brown),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(c.sosQueue[i].title,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(c.sosQueue[i].location,
                          style: const TextStyle(
                              fontSize: 9, color: Colors.black54)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(c.sosQueue[i].distance,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                  Text(c.sosQueue[i].ago,
                      style:
                          const TextStyle(fontSize: 9, color: Colors.black54)),
                ]),
              ]),
            ),
          ),
        ]
      ])),
    ]);
  }
}
