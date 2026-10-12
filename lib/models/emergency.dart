import 'package:flutter/material.dart';

enum EmergencyStage {
  idle,
  sending,
  confirmed,
  assigned,
  tracking,
  arrived,
  completed,
}

class Profile {
  final String title, subtitle, initial;
  const Profile(this.title, this.subtitle, this.initial);
}

class ResidentReport {
  final String title, status, ambulance;
  final int step;
  const ResidentReport(this.title, this.status, this.step, this.ambulance);
}

class QueueItem {
  final String title, location, distance, ago;
  final String severity, patient, reportedBy, vehicle;
  const QueueItem(this.title, this.location, this.distance, this.ago,
      {this.severity = 'Stable',
      this.patient = 'Unknown',
      this.reportedBy = 'Resident SOS',
      this.vehicle = 'Ambulance RB-04'});
  bool get critical => severity == 'Critical';

  /// "Brgy. San Isidro · Fidel R." -> "Brgy. San Isidro"
  String get area => location.split(' · ').first;
}

class PatientCase {
  final String title, location, eta, severity;
  final String? pulse, spo2, bp;
  const PatientCase(this.title, this.location, this.eta, this.severity,
      {this.pulse, this.spo2, this.bp});
  bool get critical => severity == 'Critical';
}

class ReviewCase {
  final String title, detail;
  const ReviewCase(this.title, this.detail);
}

class ResourceStat {
  final String label, value, sub;
  final Color color;
  const ResourceStat(this.label, this.value, this.sub, this.color);
}

class ChecklistItem {
  final String label;
  bool done;
  ChecklistItem(this.label, this.done);
}

class AssistRequest {
  final String title, detail, action;
  const AssistRequest(this.title, this.detail, this.action);
}

class UserFeedback {
  final String rating, text;
  const UserFeedback(this.rating, this.text);
}
