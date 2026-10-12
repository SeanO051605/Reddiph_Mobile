import 'package:flutter/material.dart';
import '../../core/nav.dart';
import '../../models/doctor_data.dart';
import '../screens/nurse_case_detail.dart';
import '../widgets/doctor_widgets.dart';
import '../widgets/nurse_widgets.dart';

/// Nurse > Cases tab: dark header with filters + search, urgency list.
class NurseCasesTab extends StatefulWidget {
  final VoidCallback onBack;
  const NurseCasesTab({super.key, required this.onBack});

  @override
  State<NurseCasesTab> createState() => _NurseCasesTabState();
}

class _NurseCasesTabState extends State<NurseCasesTab> {
  String _filter = 'En route';
  String _query = '';

  bool _match(DoctorCase c) =>
      _query.isEmpty ||
      c.name.toLowerCase().contains(_query) ||
      c.summary.toLowerCase().contains(_query);

  @override
  Widget build(BuildContext context) {
    final urgency = DoctorData.urgency.where(_match).toList();
    final review = DoctorData.review.where(_match).toList();
    final filters = {
      'En route': DoctorData.urgency.length,
      'Arrived': DoctorData.review.length,
    };

    return ListView(padding: const EdgeInsets.only(bottom: 110), children: [
      Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [kNurse, kNurse2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            GestureDetector(
              onTap: widget.onBack,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white24,
                child: Icon(Icons.chevron_left, size: 16, color: Colors.white),
              ),
            ),
            const Spacer(),
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white24,
              child: Icon(Icons.tune, size: 13, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 22),
          const Text('Cases',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const Text('District Hospital · Today',
              style: TextStyle(color: Colors.white60, fontSize: 9)),
          const SizedBox(height: 12),
          Wrap(spacing: 6, children: [
            for (final e in filters.entries)
              GestureDetector(
                onTap: () => setState(() => _filter = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _filter == e.key ? Colors.white : Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${e.key} ${e.value}',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color:
                              _filter == e.key ? kNurse : Colors.white70)),
                ),
              ),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              style: const TextStyle(fontSize: 10),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 16),
                hintText: 'Search name or complaint',
                hintStyle: const TextStyle(fontSize: 9, color: Colors.black45),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      if (_filter == 'En route') ...[
        _label('Sorted by urgency'),
        for (final c in urgency) _row(context, c),
        if (urgency.isEmpty) _empty(),
      ],
      _label('Needs your review'),
      for (final c in review) _row(context, c),
      if (review.isEmpty) _empty(),
    ]);
  }

  Widget _empty() => const Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Text('No cases to show',
            style: TextStyle(fontSize: 10, color: Colors.black54)),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: Text(t,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      );

  Widget _row(BuildContext context, DoctorCase c) {
    final sev = doctorSeverity(c.severity);
    final dot = c.critical
        ? const Color(0xFF7A1410)
        : c.needsReview
            ? const Color(0xFFD9A93B)
            : Colors.black87;
    return GestureDetector(
      onTap: () => Nav.push(context, NurseCaseDetail(item: c)),
      child: DCard(
        Row(children: [
          Icon(Icons.circle, size: 8, color: dot),
          const SizedBox(width: 10),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            Text(c.summary,
                style: const TextStyle(fontSize: 8, color: Colors.black54)),
          ])),
          SmallPill(c.severity, sev),
        ]),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      ),
    );
  }
}