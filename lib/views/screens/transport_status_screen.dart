import 'package:flutter/material.dart';
import '../../controllers/dashboard_controller.dart';
import '../widgets/common.dart';
import '../widgets/responder_widgets.dart';

/// Step-by-step transport timeline for an accepted case. The responder taps
/// "Update status" to move to the next step; the time is stamped as it happens.
class TransportStatusScreen extends StatefulWidget {
  final String? title, location;
  final String caseId;
  const TransportStatusScreen(
      {super.key, this.title, this.location, this.caseId = 'A-0142'});

  @override
  State<TransportStatusScreen> createState() => _TransportStatusScreenState();
}

class _TransportStatusScreenState extends State<TransportStatusScreen> {
  static const _steps = [
    'Dispatched',
    'Responding',
    'Patient picked up',
    'En route to hospital',
    'Arrived at hospital',
  ];
  static const _subs = ['Unit RB-04 assigned', 'On the way to the incident'];

  final _times = <String?>['11:16', '11:17', '11:24', null, null];
  int _stage = 2;

  static String _now() {
    final t = TimeOfDay.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _advance() {
    if (_stage >= _steps.length - 1) return;
    setState(() {
      _stage++;
      _times[_stage] = _now();
    });
  }

  Widget _dot(int i) {
    const size = 20.0;
    if (i < _stage) {
      return const CircleAvatar(
          radius: size / 2,
          backgroundColor: kResponderBrown,
          child: Icon(Icons.check, size: 12, color: Colors.white));
    }
    if (i == _stage) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kResponderBrown,
          border: Border.all(color: const Color(0xFFE3C3B8), width: 3),
        ),
        child: const Center(
            child: Icon(Icons.circle, size: 6, color: Colors.white)),
      );
    }
    return const CircleAvatar(
        radius: size / 2, backgroundColor: Color(0xFFB9B9B9));
  }

  @override
  Widget build(BuildContext context) {
    final d = DashboardController.I.dispatch;
    final title = widget.title ?? d.title;
    final location = widget.location ?? d.location;
    final last = _stage >= _steps.length - 1;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('Case ${widget.caseId} · $location',
            style: const TextStyle(fontSize: 9, color: Colors.black54)),
        const SizedBox(height: 28),
        const Text('Transport status',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        for (int i = 0; i < _steps.length; i++)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              _dot(i),
              if (i < _steps.length - 1)
                Container(
                    width: 2,
                    height: 30,
                    color: i < _stage
                        ? kResponderBrown
                        : const Color(0xFFD0D0D0)),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_steps[i],
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: i <= _stage
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: i <= _stage ? Colors.black : Colors.black54)),
                  if (i == _stage)
                    const Text('Current status',
                        style: TextStyle(fontSize: 8, color: Colors.black54))
                  else if (i < _subs.length && i < _stage)
                    Text(_subs[i],
                        style: const TextStyle(
                            fontSize: 8, color: Colors.black54)),
                ]),
              ),
            ),
            if (_times[i] != null)
              Text(_times[i]!,
                  style: const TextStyle(fontSize: 8, color: Colors.black54)),
          ]),
        const SizedBox(height: 20),
        Btn(
          last ? 'CASE COMPLETED' : 'MARK: ${_steps[_stage + 1].toUpperCase()}',
          kResponderBrown,
          disabled: last,
          onTap: _advance,
        ),
      ]),
    );
  }
}