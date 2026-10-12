import 'package:flutter/material.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/doctor_data.dart';
import '../screens/nurse_case_detail.dart';
import '../widgets/doctor_widgets.dart';
import '../widgets/nurse_widgets.dart';
import '../widgets/open_street_map.dart';
import '../../services/open_street_map_api.dart';

class NurseMapTab extends StatefulWidget {
  final VoidCallback onBack;
  const NurseMapTab({super.key, required this.onBack});

  @override
  State<NurseMapTab> createState() => _NurseMapTabState();
}

class _NurseMapTabState extends State<NurseMapTab> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final incoming =
        DoctorData.cases.where((c) => c.status == 'Incoming').toList();
    final sel = incoming[_selected];
    final next = incoming[(_selected + 1) % incoming.length];
    final sev = doctorSeverity(sel.severity);

    return Stack(children: [
      Positioned.fill(
        child: OpenStreetMapView(
          radius: 0,
          center: OpenStreetMapApi.hospital,
          markers: [
            const OpenStreetMapMarker(
              point: OpenStreetMapApi.hospital,
              label: 'District Hospital',
              color: kNurse,
              icon: Icons.local_hospital,
            ),
            for (int i = 0; i < incoming.length; i++)
              OpenStreetMapMarker(
                point: i == 0
                    ? OpenStreetMapApi.incidentOne
                    : OpenStreetMapApi.incidentTwo,
                label: 'Responder ${i + 3}',
                color: i == _selected ? kSos : kNurse,
                icon: Icons.emergency,
                onTap: () => setState(() => _selected = i),
              ),
          ],
        ),
      ),
      // Back button
      Positioned(
        left: 16,
        top: 16,
        child: GestureDetector(
          onTap: widget.onBack,
          child: const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white,
            child: Icon(Icons.chevron_left, size: 18, color: Colors.black),
          ),
        ),
      ),
      // Live chip
      Positioned(
        right: 16,
        top: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.circle, size: 7),
            SizedBox(width: 5),
            Text('Live',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
      // Bottom sheet
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 56,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.centerRight,
                child: SmallPill(sel.severity, sev)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${sel.summary.split(' · ').first} · ${sel.name}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${sel.unit} · Reserved ${sel.bay}',
                  style: const TextStyle(fontSize: 8, color: Colors.black54)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _stat(sel.eta, 'Arrives ${sel.arrives}', big: true),
              const SizedBox(width: 10),
              _stat(sel.distance, 'Distance', big: true, red: false),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _stat(sel.name, 'Selected', small: true),
              const SizedBox(width: 10),
              _stat('${next.name} · ${next.eta}', 'Next', small: true),
            ]),
            const SizedBox(height: 12),
            NurseButton('OPEN PATIENT RECORD',
                onTap: () => Nav.push(context, NurseCaseDetail(item: sel))),
          ]),
        ),
      ),
    ]);
  }

  Widget _stat(String v, String l,
          {bool big = false, bool small = false, bool red = true}) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(small ? l : v,
                style: small
                    ? const TextStyle(fontSize: 8, color: Colors.black54)
                    : TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: red && big && v.contains('min')
                            ? kSos
                            : Colors.black)),
            Text(small ? v : l,
                style: small
                    ? const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)
                    : const TextStyle(fontSize: 8, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
}