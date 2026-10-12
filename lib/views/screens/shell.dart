import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/sos_controller.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/demo_data.dart';
import '../../models/emergency.dart';
import '../dashboards/doctor_home.dart';
import '../dashboards/nurse_home.dart';
import '../dashboards/resident_home.dart';
import '../dashboards/responder_home.dart';
import '../dashboards/volunteer_home.dart';
import '../widgets/common.dart';
import '../widgets/open_street_map.dart';
import '../../services/open_street_map_api.dart';
import 'portal_screen.dart';
import 'resident_status_map_screen.dart';
import 'sos_sending_screen.dart';
import 'tracking_screen.dart';
import '../dashboards/responder_queue.dart';

import '../screens/doctor_shell.dart';
import 'nurse_shell.dart';
import 'volunteer_shell.dart';

const _residentColor = Color(0xFF4B3F9E);

class Shell extends StatefulWidget {
  final int initialTab;

  const Shell({super.key, this.initialTab = 0});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final role = AuthController.I.role!;
  late int tab = widget.initialTab;
  late final bool _isResident = role.name == 'Resident';

  // Role never changes while the shell is alive, so build these once.
  static const _responderDestinations = <Widget>[
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(
        icon: Icon(Icons.format_list_bulleted), label: 'Queue'),
    NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
    NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Calendar'),
    NavigationDestination(icon: Icon(Icons.account_circle), label: 'Profile'),
  ];

  late final List<Widget> _destinations = role.name == 'Responder'
      ? _responderDestinations
      : [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: role.name == 'Volunteer' ? 'Request' : 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: _isResident ? 'Status' : 'History',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ];
  void _sendSos() {
    if (_isResident) {
      final sos = SosController.I;
      if (sos.stage == EmergencyStage.idle ||
          sos.stage == EmergencyStage.completed) {
        sos.send();
      }
      if (sos.stage == EmergencyStage.sending) sos.confirm();
      if (sos.stage == EmergencyStage.confirmed) sos.assignResponder();
      if (sos.stage == EmergencyStage.assigned) sos.startTracking();
      Nav.push(context, const TrackingScreen());
      return;
    }

    SosController.I.send();
    Nav.push(context, const SosSendingScreen());
  }

  void _logout() {
    AuthController.I.logout();
    Nav.resetTo(context, const PortalScreen());
  }

  void _selectTab(int index) {
    if (index == tab) return;
    HapticFeedback.selectionClick();
    setState(() => tab = index);
  }

  Widget _residentBody() {
    switch (tab) {
      case 1:
        return const ResidentStatusHome();
      case 2:
        return const ResidentProfileHome(roleColor: _residentColor);
      default:
        return ResidentHome(role: role, onSos: _sendSos);
    }
  }

  Widget _responderBody() {
    switch (tab) {
      case 1:
        return const ResponderQueueTab();
      case 2:
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Map',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: OpenStreetMapView(
                radius: 10,
                markers: [
                  for (int i = 0; i < DemoData.sosQueue.length; i++)
                    OpenStreetMapMarker(
                      point: switch (i) {
                        0 => OpenStreetMapApi.incidentOne,
                        1 => OpenStreetMapApi.incidentTwo,
                        _ => OpenStreetMapApi.incidentThree,
                      },
                      label: DemoData.sosQueue[i].title,
                      color: role.color,
                      icon: Icons.emergency,
                    ),
                ],
              ),
            ),
          ]),
        );
      case 3:
        return const Center(
            child: Text('No scheduled shifts',
                style: TextStyle(fontSize: 11, color: Colors.black54)));
      case 4:
        return Center(
          child: Pressable(
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: role.color),
              onPressed: _logout,
              child: const Text('Log out'),
            ),
          ),
        );
      default:
        return const ResponderHome();
    }
  }

  Widget _body() {
    if (_isResident) return _residentBody();
    if (role.name == 'Responder') return _responderBody();

    if (tab == 1) {
      return const Center(child: Text('No history yet'));
    }

    if (tab == 2) {
      return Center(
        child: Pressable(
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: role.color),
            onPressed: _logout,
            child: const Text('Log out'),
          ),
        ),
      );
    }

    switch (role.name) {
      case 'Responder':
        return const ResponderHome();
      case 'Doctor':
        return const DoctorHome();
      case 'Nurse':
        return const NurseHome();
      default:
        return VolunteerHome(role: role);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role.name == 'Doctor') return const DoctorShell();
    if (role.name == 'Nurse') return const NurseShell();
    if (role.name == 'Volunteer') return const VolunteerShell();

    final showFab = !_isResident || tab == 2;
    // ...rest stays the same

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: expandLayout,
          child: KeyedSubtree(key: ValueKey<int>(tab), child: _body()),
        ),
      ),
      // One FAB that scales in/out instead of two copy-pasted ones popping in.
      floatingActionButton: ExcludeSemantics(
        excluding: !showFab,
        child: IgnorePointer(
          ignoring: !showFab,
          child: AnimatedScale(
            scale: showFab ? 1 : 0,
            duration: kMedium,
            curve: showFab ? Curves.easeOutBack : Curves.easeIn,
            child: FloatingActionButton(
              heroTag: null, // stops a Hero flight between old/new Shell
              backgroundColor: kSos,
              shape: const CircleBorder(),
              onPressed: _sendSos,
              child: const Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        animationDuration: const Duration(milliseconds: 300),
        onDestinationSelected: _selectTab,
        destinations: _destinations,
      ),
    );
  }
}

