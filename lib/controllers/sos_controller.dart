import 'package:flutter/foundation.dart';
import '../models/emergency.dart';

class SosController extends ChangeNotifier {
  SosController._();
  static final I = SosController._();

  EmergencyStage stage = EmergencyStage.idle;
  DateTime? sentAt;

  String get message =>
      'Your location was shared with the nearest responder team.';

  String get status {
    switch (stage) {
      case EmergencyStage.idle:
        return 'Ready';
      case EmergencyStage.sending:
        return 'Sending SOS';
      case EmergencyStage.confirmed:
        return 'SOS confirmed';
      case EmergencyStage.assigned:
        return 'Responder assigned';
      case EmergencyStage.tracking:
        return 'En route';
      case EmergencyStage.arrived:
        return 'Responder arrived';
      case EmergencyStage.completed:
        return 'Case completed';
    }
  }

  void send() {
    if (stage != EmergencyStage.idle &&
        stage != EmergencyStage.completed) {
      return;
    }

    stage = EmergencyStage.sending;
    sentAt = null;
    notifyListeners();
  }

  void confirm() {
    if (stage == EmergencyStage.sending) {
      sentAt = DateTime.now();
      stage = EmergencyStage.confirmed;
      notifyListeners();
    }
  }

  void assignResponder() {
    if (stage == EmergencyStage.confirmed) {
      stage = EmergencyStage.assigned;
      notifyListeners();
    }
  }

  void startTracking() {
    if (stage == EmergencyStage.assigned ||
        stage == EmergencyStage.confirmed) {
      stage = EmergencyStage.tracking;
      notifyListeners();
    }
  }

  void markArrived() {
    if (stage == EmergencyStage.tracking) {
      stage = EmergencyStage.arrived;
      notifyListeners();
    }
  }

  void completeCase() {
    if (stage == EmergencyStage.completed) return;
    stage = EmergencyStage.completed;
    notifyListeners();
  }

  void reset() {
    if (stage == EmergencyStage.idle && sentAt == null) return;
    stage = EmergencyStage.idle;
    sentAt = null;
    notifyListeners();
  }
}
