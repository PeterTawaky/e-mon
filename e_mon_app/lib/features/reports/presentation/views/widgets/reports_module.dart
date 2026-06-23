import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/core/utils/app_durations.dart';
import 'package:e_mon_app/features/reports/domain/services/energy_report_calculator.dart';
import 'package:e_mon_app/features/reports/presentation/managers/reports_cubit.dart';
import 'package:e_mon_app/features/reports/presentation/managers/reports_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsModule extends StatefulWidget {
  const ReportsModule({super.key});

  @override
  State<ReportsModule> createState() => _ReportsModuleState();
}

class _ReportsModuleState extends State<ReportsModule> {
  final TextEditingController _oneTierRateController = TextEditingController();
  final TextEditingController _onPeakRateController = TextEditingController();
  final TextEditingController _semiPeakRateController = TextEditingController();
  final TextEditingController _offPeakRateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _oneTierRateController.dispose();
    _onPeakRateController.dispose();
    _semiPeakRateController.dispose();
    _offPeakRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerPaddingDesktop),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reports',
                style: AppTextStyles.displayLg.copyWith(fontSize: 40),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Generate branded WattWise consumption reports from live device readings.',
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ReportBuilderPanel(
                state: state,
                oneTierRateController: _oneTierRateController,
                onPeakRateController: _onPeakRateController,
                semiPeakRateController: _semiPeakRateController,
                offPeakRateController: _offPeakRateController,
                startDate: _startDate,
                endDate: _endDate,
                onStartDateChanged: (value) => setState(() {
                  _startDate = value;
                }),
                onEndDateChanged: (value) => setState(() {
                  _endDate = value;
                }),
                onGenerate: () => _generate(state),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.message != null)
                _ReportMessage(
                  message: state.message!,
                  isError: state.status == ReportsStatus.failure,
                ),
              if (state.message != null) const SizedBox(height: AppSpacing.lg),
              if (state.report != null)
                _ReportPreviewPanel(report: state.report!, state: state),
            ],
          ),
        );
      },
    );
  }

  void _generate(ReportsState state) {
    final rates = _parseRates(state.tierMode);
    if (rates == null) {
      _showValidationMessage('Write valid positive rate values first.');
      return;
    }

    context.read<ReportsCubit>().generateReport(
      rates: rates,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  EnergyReportRateInput? _parseRates(ReportTierMode mode) {
    if (mode == ReportTierMode.oneTier) {
      final rate = _parseRate(_oneTierRateController.text);
      if (rate == null) {
        return null;
      }
      return EnergyReportRateInput(
        oneTierRate: rate,
        onPeakRate: rate,
        semiPeakRate: rate,
        offPeakRate: rate,
      );
    }

    final onPeakRate = _parseRate(_onPeakRateController.text);
    final semiPeakRate = _parseRate(_semiPeakRateController.text);
    final offPeakRate = _parseRate(_offPeakRateController.text);
    if (onPeakRate == null || semiPeakRate == null || offPeakRate == null) {
      return null;
    }

    return EnergyReportRateInput(
      oneTierRate: 0,
      onPeakRate: onPeakRate,
      semiPeakRate: semiPeakRate,
      offPeakRate: offPeakRate,
    );
  }

  double? _parseRate(String value) {
    final rate = double.tryParse(value.trim());
    if (rate == null || rate < 0) {
      return null;
    }
    return rate;
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReportBuilderPanel extends StatelessWidget {
  const _ReportBuilderPanel({
    required this.state,
    required this.oneTierRateController,
    required this.onPeakRateController,
    required this.semiPeakRateController,
    required this.offPeakRateController,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onGenerate,
  });

  final ReportsState state;
  final TextEditingController oneTierRateController;
  final TextEditingController onPeakRateController;
  final TextEditingController semiPeakRateController;
  final TextEditingController offPeakRateController;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == ReportsStatus.loading;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.goldBorder),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerLow,
            AppColors.card,
            AppColors.surfaceContainerLowest,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _SegmentedChoice<ReportKind>(
                  label: 'Report type',
                  selectedValue: state.kind,
                  values: ReportKind.values,
                  labelBuilder: (value) => value.label,
                  onChanged: (value) =>
                      context.read<ReportsCubit>().changeKind(value),
                ),
                _SegmentedChoice<ReportTierMode>(
                  label: 'Calculation mode',
                  selectedValue: state.tierMode,
                  values: ReportTierMode.values,
                  labelBuilder: (value) => value.label,
                  onChanged: (value) =>
                      context.read<ReportsCubit>().changeTierMode(value),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _RateFields(
              mode: state.tierMode,
              oneTierRateController: oneTierRateController,
              onPeakRateController: onPeakRateController,
              semiPeakRateController: semiPeakRateController,
              offPeakRateController: offPeakRateController,
            ),
            if (state.kind == ReportKind.specific) ...[
              const SizedBox(height: AppSpacing.lg),
              _DateRangeFields(
                startDate: startDate,
                endDate: endDate,
                onStartDateChanged: onStartDateChanged,
                onEndDateChanged: onEndDateChanged,
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.lg),
              _MonthlyNotice(),
            ],
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: _PremiumActionButton(
                icon: Icons.auto_awesome_rounded,
                label: isLoading ? 'Generating' : 'Generate Report',
                isBusy: isLoading,
                onPressed: isLoading ? null : onGenerate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedChoice<T> extends StatelessWidget {
  const _SegmentedChoice({
    required this.label,
    required this.selectedValue,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final T selectedValue;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.labelCaps),
        const SizedBox(height: AppSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.fullBorder,
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Wrap(
              spacing: AppSpacing.xs,
              children: values.map((value) {
                final isSelected = value == selectedValue;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    borderRadius: AppRadius.fullBorder,
                    onTap: () => onChanged(value),
                    child: AnimatedContainer(
                      duration: AppDurations.t250,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.transparent,
                        borderRadius: AppRadius.fullBorder,
                      ),
                      child: Text(
                        labelBuilder(value),
                        style: AppTextStyles.labelCaps.copyWith(
                          color: isSelected
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _RateFields extends StatelessWidget {
  const _RateFields({
    required this.mode,
    required this.oneTierRateController,
    required this.onPeakRateController,
    required this.semiPeakRateController,
    required this.offPeakRateController,
  });

  final ReportTierMode mode;
  final TextEditingController oneTierRateController;
  final TextEditingController onPeakRateController;
  final TextEditingController semiPeakRateController;
  final TextEditingController offPeakRateController;

  @override
  Widget build(BuildContext context) {
    if (mode == ReportTierMode.oneTier) {
      return SizedBox(
        width: 340,
        child: _RateTextField(
          controller: oneTierRateController,
          label: 'Rate',
          icon: Icons.payments_outlined,
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        SizedBox(
          width: 260,
          child: _RateTextField(
            controller: onPeakRateController,
            label: 'On-Peak Rate',
            icon: Icons.trending_up_rounded,
          ),
        ),
        SizedBox(
          width: 260,
          child: _RateTextField(
            controller: semiPeakRateController,
            label: 'Semi-Peak Rate',
            icon: Icons.show_chart_rounded,
          ),
        ),
        SizedBox(
          width: 260,
          child: _RateTextField(
            controller: offPeakRateController,
            label: 'Off-Peak Rate',
            icon: Icons.trending_down_rounded,
          ),
        ),
      ],
    );
  }
}

class _RateTextField extends StatelessWidget {
  const _RateTextField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: 'rate',
      ),
    );
  }
}

class _DateRangeFields extends StatelessWidget {
  const _DateRangeFields({
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _DatePickerButton(
          label: 'Start Date',
          value: startDate,
          requiredMark: true,
          onPicked: onStartDateChanged,
        ),
        _DatePickerButton(
          label: 'End Date',
          value: endDate,
          onPicked: onEndDateChanged,
          onCleared: () => onEndDateChanged(null),
        ),
      ],
    );
  }
}

class _DatePickerButton extends StatefulWidget {
  const _DatePickerButton({
    required this.label,
    required this.value,
    required this.onPicked,
    this.onCleared,
    this.requiredMark = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPicked;
  final VoidCallback? onCleared;
  final bool requiredMark;

  @override
  State<_DatePickerButton> createState() => _DatePickerButtonState();
}

class _DatePickerButtonState extends State<_DatePickerButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        borderRadius: AppRadius.regularBorder,
        onTap: () => _pickDate(context),
        child: AnimatedContainer(
          duration: AppDurations.t250,
          width: 280,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.regularBorder,
            border: Border.all(
              color: _isHovered ? AppColors.primary : AppColors.goldBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: _isHovered
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.requiredMark ? '${widget.label} *' : widget.label,
                      style: AppTextStyles.labelCaps,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.value == null
                          ? 'Choose date'
                          : _formatUiDate(widget.value!),
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.value != null && widget.onCleared != null)
                IconButton(
                  tooltip: 'Clear date',
                  onPressed: widget.onCleared,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surfaceContainerLow,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onPicked(picked);
    }
  }
}

class _MonthlyNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: AppRadius.regularBorder,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.event_available_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Monthly report uses current month readings automatically. '
                'Start date is the first reading in ${_monthName(now.month)} ${now.year}; '
                'end date is today.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportMessage extends StatelessWidget {
  const _ReportMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.success;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.regularBorder,
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(message, style: AppTextStyles.bodyMd.copyWith(color: color)),
      ),
    );
  }
}

class _ReportPreviewPanel extends StatelessWidget {
  const _ReportPreviewPanel({required this.report, required this.state});

  final EnergyReport report;
  final ReportsState state;

  @override
  Widget build(BuildContext context) {
    final isSaving = state.status == ReportsStatus.saving;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.goldBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.kind.label, style: AppTextStyles.headlineMd),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Extracted ${_formatUiDateTime(report.extractedAt)}',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                _PremiumActionButton(
                  icon: Icons.picture_as_pdf_rounded,
                  label: isSaving ? 'Saving PDF' : 'Save PDF',
                  isBusy: isSaving,
                  onPressed: isSaving
                      ? null
                      : () => context.read<ReportsCubit>().saveAndOpenReport(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _ReportMetricCard(
                  label: 'Company',
                  value: 'HA Technology',
                  icon: Icons.business_rounded,
                ),
                _ReportMetricCard(
                  label: 'Application',
                  value: 'WattWise',
                  icon: Icons.bolt_rounded,
                ),
                _ReportMetricCard(
                  label: 'Readings',
                  value: report.readingsCount.toString(),
                  icon: Icons.sensors_rounded,
                ),
                _ReportMetricCard(
                  label: 'Total charge',
                  value: report.totalCharge.toStringAsFixed(2),
                  icon: Icons.payments_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('Time Period')),
                  DataColumn(label: Text(_reportDateRange(report))),
                  const DataColumn(label: Text('Rate')),
                  const DataColumn(label: Text('Charge')),
                ],
                rows: report.rows.map((row) {
                  return DataRow(
                    cells: [
                      DataCell(Text(row.timePeriod)),
                      DataCell(
                        Text(
                          '${row.summationValue.toStringAsFixed(2)} kWh',
                          style: AppTextStyles.dataTabular.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      DataCell(Text(row.rate.toStringAsFixed(2))),
                      DataCell(Text(row.charge.toStringAsFixed(2))),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (state.savedPath != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Saved to ${state.savedPath}',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  const _ReportMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.regularBorder,
          border: Border.all(color: AppColors.goldBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.labelCaps),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumActionButton extends StatefulWidget {
  const _PremiumActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  State<_PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<_PremiumActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: FilledButton.icon(
        onPressed: widget.onPressed,
        style: FilledButton.styleFrom(
          side: BorderSide(
            color: _isHovered && isEnabled
                ? AppColors.primary
                : AppColors.goldBorder,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        icon: widget.isBusy
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(widget.icon),
        label: Text(widget.label),
      ),
    );
  }
}

String _formatUiDate(DateTime value) {
  return '${_monthName(value.month)} ${value.day}, ${value.year}';
}

String _formatUiDateTime(DateTime value) {
  return '${_formatUiDate(value)} ${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
}

String _reportDateRange(EnergyReport report) {
  if (report.rows.isEmpty) {
    return 'Date Range';
  }
  return report.rows.first.dateRange;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _monthName(int month) {
  return const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}
