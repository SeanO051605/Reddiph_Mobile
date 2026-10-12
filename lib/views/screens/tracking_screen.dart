import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/sos_controller.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/emergency.dart';
import '../../services/open_street_map_api.dart';
import '../widgets/open_street_map.dart';
import 'arrived_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final controller = SosController.I;

  @override
  void initState() {
    super.initState();
    if (controller.stage == EmergencyStage.assigned ||
        controller.stage == EmergencyStage.confirmed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.startTracking();
      });
    }
  }

  void _arrive() {
    controller.markArrived();
    Nav.replace(context, const ArrivedScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: OpenStreetMapView(
              center: OpenStreetMapApi.resident,
              zoom: 15,
              route: [
                OpenStreetMapApi.incidentOne,
                LatLng(14.1165, 120.853),
                LatLng(14.1175, 120.851),
                LatLng(14.1175, 120.849),
                OpenStreetMapApi.resident,
              ],
              markers: [
                OpenStreetMapMarker(
                  point: OpenStreetMapApi.resident,
                  label: 'Your location',
                  color: kSos,
                  icon: Icons.person,
                ),
                OpenStreetMapMarker(
                  point: OpenStreetMapApi.incidentOne,
                  label: 'Kuya Mark · 4 min away',
                  color: kBrand,
                  icon: Icons.support_agent,
                  showLabel: true,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _MapHeader(onBack: () => Navigator.maybePop(context)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ResponderSheet(
              controller: controller,
              onCallResponder: _arrive,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _MapHeader({required this.onBack});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency response',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Brgy. San Isidro · Purok 4',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.my_location, color: kBrand, size: 21),
              ),
            ],
          ),
        ),
      );
}

class _ResponderSheet extends StatelessWidget {
  final SosController controller;
  final VoidCallback onCallResponder;

  const _ResponderSheet({
    required this.controller,
    required this.onCallResponder,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        elevation: 12,
        shadowColor: Colors.black38,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR RESPONDER IS ON THE WAY',
                            style: TextStyle(
                              color: kBrand,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .5,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '4 min',
                            style: TextStyle(
                              fontSize: 30,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'estimated arrival',
                            style:
                                TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    _ResponderAvatar(),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kuya Mark',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'Unit RB-04',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => _ProgressLine(
                    stage: controller.stage,
                  ),
                ),
                const SizedBox(height: 14),
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: controller.stage == EmergencyStage.tracking
                          ? onCallResponder
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: kBrand,
                        disabledBackgroundColor: kGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text(
                        'CALL RESPONDER',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ResponderAvatar extends StatelessWidget {
  const _ResponderAvatar();

  @override
  Widget build(BuildContext context) => Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: kBrand.withAlpha(24),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.support_agent, size: 30, color: kBrand),
      );
}

class _ProgressLine extends StatelessWidget {
  final EmergencyStage stage;
  const _ProgressLine({required this.stage});

  static const _labels = ['Request', 'Assigned', 'En route', 'Arrived'];

  @override
  Widget build(BuildContext context) {
    final current = switch (stage) {
      EmergencyStage.sending => 0,
      EmergencyStage.confirmed => 0,
      EmergencyStage.assigned => 1,
      EmergencyStage.tracking => 2,
      EmergencyStage.arrived || EmergencyStage.completed => 3,
      EmergencyStage.idle => -1,
    };

    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: kMedium,
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i <= current ? kBrand : kGrey,
                    shape: BoxShape.circle,
                  ),
                  child: i < current
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: i <= current ? Colors.white : Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: i <= current ? Colors.black87 : Colors.black45,
                    fontWeight:
                        i == current ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (i < _labels.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 17),
                color: i < current ? kBrand : kGrey,
              ),
            ),
        ],
      ],
    );
  }
}
