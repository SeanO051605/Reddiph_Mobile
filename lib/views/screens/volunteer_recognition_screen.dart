import 'package:flutter/material.dart';
import '../widgets/doctor_widgets.dart';
import '../widgets/volunteer_widgets.dart';

/// "Rate <volunteer>" screen: stats, what people appreciate, star rating.
class VolunteerRecognitionScreen extends StatefulWidget {
  final String name;
  const VolunteerRecognitionScreen({super.key, required this.name});

  @override
  State<VolunteerRecognitionScreen> createState() =>
      _VolunteerRecognitionScreenState();
}

class _VolunteerRecognitionScreenState
    extends State<VolunteerRecognitionScreen> {
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    final initial = widget.name.isEmpty ? '?' : widget.name[0];
    return Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.fromLTRB(24, 10, 24, 30), children: [
        Center(
          child: CircleAvatar(
            radius: 28,
            backgroundColor: kVol,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text('Rate ${widget.name}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        ),
        const Center(
          child: Text('Bayanihan volunteer · Verified',
              style: TextStyle(fontSize: 8, color: Colors.black54)),
        ),
        const SizedBox(height: 18),
        Row(children: [
          _stat('★ 4.9', 'Avg. rating'),
          const SizedBox(width: 8),
          _stat('42', 'Assists'),
          const SizedBox(width: 8),
          _stat('12', 'Thanks this month'),
        ]),
        const SizedBox(height: 22),
        const Text('What people appreciate',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _bar('On time', .9),
        _bar('Helpful', .8),
        _bar('Careful driving', .6),
        const SizedBox(height: 22),
        Center(
          child: Stars(_rating,
              size: 24, onChanged: (v) => setState(() => _rating = v)),
        ),
        const SizedBox(height: 18),
        NavyButton('SUBMIT RATING', onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('You rated ${widget.name} $_rating stars.')));
          Navigator.pop(context);
        }),
      ]),
    );
  }

  Widget _stat(String v, String l) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(children: [
            Text(v,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(l,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 7, color: Colors.black54)),
          ]),
        ),
      );

  Widget _bar(String label, double value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(fontSize: 8, color: Colors.black54)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: const Color(0xFFB8BECC),
                valueColor: const AlwaysStoppedAnimation(kNavy),
              ),
            ),
          ),
        ]),
      );
}