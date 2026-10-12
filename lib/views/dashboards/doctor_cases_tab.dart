import 'package:flutter/material.dart';
import '../../core/nav.dart';
import '../../models/doctor_data.dart';
import '../screens/doctor_case_detail.dart';
import '../widgets/doctor_widgets.dart';

class DoctorCasesTab extends StatefulWidget {
  const DoctorCasesTab({super.key});

  @override
  State<DoctorCasesTab> createState() => _DoctorCasesTabState();
}

class _DoctorCasesTabState extends State<DoctorCasesTab> {
  String _filter = 'Incoming';
  String _query = '';

  bool _match(DoctorCase c) =>
      _query.isEmpty ||
      c.name.toLowerCase().contains(_query) ||
      c.summary.toLowerCase().contains(_query);

  @override
  Widget build(BuildContext context) {
    const all = DoctorData.cases;
    int count(String f) => all.where((c) => c.status == f).length;
    final filters = {
      'Incoming': count('Incoming'),
      'In ER': 3,
      'Done': 6,
    };
    final urgency = DoctorData.urgency.where(_match).toList();
    final review = DoctorData.review.where(_match).toList();

    return ListView(padding: const EdgeInsets.only(bottom: 110), children: [
      Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [kNavy, kNavy2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 28),
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
                    color: _filter == e.key ? kSlate : Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _filter == e.key
                            ? Colors.white54
                            : Colors.transparent),
                  ),
                  child: Text('${e.key} ${e.value}',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _filter == e.key
                              ? Colors.white
                              : Colors.white70)),
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
      _label('Sorted by urgency'),
      if (_filter == 'Incoming')
        for (final c in urgency) _row(context, c)
      else
        _empty(),
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
      onTap: () => Nav.push(context, DoctorCaseDetail(item: c)),
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