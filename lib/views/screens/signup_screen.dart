import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/role.dart';

enum _Kind { text, phone, email, password, dropdown }

class _Field {
  final String label;
  final _Kind kind;
  final bool optional;
  const _Field(this.label, [this.kind = _Kind.text, this.optional = false]);
}

class _Config {
  final String title, sub, button, footnote, done;
  final bool approval; // shows the "administrator approval" banner
  final List<_Field> fields;
  const _Config({
    required this.title,
    required this.sub,
    required this.button,
    required this.done,
    required this.fields,
    this.approval = false,
    this.footnote = '',
  });
}

const _barangays = ['Barangay 1', 'Barangay 2', 'Barangay 3', 'Barangay 4'];

const _pw = [_Field('Password', _Kind.password)];
const _pwConfirm = [
  _Field('Password', _Kind.password),
  _Field('Confirm password', _Kind.password),
];

/// Per-role sign-up forms, keyed by [Role.name]. Edit fields / copy here.
final Map<String, _Config> _configs = {
  'Resident': const _Config(
    title: 'Create resident account',
    sub: 'Self-registration for residents',
    button: 'Send Verification Code',
    done: 'Verification code sent to your mobile number.',
    fields: [
      _Field('Full name'),
      _Field('Mobile number', _Kind.phone),
      _Field('Barangay', _Kind.dropdown),
      ..._pwConfirm,
    ],
  ),
  'Responder': const _Config(
    title: 'Request barangay responder access',
    sub: 'Requires administrator approval',
    button: 'Sign Up',
    done: 'Request sent. Your administrator will review it.',
    approval: true,
    fields: [
      _Field('Full name'),
      _Field('Mobile number', _Kind.phone),
      _Field('Barangay', _Kind.dropdown),
      ..._pwConfirm,
    ],
  ),
  'Doctor': const _Config(
    title: 'Request doctor access',
    sub: 'Requires administrator approval',
    button: 'Submit request for approval',
    done: 'Request submitted. Your administrator will review it.',
    footnote: "You'll be notified once your administrator approves access.",
    approval: true,
    fields: [
      _Field('Full name'),
      _Field('PRC license number'),
      _Field('Department'),
      _Field('Hospital email', _Kind.email),
      _Field('Contact number', _Kind.phone),
      ..._pw,
    ],
  ),
  'Nurse': const _Config(
    title: 'Request Nurse access',
    sub: 'Requires administrator approval',
    button: 'Submit request for approval',
    done: 'Request submitted. Your administrator will review it.',
    footnote: "You'll be notified once your administrator approves access.",
    approval: true,
    fields: [
      _Field('Full name'),
      _Field('PRC license number'),
      _Field('Department'),
      _Field('Hospital email', _Kind.email),
      _Field('Contact number', _Kind.phone),
      ..._pw,
    ],
  ),
  'Volunteer': const _Config(
    title: 'Create volunteer account',
    sub: 'Self-registration for community volunteers',
    button: 'Sign Up',
    done: 'Request sent. Your administrator will review it.',
    approval: true,
    fields: [
      _Field('Full name'),
      _Field('Mobile number', _Kind.phone),
      _Field('Barangay', _Kind.dropdown),
      _Field('Vehicle (optional)', _Kind.text, true),
      ..._pwConfirm,
    ],
  ),
};

class SignUpScreen extends StatefulWidget {
  final Role role;
  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _ctrl = <String, TextEditingController>{};
  final _dropdown = <String, String?>{};
  bool _agree = false;
  bool _agreeError = false;

  Role get role => widget.role;

  _Config get cfg =>
      _configs[role.name] ??
      _Config(
        title: 'Create ${role.name.toLowerCase()} account',
        sub: '',
        button: 'Sign Up',
        done: 'Account request sent.',
        fields: const [_Field('Full name'), ..._pwConfirm],
      );

  TextEditingController _c(String label) =>
      _ctrl.putIfAbsent(label, () => TextEditingController());

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate(_Field f, String? v) {
    final value = (v ?? '').trim();
    if (f.optional) return null;
    if (value.isEmpty) return 'Required';
    if (f.kind == _Kind.email && !value.contains('@')) {
      return 'Enter a valid email';
    }
    if (f.kind == _Kind.phone && value.replaceAll(RegExp(r'\D'), '').length < 10) {
      return 'Enter a valid number';
    }
    if (f.kind == _Kind.password && value.length < 6) {
      return 'At least 6 characters';
    }
    if (f.label == 'Confirm password' && value != _c('Password').text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _submit() {
    final ok = _form.currentState!.validate();
    setState(() => _agreeError = !_agree);
    if (!ok || !_agree) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(); // back to the login screen
    messenger.showSnackBar(SnackBar(content: Text(cfg.done)));
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        errorStyle: const TextStyle(fontSize: 10),
        filled: true,
        fillColor: kGrey,
        isDense: true,
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide.none),
      );

  Widget _input(_Field f, bool last) {
    switch (f.kind) {
      case _Kind.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: _dropdown[f.label],
          isExpanded: true,
          decoration: _decoration('Select barangay'),
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          items: [
            for (final b in _barangays) DropdownMenuItem(value: b, child: Text(b)),
          ],
          onChanged: (v) => setState(() => _dropdown[f.label] = v),
          validator: (v) => f.optional || v != null ? null : 'Required',
        );
      default:
        return TextFormField(
          controller: _c(f.label),
          obscureText: f.kind == _Kind.password,
          keyboardType: switch (f.kind) {
            _Kind.phone => TextInputType.phone,
            _Kind.email => TextInputType.emailAddress,
            _ => TextInputType.text,
          },
          textInputAction: last ? TextInputAction.done : TextInputAction.next,
          decoration: _decoration(switch (f.kind) {
            _Kind.phone => '09XXXXXXXXX',
            _Kind.password => 'Enter ${f.label.toLowerCase()}',
            _ => '',
          }),
          validator: (v) => _validate(f, v),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = cfg;
    final tint = Color.alphaBlend(role.color.withAlpha(70), Colors.white);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Form(
          key: _form,
          child: Column(children: [
            const SizedBox(height: 10),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(14)),
              child: Icon(role.icon, color: role.color, size: 26),
            ),
            const SizedBox(height: 12),
            Text(c.title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (c.sub.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(c.sub,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
            const SizedBox(height: 16),
            if (c.approval) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFF6B6B6B),
                    borderRadius: BorderRadius.circular(6)),
                child: const Row(children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        "This role isn't self-registered. Submitting this form "
                        'sends an account request to your administrator for '
                        'approval.',
                        style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
            ],
            for (var i = 0; i < c.fields.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.fields[i].label, style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  _input(c.fields[i], i == c.fields.length - 1),
                ]),
              ),
            Row(children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agree,
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(
                      color: _agreeError ? Colors.red : Colors.black54, width: 1.5),
                  onChanged: (v) => setState(() {
                    _agree = v ?? false;
                    _agreeError = false;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('I agree to the Terms of Use and Data Privacy Notice',
                    style: TextStyle(
                        fontSize: 10,
                        color: _agreeError ? Colors.red : Colors.black87)),
              ),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: role.color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
                onPressed: _submit,
                child: Text(c.button),
              ),
            ),
            const SizedBox(height: 12),
            if (c.footnote.isNotEmpty)
              Text(c.footnote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.black54))
            else
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Text('Already have an account? Log in',
                    style: TextStyle(fontSize: 10, color: Colors.black54)),
              ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}