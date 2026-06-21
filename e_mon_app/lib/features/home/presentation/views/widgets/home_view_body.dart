import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/core/utils/app_durations.dart';
import 'package:e_mon_app/features/home/data/models/reading_model.dart';
import 'package:e_mon_app/features/home/presentation/managers/chart_range.dart';
import 'package:e_mon_app/features/home/presentation/managers/home_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.containerPaddingDesktop),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: AppSpacing.lg),
                  _LiveChartPanel(state: state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Energy Trend',
                style: AppTextStyles.displayLg.copyWith(fontSize: 40),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Streaming simulated device readings. The chart refreshes every minute from /readings.',
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        const _ReportActions(),
      ],
    );
  }
}

class _ReportActions extends StatelessWidget {
  const _ReportActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.end,
      children: [
        _GhostActionButton(
          icon: Icons.description_outlined,
          label: 'Usage Report',
        ),
        _GhostActionButton(
          icon: Icons.download_outlined,
          label: 'Export Report',
        ),
      ],
    );
  }
}

class _GhostActionButton extends StatelessWidget {
  const _GhostActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _HoverBorder(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.labelCaps),
          ],
        ),
      ),
    );
  }
}

class _LiveChartPanel extends StatelessWidget {
  const _LiveChartPanel({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final readings = state.visibleReadings;

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
            _ChartToolbar(state: state),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 420,
              child: AnimatedSwitcher(
                duration: AppDurations.t500,
                child: _buildChartContent(context, readings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent(BuildContext context, List<ReadingModel> readings) {
    if (state.status == HomeStatus.loading && readings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HomeStatus.failure && readings.isEmpty) {
      return _EmptyChartMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to load live readings',
        message: state.errorMessage ?? 'Check the API server and try again.',
      );
    }

    if (readings.isEmpty) {
      return const _EmptyChartMessage(
        icon: Icons.show_chart_rounded,
        title: 'Waiting for device data',
        message: 'The simulation service will add a new reading each minute.',
      );
    }

    return _TrendLineChart(readings: readings);
  }
}

class _ChartToolbar extends StatelessWidget {
  const _ChartToolbar({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Relative Value', style: AppTextStyles.headlineSm),
                const SizedBox(width: AppSpacing.sm),
                _StatsHoverButton(state: state),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _LiveDot(),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  state.status == HomeStatus.failure
                      ? 'Live sync interrupted'
                      : 'Live sync active',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: state.status == HomeStatus.failure
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        _RangeSelector(selectedRange: state.selectedRange),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selectedRange});

  final ChartRange selectedRange;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Wrap(
          spacing: AppSpacing.xs,
          children: ChartRange.values.map((range) {
            final isSelected = range == selectedRange;
            return InkWell(
              mouseCursor: SystemMouseCursors.click,
              borderRadius: AppRadius.fullBorder,
              onTap: () => context.read<HomeCubit>().changeRange(range),
              child: AnimatedContainer(
                duration: AppDurations.t250,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.transparent,
                  borderRadius: AppRadius.fullBorder,
                ),
                child: Text(
                  range.label,
                  style: AppTextStyles.labelCaps.copyWith(
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatsHoverButton extends StatefulWidget {
  const _StatsHoverButton({required this.state});

  final HomeState state;

  @override
  State<_StatsHoverButton> createState() => _StatsHoverButtonState();
}

class _StatsHoverButtonState extends State<_StatsHoverButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;

  @override
  void dispose() {
    _removeOverlay(updateState: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _showOverlay(),
        onExit: (_) => _removeOverlay(),
        child: AnimatedContainer(
          duration: AppDurations.t250,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.primary.withValues(alpha: 0.14)
                : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.fullBorder,
            border: Border.all(
              color: _isHovered ? AppColors.primary : AppColors.goldBorder,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.query_stats_rounded,
                size: 17,
                color: _isHovered
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Stats',
                style: AppTextStyles.labelCaps.copyWith(
                  color: _isHovered
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      return;
    }

    setState(() => _isHovered = true);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 44),
              child: Align(
                alignment: Alignment.topLeft,
                child: _StatsOverlay(state: widget.state),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay({bool updateState = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted && updateState) {
      setState(() => _isHovered = false);
    }
  }
}

class _StatsOverlay extends StatelessWidget {
  const _StatsOverlay({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final readings = state.visibleReadings;
    final values = readings.map((reading) => reading.relativeValue).toList();
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final average = values.isEmpty ? 0 : total / values.length;
    final peak = values.isEmpty
        ? 0
        : values.reduce((current, next) => current > next ? current : next);

    return Material(
      color: AppColors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.overlay.withValues(alpha: 0.98),
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: AppColors.primary),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: SizedBox(
          width: 310,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Range Statistics', style: AppTextStyles.headlineSm),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${state.selectedRange.label} relative value summary',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _StatsRow(label: 'Readings', value: readings.length.toString()),
                _StatsRow(
                  label: 'Total',
                  value: '${total.toStringAsFixed(2)} kWh',
                ),
                _StatsRow(
                  label: 'Average',
                  value: '${average.toStringAsFixed(2)} kWh',
                ),
                _StatsRow(
                  label: 'Peak',
                  value: '${peak.toStringAsFixed(2)} kWh',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelCaps.copyWith(color: AppColors.mutedText),
          ),
          Text(
            value,
            style: AppTextStyles.dataTabular.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _HoverBorder extends StatefulWidget {
  const _HoverBorder({required this.child});

  final Widget child;

  @override
  State<_HoverBorder> createState() => _HoverBorderState();
}

class _HoverBorderState extends State<_HoverBorder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.t250,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.72),
          borderRadius: AppRadius.regularBorder,
          border: Border.all(
            color: _isHovered ? AppColors.primary : AppColors.goldBorder,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: const Padding(
        padding: EdgeInsets.all(5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(dimension: 8),
        ),
      ),
    );
  }
}

class _TrendLineChart extends StatelessWidget {
  const _TrendLineChart({required this.readings});

  final List<ReadingModel> readings;

  @override
  Widget build(BuildContext context) {
    final values = readings.map((reading) => reading.relativeValue).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final padding = ((maxValue - minValue) * 0.18).clamp(4, 80).toDouble();
    final spots = [
      for (var index = 0; index < readings.length; index++)
        FlSpot(index.toDouble(), readings[index].relativeValue),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (readings.length - 1).toDouble(),
        minY: minValue - padding,
        maxY: maxValue + padding,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: _chartInterval(minValue, maxValue),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border.withValues(alpha: 0.72),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: AppTextStyles.dataTabular.copyWith(
                    color: AppColors.mutedText,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: _bottomInterval(readings.length),
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= readings.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    _formatReadingLabel(readings[index].createdAt),
                    style: AppTextStyles.dataTabular.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.overlay,
            tooltipBorder: const BorderSide(color: AppColors.goldBorder),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final reading = readings[spot.x.toInt()];
                return LineTooltipItem(
                  '${reading.relativeValue.toStringAsFixed(2)} kWh\n${_formatDateTime(reading.createdAt)}',
                  AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.28,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: readings.length <= 16,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: AppColors.onPrimary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.24),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: AppDurations.t500,
    );
  }
}

class _EmptyChartMessage extends StatelessWidget {
  const _EmptyChartMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 42),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.headlineSm),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

double _chartInterval(double minValue, double maxValue) {
  final range = maxValue - minValue;
  if (range <= 0) {
    return 1;
  }
  return range / 4;
}

double _bottomInterval(int count) {
  if (count <= 4) {
    return 1;
  }
  return (count / 4).floorToDouble();
}

String _formatReadingLabel(DateTime value) {
  return '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
}

String _formatDateTime(DateTime value) {
  return '${value.year}-${_twoDigits(value.month)}-${_twoDigits(value.day)} '
      '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
