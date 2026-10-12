import 'package:flutter/material.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/theme.dart';
import '../widgets/doctor_widgets.dart';
import '../widgets/volunteer_widgets.dart';

class VolunteerProfileTab extends StatefulWidget {
  final VoidCallback onLogout;
  const VolunteerProfileTab({super.key, required this.onLogout});

  @override
  State<VolunteerProfileTab> createState() => _VolunteerProfileTabState();
}

class _VolunteerProfileTabState extends State<VolunteerProfileTab> {
  bool _notifications = true;
  bool _available = true;

  @override
  Widget build(BuildContext context) {
    final p = DashboardController.I.profileFor('Volunteer');

    return ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 110), children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            SizedBox(height: 2),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('4.8 ', style: TextStyle(fontSize: 8, color: Colors.black54)),
              Icon(Icons.star, size: 8, color: Colors.black87),
              Text(' Verified volunteer',
                  style: TextStyle(fontSize: 8, color: Colors.black54)),
            ]),
          ]),
        ),
        CircleAvatar(
          radius: 12,
          backgroundColor: kVol,
          child: Text(p.initial,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      ]),
      const SizedBox(height: 20),
      const DCard(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rina Domingo',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
          SizedBox(height: 2),
          Text('Brgy. San Isidro · Vehicle: Toyota Avanza, 4 seats',
              style: TextStyle(fontSize: 8, color: Colors.black87)),
        ]),
        padding: EdgeInsets.all(14),
        margin: EdgeInsets.zero,
      ),
      const SizedBox(height: 22),
      const Text('Settings',
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      DCard(
        Column(children: [
          InkWell(
            onTap: () => setState(() => _notifications = !_notifications),
            child: _row('Notification', _notifications ? 'On' : 'Off'),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: () => setState(() => _available = !_available),
            child: _row('Availability',
                _available ? 'Available now' : 'Unavailable'),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: widget.onLogout,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Log out',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: kSos)),
              ),
            ),
          ),
        ]),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        margin: EdgeInsets.zero,
      ),
    ]);
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w700))),
          Text(value,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
        ]),
      );
}