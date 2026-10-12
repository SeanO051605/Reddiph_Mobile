import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/sos_controller.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/emergency.dart';
import '../widgets/common.dart';
import '../widgets/volunteer_widgets.dart';
import 'sos_sending_screen.dart';
import 'tracking_screen.dart';

/// Volunteer > SOS: hold the big button to send, and see your active report.
class VolunteerSosScreen extends StatelessWidget {
  const VolunteerSosScreen({super.key});

  void _send(BuildContext context) {
    HapticFeedback.heavyImpact();
    SosController.I.send();
    Nav.push(context, const SosSendingScreen());
  }

  @override
  Widget build(BuildContext context) {
    final sos = SosController.I;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 30), children: [
        const SizedBox(height: 10),
        Center(
          child: PulseRing(
            color: kSos,
            size: 220,
            child: GestureDetector(
              onLongPress: () => _send(context),
              child: const DecoratedBox(
                decoration: BoxDecoration(color: kSos, shape: BoxShape.circle),
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('SOS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      Text('HOLD TO SEND',
                          style: TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            'Sends your location and reports the emergency\nto the nearest responder team.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Colors.black38),
          ),
        ),
        const Text('Your active report',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: sos,
          builder: (context, _) {
            final active = sos.stage != EmergencyStage.idle &&
                sos.stage != EmergencyStage.completed;
            final step = active
                ? switch (sos.stage) {
                    EmergencyStage.sending => 0,
                    EmergencyStage.confirmed => 1,
                    EmergencyStage.assigned => 2,
                    EmergencyStage.tracking => 2,
                    EmergencyStage.arrived => 3,
                    _ => -1,
                  }
                : -1;

            return Column(children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: Text(active ? 'Emergency request' : 'No active report',
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    Pill(active ? sos.status : '--', const Color(0xFFD9D9D9),
                        Colors.black87),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    for (int i = 0; i < 4; i++) ...[
                      if (i > 0)
                        Expanded(
                          child: Container(
                              height: 2,
                              color: i <= step ? kVol : Colors.black12),
                        ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= step ? kVol : Colors.black26,
                        ),
                      ),
                    ],
                  ]),
                ]),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(active ? 'Responder on the way' : '--',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    width: 110,
                    child: Btn(
                      'VIEW STATUS',
                      kVol,
                      fontSize: 9,
                      disabled: !active,
                      onTap: () => Nav.push(context, const TrackingScreen()),
                    ),
                  ),
                ]),
              ),
            ]);
          },
        ),
      ]),
    );
  }
}