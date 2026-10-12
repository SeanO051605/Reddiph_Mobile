import 'package:flutter/material.dart';

class Role {
  final String name, desc, loginTitle, loginSub;
  final Color color;
  final IconData icon;
  final List<String> fields;
  const Role(this.name, this.desc, this.color, this.icon, this.loginTitle,
      this.loginSub, this.fields);
}

const roles = <Role>[
  Role('Resident', 'Reports own emergency,\nviews status only', Color(0xFF4B3F9E),
      Icons.person, 'Resident login', 'Report your own emergency',
      ['Mobile number', 'Password']),
  Role('Responder', 'SOS, dispatch,\ntransport, field routing', Color(0xFF7A3A22),
      Icons.shield, 'Barangay Responder login',
      '',
      ['Responder ID', 'Password']),
  Role('Doctor', 'Case review, patient records,\narrival confirm', Color(0xFF3F3339),
      Icons.medical_services, 'Doctor login',
      'Don Salvador Benedicto Memorial\nDistrict Hospital',
      ['Hospital staff ID', 'Password']),
  Role('Nurse', 'Resource prep, incoming\npatient monitoring', Color(0xFF323C3C),
      Icons.local_hospital, 'Nurse login',
      'Don Salvador Benedicto Memorial\nDistrict Hospital',
      ['Hospital staff ID', 'Password']),
  Role('Volunteer', 'Supplementary field support', Color(0xFF263140),
      Icons.volunteer_activism, 'Volunteer login', 'Supplementary field support',
      ['Volunteer ID', 'Password']),
];

