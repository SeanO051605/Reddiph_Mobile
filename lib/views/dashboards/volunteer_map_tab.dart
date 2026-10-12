import 'package:flutter/material.dart';
import '../widgets/doctor_widgets.dart';
import '../widgets/open_street_map.dart';
import '../widgets/volunteer_widgets.dart';
import '../../services/open_street_map_api.dart';

class VolunteerMapTab extends StatefulWidget {
  final VoidCallback onBack;
  const VolunteerMapTab({super.key, required this.onBack});

  @override
  State<VolunteerMapTab> createState() => _VolunteerMapTabState();
}

class _VolunteerMapTabState extends State<VolunteerMapTab> {
  bool _offered = false;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned.fill(
        child: OpenStreetMapView(
          radius: 0,
          center: OpenStreetMapApi.resident,
          markers: [
            OpenStreetMapMarker(
              point: OpenStreetMapApi.hospital,
              label: 'District Hospital',
              color: kVol,
              icon: Icons.local_hospital,
            ),
            OpenStreetMapMarker(
              point: OpenStreetMapApi.incidentTwo,
              label: 'Vehicle needed',
              color: Color(0xFF8A3A22),
              icon: Icons.emergency,
            ),
            OpenStreetMapMarker(
              point: OpenStreetMapApi.resident,
              label: 'You',
              color: kVol,
              icon: Icons.person,
            ),
          ],
        ),
      ),
      // Back
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
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ]),
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
            const Align(
              alignment: Alignment.centerRight,
              child: SmallPill(
                  '1.2 km', (bg: Color(0xFFD9D9D9), fg: Colors.black87)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Vehicle needed',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Ambulance unavailable · transport to District Hospital',
                  style: TextStyle(fontSize: 8, color: Colors.black54)),
            ),
            const SizedBox(height: 12),
            const DCard(
              Row(children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: kVol,
                  child: Text('N',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Aling Nena's family",
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w800)),
                        Text('Fall injury, elderly · Purok 7',
                            style:
                                TextStyle(fontSize: 8, color: Colors.black54)),
                      ]),
                ),
              ]),
              margin: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            DCard(
              Column(children: [
                _info('Pickup', 'Purok 7'),
                const Divider(height: 14),
                _info('Destination', 'District Hospital'),
              ]),
              margin: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            VolButton(
              _offered ? 'OFFER SENT' : 'OFFER MY VEHICLE',
              onTap: _offered
                  ? null
                  : () {
                      setState(() => _offered = true);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Your vehicle offer was sent.')));
                    },
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _info(String l, String v) => Row(children: [
        Expanded(
            child: Text(l,
                style: const TextStyle(fontSize: 8, color: Colors.black54))),
        Text(v,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
      ]);
}
