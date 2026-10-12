import 'package:flutter/material.dart';
import '../../core/nav.dart';
import '../../models/emergency.dart';
import '../../services/open_street_map_api.dart';
import '../widgets/common.dart';
import '../widgets/open_street_map.dart';
import '../widgets/responder_widgets.dart';
import 'transport_status_screen.dart';

/// One SOS case: where it is, who it is, and the accept / request-vehicle actions.
class CaseDetailScreen extends StatelessWidget {
  final QueueItem item;
  const CaseDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final sev = severityColors(item.severity);
    final rows = <(String, String)>[
      ('Patient', item.patient),
      ('Location', item.area),
      ('Reported by', item.reportedBy),
      ('Recommended vehicle', item.vehicle),
    ];
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Reported ${item.ago} · ${item.distance} away',
                        style: const TextStyle(
                            fontSize: 9, color: Colors.black54)),
                  ])),
              Pill(item.severity, sev.bg, sev.fg),
            ]),
            const SizedBox(height: 14),
            const OpenStreetMapView(
              height: 150,
              radius: 8,
              center: OpenStreetMapApi.incidentOne,
              markers: [
                OpenStreetMapMarker(
                  point: OpenStreetMapApi.incidentOne,
                  label: 'Emergency location',
                  icon: Icons.emergency,
                ),
                OpenStreetMapMarker(
                  point: OpenStreetMapApi.resident,
                  label: 'Your location',
                  color: kResponderOrange,
                  icon: Icons.person,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(children: [
                for (int i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: Colors.black12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    child: Row(children: [
                      Expanded(
                          child: Text(rows[i].$1,
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.black54))),
                      Text(rows[i].$2,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            Btn('ACCEPT CASE', kResponderBrown,
                onTap: () => Nav.replace(
                    context,
                    TransportStatusScreen(
                        title: item.title, location: item.area))),
            const SizedBox(height: 8),
            Pressable(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Another vehicle requested.'))),
                  child: const Text('REQUEST ANOTHER VEHICLE',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ]),
    );
  }
}
