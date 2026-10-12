import 'package:flutter/material.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/nav.dart';
import '../screens/case_detail_screen.dart';
import '../screens/report_form_screen.dart';
import '../widgets/common.dart';
import '../widgets/responder_widgets.dart';

/// "SOS queue" tab: every incoming case, filterable by severity.
class ResponderQueueTab extends StatefulWidget {
  const ResponderQueueTab({super.key});

  @override
  State<ResponderQueueTab> createState() => _ResponderQueueTabState();
}

class _ResponderQueueTabState extends State<ResponderQueueTab> {
  static const _filters = ['All', 'Critical', 'Urgent', 'Stable'];
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final c = DashboardController.I;
    final all = c.sosQueue;
    int count(String f) =>
        f == 'All' ? all.length : all.where((q) => q.severity == f).length;
    final shown =
        _filter == 'All' ? all : all.where((q) => q.severity == _filter).toList();
    final p = c.profileFor('Responder');

    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
        children: [
          Row(children: [
            const Expanded(
                child: Text('SOS queue',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            IconButton(
              tooltip: 'File a report',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: () => Nav.push(context, const ReportFormScreen()),
            ),
            CircleAvatar(
                radius: 14,
                backgroundColor: kResponderBrown,
                child: Text(p.initial,
                    style: const TextStyle(color: Colors.white, fontSize: 12))),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final f in _filters)
              GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _filter == f ? kResponderBrown : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _filter == f ? kResponderBrown : Colors.black26),
                  ),
                  child: Text('$f ${count(f)}',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _filter == f ? Colors.white : Colors.black87)),
                ),
              ),
          ]),
          const SizedBox(height: 14),
          if (shown.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                  child: Text('No cases in this group',
                      style: TextStyle(fontSize: 11, color: Colors.black54))),
            ),
          for (final q in shown) _QueueCard(q),
        ]);
  }
}

class _QueueCard extends StatelessWidget {
  final QueueItem q;
  const _QueueCard(this.q);

  @override
  Widget build(BuildContext context) {
    final sev = severityColors(q.severity);
    void open() => Nav.push(context, CaseDetailScreen(item: q));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: open,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: q.critical ? const Color(0xFFD9382B) : Colors.black12,
              width: q.critical ? 1.2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Pill(q.severity, sev.bg, sev.fg),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(q.title,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700)),
              Text('${q.location} · ${q.ago}',
                  style: const TextStyle(fontSize: 8, color: Colors.black54)),
            ])),
            Text(q.distance,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ]),
          if (q.critical) ...[
            const SizedBox(height: 8),
            SizedBox(
                height: 30,
                child: Btn('VIEW CASE', kResponderBrown, fontSize: 9, onTap: open)),
          ],
        ]),
      ),
    );
  }
}