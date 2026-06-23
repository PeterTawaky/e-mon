import 'dart:io';

import 'package:e_mon_app/features/reports/data/repositories/reports_repo.dart';
import 'package:e_mon_app/features/reports/domain/services/energy_report_calculator.dart';
import 'package:e_mon_app/features/reports/domain/services/report_pdf_service.dart';
import 'package:e_mon_app/features/reports/presentation/managers/reports_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._reportsRepo, this._pdfService)
    : super(ReportsState.initial());

  final ReportsRepo _reportsRepo;
  final ReportPdfService _pdfService;

  void changeKind(ReportKind kind) {
    emit(
      state.copyWith(
        kind: kind,
        status: ReportsStatus.initial,
        clearReport: true,
        clearSavedPath: true,
        clearMessage: true,
      ),
    );
  }

  void changeTierMode(ReportTierMode tierMode) {
    emit(
      state.copyWith(
        tierMode: tierMode,
        status: ReportsStatus.initial,
        clearReport: true,
        clearSavedPath: true,
        clearMessage: true,
      ),
    );
  }

  Future<void> generateReport({
    required EnergyReportRateInput rates,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (state.kind == ReportKind.specific && startDate == null) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          message: 'Choose a start date before generating the report.',
          clearReport: true,
          clearSavedPath: true,
        ),
      );
      return;
    }

    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          message: 'End date must be after the start date.',
          clearReport: true,
          clearSavedPath: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ReportsStatus.loading,
        clearMessage: true,
        clearSavedPath: true,
      ),
    );

    try {
      final now = DateTime.now();
      final isMonthlyReport = state.kind == ReportKind.monthly;
      final reportStartDate = isMonthlyReport
          ? DateTime(now.year, now.month)
          : startDate;
      final reportEndDate = isMonthlyReport
          ? DateTime(now.year, now.month, now.day)
          : endDate;
      final readings = state.kind == ReportKind.monthly
          ? await _reportsRepo.getMonthlyReadings()
          : await _reportsRepo.getRangeReadings(
              startDate: startDate!,
              endDate: endDate,
            );

      final report = EnergyReportCalculator.build(
        kind: state.kind,
        tierMode: state.tierMode,
        readings: readings,
        rates: rates,
        selectedStartDate: reportStartDate,
        selectedEndDate: reportEndDate,
        extractedAt: now,
      );

      emit(
        state.copyWith(
          status: ReportsStatus.success,
          report: report,
          message: readings.isEmpty
              ? 'No readings found for this report period.'
              : null,
          clearSavedPath: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          message: 'Unable to generate report. $error',
          clearReport: true,
          clearSavedPath: true,
        ),
      );
    }
  }

  Future<void> saveAndOpenReport() async {
    final report = state.report;
    if (report == null) {
      return;
    }

    emit(state.copyWith(status: ReportsStatus.saving, clearMessage: true));

    try {
      final File file = await _pdfService.saveReport(report);
      await _pdfService.openReport(file);
      emit(
        state.copyWith(
          status: ReportsStatus.saved,
          savedPath: file.path,
          message: 'Report saved successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          message: 'Unable to save report PDF. $error',
        ),
      );
    }
  }
}
