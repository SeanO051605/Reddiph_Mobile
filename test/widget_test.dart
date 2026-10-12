import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reddiph/controllers/sos_controller.dart';
import 'package:reddiph/main.dart';
import 'package:reddiph/models/emergency.dart';
import 'package:reddiph/views/screens/portal_screen.dart';
import 'package:reddiph/views/screens/sos_confirmed_screen.dart';
import 'package:reddiph/views/screens/sos_sending_screen.dart';

void main() {
  testWidgets('Reddiph app launches and displays the portal screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ReddiphApp());

    await tester.pumpAndSettle();

    expect(find.byType(ReddiphApp), findsOneWidget);
    expect(find.byType(PortalScreen), findsOneWidget);
  });

  testWidgets('Portal screen fits on a compact phone viewport without overflow',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: PortalScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(PortalScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SOS sending screen auto-confirms after the 3 second countdown',
      (WidgetTester tester) async {
    SosController.I.reset();
    SosController.I.send();

    await tester.pumpWidget(const MaterialApp(home: SosSendingScreen()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(SosController.I.stage, EmergencyStage.assigned);
    expect(find.byType(SosConfirmedScreen), findsOneWidget);
  });
}

