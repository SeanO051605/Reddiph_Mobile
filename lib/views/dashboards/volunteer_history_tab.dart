import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/volunteer_data.dart';
import '../widgets/doctor_widgets.dart';

class VolunteerHistoryTab extends StatelessWidget {
  final VoidCallback onBack;
  const VolunteerHistoryTab({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final days = <String>[];
    for (final h in VolunteerData.history) {
      if (!days.contains(h.day)) days.add(h.day);
    }

    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 110), children: [
      Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: onBack,
        ),
      ),
      const SizedBox(height: 6),
      const Text('My assistance history',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
      const Text('31 completed · 4.8 average rating',
          style: TextStyle(fontSize: 8, color: Colors.black54)),
      const SizedBox(height: 22),
      for (final d in days) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Text(d,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
        ),
        for (final h in VolunteerData.history.where((e) => e.day == d))
          DCard(
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(h.title,
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(h.detail,
                      style:
                          const TextStyle(fontSize: 7, color: Colors.black54)),
                ]),
              ),
              Text(h.rating,
                  style: const TextStyle(
                      fontSize: 8, fontWeight: FontWeight.w800)),
              const SizedBox(width: 3),
              const Icon(Icons.star, size: 9, color: kSos),
            ]),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        const SizedBox(height: 8),
      ],
    ]);
  }
}