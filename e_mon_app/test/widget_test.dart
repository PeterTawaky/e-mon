import 'package:e_mon_app/features/home/data/models/reading_model.dart';
import 'package:e_mon_app/features/home/data/repositories/home_repo.dart';
import 'package:e_mon_app/features/home/presentation/views/home_view.dart';
import 'package:e_mon_app/features/tenants/data/models/tenant_model.dart';
import 'package:e_mon_app/features/tenants/data/repositories/tenants_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders live power dashboard', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(
          homeRepo: _FakeHomeRepo(),
          tenantsRepo: _FakeTenantsRepo(),
          enableLiveUpdates: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('WattWise Dashboard'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Latest Accumulative Values'), findsOneWidget);
  });
}

class _FakeTenantsRepo implements TenantsRepo {
  @override
  Future<List<TenantModel>> getTenants() async {
    return [TenantModel(id: 1, user: 'North Tower', createdAt: DateTime.now())];
  }

  @override
  Future<TenantModel> createTenant({
    required String user,
    required String password,
    String? registerNo,
    String? gatewayIp,
    String? email,
    String? phoneNo,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTenant(int id) {
    throw UnimplementedError();
  }
}

class _FakeHomeRepo implements HomeRepo {
  @override
  Future<List<ReadingModel>> getReadings() async {
    final now = DateTime.now();
    return [
      ReadingModel(
        id: 1,
        tenantId: 1,
        componentName: 'Main Power Meter',
        accumulativeValue: 100,
        pastAccumulativeValue: 96,
        relativeValue: 4,
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
      ReadingModel(
        id: 2,
        tenantId: 1,
        componentName: 'Main Power Meter',
        accumulativeValue: 105,
        pastAccumulativeValue: 100,
        relativeValue: 5,
        createdAt: now,
      ),
    ];
  }
}
