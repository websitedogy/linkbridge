import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linksbridge/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('intro plays once and then opens Get Started', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LinksBridgeApp()));
    await tester.pump();
    expect(find.text('LinksBridge'), findsOneWidget);
    expect(find.text('Get Started →'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 6500));
    await tester.pumpAndSettle();
    expect(find.text('Find the Right Business Opportunity'), findsOneWidget);
    expect(find.text('Get Started →'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(360, 640), Size(390, 844), Size(412, 915)]) {
    testWidgets(
      'splash has no overflow at ${size.width.toInt()}x${size.height.toInt()} with large text',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(const ProviderScope(child: LinksBridgeApp()));
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.pump(const Duration(milliseconds: 6500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
