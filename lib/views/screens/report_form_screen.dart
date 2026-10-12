import 'package:flutter/material.dart';
import '../widgets/common.dart';
import '../widgets/responder_widgets.dart';

/// "What's happening?" report form: pick a type, describe it, confirm location.
class ReportFormScreen extends StatefulWidget {
  final Color color;
  const ReportFormScreen({super.key, this.color = kResponderBrown});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  static const _types = ['Medical', 'Fire', 'Accident', 'Other'];
  final _who = TextEditingController();
  final _what = TextEditingController();
  String? _type;

  @override
  void dispose() {
    _who.dispose();
    _what.dispose();
    super.dispose();
  }

  void _send() {
    final messenger = ScaffoldMessenger.of(context);
    if (_type == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text("Choose what's happening first.")));
      return;
    }
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Report sent.')));
  }

  InputDecoration _box(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 10, color: Colors.black38),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: widget.color)),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(t,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
        const Text("What's happening?",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(children: [
          for (final t in _types)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: t == _types.last ? 0 : 6),
                child: GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _type == t ? color : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: _type == t ? color : Colors.black26),
                    ),
                    child: Text(t,
                        style: TextStyle(
                            fontSize: 8,
                            color: _type == t ? Colors.white : Colors.black87)),
                  ),
                ),
              ),
            ),
        ]),
        _label('Who is affected?'),
        TextField(
            controller: _who,
            style: const TextStyle(fontSize: 11),
            decoration: _box('e.g. 1 adult, elderly, conscious')),
        _label('What happened?'),
        TextField(
            controller: _what,
            minLines: 3,
            maxLines: 5,
            style: const TextStyle(fontSize: 11),
            decoration: _box(
                'What happened, when did it start, anything the responder should know')),
        _label('Location'),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(children: [
            Icon(Icons.location_on_outlined, size: 20, color: color),
            const SizedBox(width: 8),
            const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Brgy. San Isidro, Purok 4',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              Text('Near the covered court',
                  style: TextStyle(fontSize: 8, color: Colors.black54)),
            ])),
            TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () {},
              child: const Text('Change',
                  style: TextStyle(fontSize: 8, color: Colors.black87)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Pressable(
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6))),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Photo attachments are not available in the demo.'))),
              icon: const Icon(Icons.photo_camera, size: 14),
              label: const Text('ATTACH A PHOTO',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
            height: 44,
            child: Btn('SEND REPORT', color, fontSize: 11, onTap: _send)),
      ]),
    );
  }
}