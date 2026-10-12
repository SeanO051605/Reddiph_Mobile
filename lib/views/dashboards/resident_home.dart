import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/sos_controller.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/role.dart';
import '../widgets/common.dart';
import '../screens/tracking_screen.dart';

class ResidentHome extends StatelessWidget {
  final Role role;
  final VoidCallback onSos;
  const ResidentHome({super.key, required this.role, required this.onSos});

  @override
  Widget build(BuildContext context) {
    final p = DashboardController.I.profileFor(role.name);

    // Only _ReportSection listens to the SOS controller, so the header and the
    // SOS button are not rebuilt every time the emergency stage changes.
    return ListView(
      children: [
        Header(p.title, p.subtitle, role.color, p.initial),
        const SizedBox(height: 10),
        _SosButton(onSos: onSos),
        const Padding(
          padding: EdgeInsets.all(14),
          child: Text(
            'Sends your location and reports the emergency\nto the nearest responder team.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Colors.black38),
          ),
        ),
        _ReportSection(role: role),
      ],
    );
  }
}

/// Hold-to-send button: pulses gently while idle, squishes while held, and
/// gives a haptic bump when the hold completes.
class _SosButton extends StatefulWidget {
  final VoidCallback onSos;
  const _SosButton({required this.onSos});

  @override
  State<_SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<_SosButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) => Center(
        child: PulseRing(
          color: kSos,
          size: 220,
          child: Semantics(
            button: true,
            label: 'SOS. Press and hold to send an emergency alert',
            child: GestureDetector(
              onTapDown: (_) => _set(true),
              onTapUp: (_) => _set(false),
              onTapCancel: () => _set(false),
              onLongPress: () {
                HapticFeedback.heavyImpact();
                widget.onSos();
              },
              child: AnimatedScale(
                scale: _down ? .93 : 1,
                duration: Duration(milliseconds: _down ? 120 : 220),
                curve: _down ? Curves.easeOut : Curves.easeOutBack,
                child: const _SosFace(),
              ),
            ),
          ),
        ),
      );
}

class _SosFace extends StatelessWidget {
  const _SosFace();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
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
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              Text('HOLD TO SEND',
                  style: TextStyle(color: Colors.white70, fontSize: 9)),
            ],
          ),
        ),
      );
}

class _ReportSection extends StatelessWidget {
  final Role role;
  const _ReportSection({required this.role});

  @override
  Widget build(BuildContext context) {
    final rp = DashboardController.I.residentReport;
    final sos = SosController.I;

    return ListenableBuilder(
      listenable: sos,
      builder: (context, _) {
        final active = sos.stage != EmergencyStage.idle &&
            sos.stage != EmergencyStage.completed;
        final title = active ? 'Emergency request — Mother' : rp.title;
        final status = active ? sos.status : rp.status;
        final step = active
            ? switch (sos.stage) {
                EmergencyStage.sending => 0,
                EmergencyStage.confirmed => 1,
                EmergencyStage.assigned => 2,
                EmergencyStage.tracking => 2,
                EmergencyStage.arrived => 3,
                _ => rp.step,
              }
            : rp.step;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Section(active ? 'Your emergency request' : 'Your active report'),
            Box(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Pill(status, role.color.withAlpha(77), role.color),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (int i = 0; i < 4; i++) ...[
                        _StepDot(
                          done: i < step,
                          color: i < step
                              ? const Color(0xFF323C3C)
                              : i == step
                                  ? kSos
                                  : Colors.grey,
                        ),
                        if (i < 3)
                          const Expanded(
                            child: SizedBox(
                              height: 2,
                              child: ColoredBox(color: Colors.black26),
                            ),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Box(
              Row(
                children: [
                  Expanded(
                    child: Text(
                      active ? 'Barangay ambulance\n4 min away' : rp.ambulance,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(width: 70, height: 26, color: role.color),
                ],
              ),
            ),
            AnimatedSize(
              duration: kMedium,
              curve: kEase,
              alignment: Alignment.topCenter,
              child: active
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Btn(
                        'VIEW EMERGENCY STATUS',
                        role.color,
                        fontSize: 14,
                        onTap: () => Nav.push(context, const TrackingScreen()),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        );
      },
    );
  }
}

/// Progress dot that animates its colour and pops the check mark in.
class _StepDot extends StatelessWidget {
  final bool done;
  final Color color;
  const _StepDot({required this.done, required this.color});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: kMedium,
        curve: Curves.easeOut,
        width: 16,
        height: 16,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: AnimatedSwitcher(
          duration: kFast,
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: done
              ? const Icon(Icons.check,
                  key: ValueKey('done'), size: 10, color: Colors.white)
              : const SizedBox.shrink(key: ValueKey('todo')),
        ),
      );
}
