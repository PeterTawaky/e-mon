import 'package:e_mon_app/features/home/data/models/reading_model.dart';
import 'package:e_mon_app/features/home/data/repositories/home_repo.dart';
import 'package:e_mon_app/features/home/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders live power dashboard', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(homeRepo: _FakeHomeRepo(), enableLiveUpdates: false),
      ),
    );
    await tester.pump();

    expect(find.text('WattWise Dashboard'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Day'), findsOneWidget);
  });
}

class _FakeHomeRepo implements HomeRepo {
  @override
  Future<List<ReadingModel>> getReadings() async {
    final now = DateTime.now();
    return [
      ReadingModel(
        id: 1,
        componentName: 'Main Power Meter',
        accumulativeValue: 100,
        pastAccumulativeValue: 96,
        relativeValue: 4,
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
      ReadingModel(
        id: 2,
        componentName: 'Main Power Meter',
        accumulativeValue: 105,
        pastAccumulativeValue: 100,
        relativeValue: 5,
        createdAt: now,
      ),
    ];
  }
}