class ResidentStatusHome extends StatelessWidget {
  const ResidentStatusHome({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SosController.I;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final active = controller.stage != EmergencyStage.idle &&
            controller.stage != EmergencyStage.completed;

        return AnimatedSwitcher(
          duration: kMedium,
          layoutBuilder: expandLayout,
          child: active
              ? _ActiveStatus(
                  key: const ValueKey('active'),
                  status: controller.status,
                )
              : const _EmptyStatus(key: ValueKey('empty')),
        );
      },
    );
  }
}

class _EmptyStatus extends StatelessWidget {
  const _EmptyStatus({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 54, color: Colors.black26),
              SizedBox(height: 14),
              Text(
                'No active emergency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Your active emergency status will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
}

class _ActiveStatus extends StatelessWidget {
  final String status;
  const _ActiveStatus({super.key, required this.status});

  static const _card = BoxDecoration(
    border: Border.fromBorderSide(BorderSide(color: Colors.black12)),
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const Text(
            'Emergency Status',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Case #RS-2026-01 · Brgy. San Isidro',
            style: TextStyle(fontSize: 10, color: Colors.black54),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 270,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const OpenStreetMapView(
                    radius: 0,
                    center: OpenStreetMapApi.resident,
                    markers: [
                      OpenStreetMapMarker(
                        point: OpenStreetMapApi.resident,
                        label: 'Emergency location',
                        color: kSos,
                        icon: Icons.emergency,
                      ),
                      OpenStreetMapMarker(
                        point: OpenStreetMapApi.hospital,
                        label: 'District Hospital',
                        color: kBrand,
                        icon: Icons.local_hospital,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(10),
                      child: IconButton(
                        tooltip: 'View full-screen map',
                        onPressed: () =>
                            Nav.push(context, const ResidentStatusMapScreen()),
                        icon: const Icon(Icons.fullscreen, color: kBrand),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const DecoratedBox(
            decoration: _card,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barangay ambulance · RB-04',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Kuya Mark is on the way',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '4 min',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: kMedium,
            layoutBuilder: leftLayout,
            child: Text(
              status,
              key: ValueKey(status),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Btn(
            'VIEW LIVE STATUS',
            kBrand,
            fontSize: 14,
            onTap: () => Nav.push(context, const TrackingScreen()),
          ),
        ],
      );
}

class ResidentProfileHome extends StatelessWidget {
  final Color roleColor;

  const ResidentProfileHome({
    super.key,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Sean Occena · Brgy. San Isidro',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 14,
              backgroundColor: _residentColor,
              child: Text(
                'S',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Household members',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _profileCard('Sean Occena', '24 · Main household member', roleColor),
        _profileCard('Aries Occena', '43 · Household member', roleColor),
        const SizedBox(height: 6),
        Pressable(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, size: 17),
            label: const Text('Add household member'),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Emergency contacts',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _profileCard(
          'Brgy. San Isidro Health Center',
          'Barangay hotline',
          roleColor,
          icon: Icons.local_hospital,
        ),
        _profileCard(
          'Juan Ramos',
          'Next of kin',
          roleColor,
          icon: Icons.phone,
        ),
        const SizedBox(height: 18),
        const Text(
          'Settings',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _setting('Notifications', 'On'),
        _setting('Language', 'Filipino'),
        _setting('Log out', '', danger: true, onTap: () {
          AuthController.I.logout();
          Nav.resetTo(context, const PortalScreen());
        }),
      ],
    );
  }

  Widget _profileCard(
    String name,
    String detail,
    Color color, {
    IconData icon = Icons.person,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Colors.black12)),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: Icon(icon, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 8, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _setting(
    String title,
    String value, {
    bool danger = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: danger ? kSos : Colors.black,
                  fontWeight: danger ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}
