import 'package:flutter/material.dart';

const kResponderBrown = Color(0xFF7A3A22);
const kResponderOrange = Color(0xFFDF8062);

/// Pill colours for a case severity ('Critical' / 'Urgent' / 'Stable').
({Color bg, Color fg}) severityColors(String severity) => switch (severity) {
      'Critical' => (bg: const Color(0xFFE9B7B1), fg: const Color(0xFF7A1410)),
      'Urgent' => (bg: const Color(0xFFF2E3A6), fg: const Color(0xFF7A5C00)),
      _ => (bg: const Color(0xFFDADADA), fg: const Color(0xFF333333)),
    };
