import 'package:flutter/material.dart';
import '../../models/doctor_data.dart';
import '../widgets/common.dart';
import '../widgets/doctor_widgets.dart';
import '../widgets/nurse_widgets.dart';

/// Nurse > Cases (incoming): vitals, timeline, clinical note, confirm arrival.
class NurseCaseDetail extends StatefulWidget {
  final DoctorCase item;
  const NurseCaseDetail({super.key, required this.item});

  @override
  State<NurseCaseDetail> createState() => _NurseCaseDetailState();
}

class _NurseCaseDetailState extends State<NurseCaseDetail> {
  final _note = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    final sev = doctorSeverity(it.severity);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 30), children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: kNurse, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(it.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12))),
              SmallPill(it.severity, sev),
            ]),
            Text(it.summary,
                style: const TextStyle(color: Colors.white70, fontSize: 9)),
            const SizedBox(height: 10),
            VitalsRow(
                pulse: it.pulse, spo2: it.spo2, bp: it.bp, blood: it.blood),
          ]),
        ),
        const Section('Case timeline'),
        DCard(
          Column(children: [
            for (int i = 0; i < it.timeline.length; i++) ...[
              if (i > 0) const Divider(height: 14),
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(it.timeline[i].$1,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600)),
                      if (it.timeline[i].$2.isNotEmpty)
                        Text(it.timeline[i].$2,
                            style: const TextStyle(
                                fontSize: 8, color: Colors.black54)),
                    ])),
                Text(it.timeline[i].$3,
                    style: const TextStyle(fontSize: 8, color: Colors.black45)),
              ]),
            ],
            if (it.timeline.isEmpty)
              const Text('No timeline events yet',
                  style: TextStyle(fontSize: 10, color: Colors.black54)),
          ]),
        ),
        const Section('Clinical note'),
        TextField(
          controller: _note,
          minLines: 3,
          maxLines: 6,
          style: const TextStyle(fontSize: 11),
          decoration: InputDecoration(
            hintText: 'Add findings, treatment given, instruction for the ER team.',
            hintStyle: const TextStyle(fontSize: 10, color: Colors.black45),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black12)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black12)),
          ),
        ),
        const SizedBox(height: 14),
        Pressable(
          child: NurseButton(
            _confirmed ? 'ARRIVAL CONFIRMED' : 'CONFIRM ARRIVAL',
            onTap: _confirmed
                ? null
                : () {
                    setState(() => _confirmed = true);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${it.name} arrival confirmed.')));
                  },
          ),
        ),
      ]),
    );
  }
}