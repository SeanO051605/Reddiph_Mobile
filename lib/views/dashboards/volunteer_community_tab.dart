import 'package:flutter/material.dart';
import '../../core/nav.dart';
import '../../models/volunteer_data.dart';
import '../screens/volunteer_post_appreciation.dart';
import '../screens/volunteer_recognition_screen.dart';
import '../widgets/doctor_widgets.dart';
import '../widgets/volunteer_widgets.dart';

/// Volunteer > Community tab: the Appreciation wall.
class VolunteerCommunityTab extends StatefulWidget {
  const VolunteerCommunityTab({super.key});

  @override
  State<VolunteerCommunityTab> createState() => _VolunteerCommunityTabState();
}

class _VolunteerCommunityTabState extends State<VolunteerCommunityTab> {
  static const _filters = ['All', 'Today', 'Earlier'];
  late final List<AppreciationEntry> _wall = VolunteerData.wall();
  String _filter = 'All';
  int _selectedPerson = 0;

  Future<void> _post() async {
    final entry = await showPostAppreciationSheet(context);
    if (entry != null && mounted) setState(() => _wall.insert(0, entry));
  }

  @override
  Widget build(BuildContext context) {
    final shown = _wall.where((e) {
      if (_filter == 'Today') return e.when == 'Today';
      if (_filter == 'Earlier') return e.when != 'Today';
      return true;
    }).toList();

    return ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 110), children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Appreciation wall',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            SizedBox(height: 2),
            Text('Thanks from your community',
                style: TextStyle(fontSize: 8, color: Colors.black54)),
          ]),
        ),
        GestureDetector(
          onTap: _post,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
                color: kSlate, borderRadius: BorderRadius.circular(14)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, size: 10, color: Colors.white),
              SizedBox(width: 2),
              Text('Post',
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 16),

      // Stats card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: kVolGradient, borderRadius: BorderRadius.circular(10)),
        child: const Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('24',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              Text('Kind words you received',
                  style: TextStyle(fontSize: 8, color: Colors.white54)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.star, size: 14, color: kStar),
              SizedBox(width: 3),
              Text('4.8',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
            ]),
            Text('average rating',
                style: TextStyle(fontSize: 8, color: Colors.white54)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),

      // Most appreciated
      Row(children: [
        const Expanded(
          child: Text('Most appreciated',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
        ),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Full list coming soon.'))),
          child: const Text('See all', style: TextStyle(fontSize: 8)),
        ),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        for (int i = 0; i < VolunteerData.people.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _personTile(i)),
        ],
      ]),
      const SizedBox(height: 14),

      // Filter chips
      Wrap(spacing: 6, children: [
        for (final f in _filters)
          GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _filter == f ? kNavy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _filter == f ? kNavy : Colors.black26),
              ),
              child: Text(f,
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: _filter == f ? Colors.white : Colors.black87)),
            ),
          ),
      ]),
      const SizedBox(height: 10),

      for (final e in shown) _entry(e),
      if (shown.isEmpty)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('No appreciation to show',
              style: TextStyle(fontSize: 10, color: Colors.black54)),
        ),
    ]);
  }

  Widget _personTile(int i) {
    final p = VolunteerData.people[i];
    final sel = i == _selectedPerson;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPerson = i);
        Nav.push(context, VolunteerRecognitionScreen(name: p.name));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF8A8DB0) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black26),
        ),
        child: Column(children: [
          CircleAvatar(
            radius: 8,
            backgroundColor: kNavy,
            child: Text(p.initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(p.name,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
          Text(p.thanks,
              style: TextStyle(
                  fontSize: 6,
                  color: sel ? Colors.white70 : Colors.black54)),
        ]),
      ),
    );
  }

  Widget _entry(AppreciationEntry e) => DCard(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(radius: 9, backgroundColor: Color(0xFFD9D9D9)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.name,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800)),
                Text(e.role,
                    style: const TextStyle(fontSize: 7, color: Colors.black54)),
              ]),
            ),
            Stars(e.stars, size: 9),
          ]),
          const SizedBox(height: 8),
          Text('"${e.quote}"', style: const TextStyle(fontSize: 9)),
          const SizedBox(height: 6),
          Text('${e.from} · ${e.when}',
              style: const TextStyle(fontSize: 7, color: Colors.black54)),
        ]),
        margin: const EdgeInsets.only(bottom: 8),
      );
}