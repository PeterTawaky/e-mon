import 'package:e_mon_app/features/reports/domain/services/energy_report_calculator.dart';

enum ReportsStatus {
  initial,
  loading,
  success,
  saving,
  saved,
  failure;
}

class ReportsState {
  const ReportsState({
    required this.status,
    required this.kind,
    required this.tierMode,
    required this.report,
    required this.savedPath,
    required this.message,
  });

  final ReportsStatus status;
  final ReportKind kind;
  final ReportTierMode tierMode;
  final EnergyReport? report;
  final String? savedPath;
  final String? message;

  factory ReportsState.initial() {
    return const ReportsState(
      status: ReportsStatus.initial,
      kind: ReportKind.specific,
      tierMode: ReportTierMode.oneTier,
      report: null,
      savedPath: null,
      message: null,
    );
  }

  ReportsState copyWith({
    ReportsStatus? status,
    ReportKind? kind,
    ReportTierMode? tierMode,
    EnergyReport? report,
    String? savedPath,
    String? message,
    bool clearReport = false,
    bool clearSavedPath = false,
    bool clearMessage = false,
  }) {
    return ReportsState(
      status: status ?? this.status,
      kind: kind ?? this.kind,
      tierMode: tierMode ?? this.tierMode,
      report: clearReport ? null : report ?? this.report,
      savedPath: clearSavedPath ? null : savedPath ?? this.savedPath,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
