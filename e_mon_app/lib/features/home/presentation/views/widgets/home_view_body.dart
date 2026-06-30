import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/core/routes/app_routes.dart';
import 'package:e_mon_app/core/services/networking/dio_consumer.dart';
import 'package:e_mon_app/core/utils/app_assets.dart';
import 'package:e_mon_app/core/utils/app_durations.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/devices_module.dart';
import 'package:e_mon_app/features/home/data/models/reading_model.dart';
import 'package:e_mon_app/features/home/presentation/managers/chart_range.dart';
import 'package:e_mon_app/features/home/presentation/managers/home_cubit.dart';
import 'package:e_mon_app/features/reports/data/repositories/reports_repo_impl.dart';
import 'package:e_mon_app/features/reports/domain/services/energy_report_calculator.dart';
import 'package:e_mon_app/features/reports/domain/services/report_pdf_service.dart';
import 'package:e_mon_app/features/reports/presentation/managers/reports_cubit.dart';
import 'package:e_mon_app/features/reports/presentation/views/widgets/reports_module.dart';
import 'package:e_mon_app/features/admins/data/repositories/admins_repo_impl.dart';
import 'package:e_mon_app/features/admins/presentation/managers/admins_cubit.dart';
import 'package:e_mon_app/features/tenants/data/models/tenant_model.dart';
import 'package:e_mon_app/features/tenants/data/repositories/tenants_repo.dart';
import 'package:e_mon_app/features/tenants/data/repositories/tenants_repo_impl.dart';
import 'package:e_mon_app/features/tenants/presentation/managers/tenants_cubit.dart';
import 'package:e_mon_app/features/tenants/presentation/views/widgets/tenants_module.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key, required this.tenantsRepo});

  final TenantsRepo tenantsRepo;

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  final ValueNotifier<_MenuDestination> _selectedDestination = ValueNotifier(
    _MenuDestination.dashboard,
  );
  ReportKind _selectedReportKind = ReportKind.specific;

  @override
  void dispose() {
    _selectedDestination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<_MenuDestination>(
          valueListenable: _selectedDestination,
          builder: (context, selectedDestination, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isCompact =
                    constraints.maxWidth < AppSizes.minDesktopWidth;
                final content = _DashboardContent(
                  selectedDestination: selectedDestination,
                  selectedReportKind: _selectedReportKind,
                  onReportSelected: _openReport,
                  tenantsRepo: widget.tenantsRepo,
                );

                if (isCompact) {
                  return Column(
                    children: [
                      _TopMenuBar(
                        selectedDestination: selectedDestination,
                        onDestinationSelected: _selectDestination,
                      ),
                      Expanded(child: content),
                    ],
                  );
                }

                return Row(
                  children: [
                    _SideMenu(
                      selectedDestination: selectedDestination,
                      onDestinationSelected: _selectDestination,
                    ),
                    Expanded(child: content),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _selectDestination(_MenuDestination destination) {
    if (destination == _MenuDestination.logout) {
      context.go(AppRoutes.loginView);
      return;
    }
    _selectedDestination.value = destination;
  }

  void _openReport(ReportKind kind) {
    _selectedReportKind = kind;
    _selectedDestination.value = _MenuDestination.reports;
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.selectedDestination,
    required this.selectedReportKind,
    required this.onReportSelected,
    required this.tenantsRepo,
  });

  final _MenuDestination selectedDestination;
  final ReportKind selectedReportKind;
  final ValueChanged<ReportKind> onReportSelected;
  final TenantsRepo tenantsRepo;

  @override
  Widget build(BuildContext context) {
    if (selectedDestination == _MenuDestination.admins) {
      return BlocProvider(
        create: (_) => AdminsCubit(AdminsRepoImpl(DioConsumer()))..loadAdmins(),
        child: const _AdminsModule(),
      );
    }

    if (selectedDestination == _MenuDestination.tenants) {
      return BlocProvider(
        create: (_) =>
            TenantsCubit(TenantsRepoImpl(DioConsumer()))..loadTenants(),
        child: const TenantsModule(),
      );
    }

    if (selectedDestination == _MenuDestination.liveMonitoring) {
      return const _LiveMonitoringModule();
    }

    if (selectedDestination == _MenuDestination.reports) {
      return BlocProvider(
        create: (_) {
          final cubit = ReportsCubit(
            ReportsRepoImpl(DioConsumer()),
            ReportPdfService(),
          );
          cubit.changeKind(selectedReportKind);
          return cubit;
        },
        child: const ReportsModule(),
      );
    }

    if (selectedDestination == _MenuDestination.devices) {
      return const DevicesModule();
    }

    if (selectedDestination != _MenuDestination.dashboard) {
      return _ComingSoonModule(destination: selectedDestination);
    }

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerPaddingDesktop),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onReportSelected: onReportSelected),
              const SizedBox(height: AppSpacing.lg),
              _LiveChartPanel(state: state, tenantsRepo: tenantsRepo),
            ],
          ),
        );
      },
    );
  }
}

enum _MenuDestination {
  dashboard('Dashboard', Icons.dashboard_rounded),
  liveMonitoring('Live Monitoring', Icons.monitor_heart_rounded),
  devices('Devices', Icons.electrical_services_rounded),
  landlords('Landlords', Icons.apartment_rounded),
  tenants('Tenants', Icons.group_rounded),
  reports('Reports', Icons.description_rounded),
  billing('Billing', Icons.receipt_long_rounded),
  alerts('Alerts', Icons.notifications_active_rounded),
  admins('Admins', Icons.admin_panel_settings_rounded),
  settings('Settings', Icons.settings_rounded),
  logout('Logout', Icons.logout_rounded);

  const _MenuDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _SideMenu extends StatelessWidget {
  const _SideMenu({
    required this.selectedDestination,
    required this.onDestinationSelected,
  });

  final _MenuDestination selectedDestination;
  final ValueChanged<_MenuDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _MenuBrand(),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView.separated(
                itemCount: _MenuDestination.values.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final destination = _MenuDestination.values[index];
                  return _MenuItem(
                    destination: destination,
                    isSelected: destination == selectedDestination,
                    onTap: () => onDestinationSelected(destination),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopMenuBar extends StatelessWidget {
  const _TopMenuBar({
    required this.selectedDestination,
    required this.onDestinationSelected,
  });

  final _MenuDestination selectedDestination;
  final ValueChanged<_MenuDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MenuBrand(compact: true),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final destination in _MenuDestination.values) ...[
                    _MenuItem(
                      destination: destination,
                      isSelected: destination == selectedDestination,
                      onTap: () => onDestinationSelected(destination),
                      isCompact: true,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuBrand extends StatelessWidget {
  const _MenuBrand({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compact ? 40 : 48,
          height: compact ? 40 : 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.36),
            ),
          ),
          child: Image.asset(Assets.imagesAppLogo, fit: BoxFit.contain),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WattWise', style: AppTextStyles.headlineSm),
            Text(
              'Power intelligence',
              style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuItem extends StatefulWidget {
  const _MenuItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  final _MenuDestination destination;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isHovered;
    final isLogout = widget.destination == _MenuDestination.logout;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AppRadius.lgBorder,
        child: AnimatedContainer(
          duration: AppDurations.t250,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? AppSpacing.md : AppSpacing.md,
            vertical: widget.isCompact ? AppSpacing.sm : AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.16)
                : _isHovered
                ? AppColors.surfaceContainerHigh.withValues(alpha: 0.72)
                : AppColors.transparent,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.transparent,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: widget.isCompact
                ? MainAxisSize.min
                : MainAxisSize.max,
            children: [
              Icon(
                widget.destination.icon,
                size: 20,
                color: isLogout
                    ? AppColors.error
                    : isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.destination.label,
                style: AppTextStyles.bodyMd.copyWith(
                  color: isLogout
                      ? AppColors.error
                      : isActive
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonModule extends StatelessWidget {
  const _ComingSoonModule({required this.destination});

  final _MenuDestination destination;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.42),
                    ),
                  ),
                  child: Icon(
                    destination.icon,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(destination.label, style: AppTextStyles.headlineMd),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  destination == _MenuDestination.logout
                      ? 'Logout flow will be connected when authentication is ready.'
                      : 'This module is reserved for future work.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminsModule extends StatefulWidget {
  const _AdminsModule();

  @override
  State<_AdminsModule> createState() => _AdminsModuleState();
}

class _AdminsModuleState extends State<_AdminsModule> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _userFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _userFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminsCubit, AdminsState>(
      listener: (context, state) {
        if (state.status == AdminsStatus.success && state.message != null) {
          _userController.clear();
          _passwordController.clear();
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerPaddingDesktop),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Admins',
                style: AppTextStyles.displayLg.copyWith(fontSize: 40),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create dashboard admins and review existing admin access.',
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _AdminCreationPanel(
                userController: _userController,
                passwordController: _passwordController,
                userFocusNode: _userFocusNode,
                passwordFocusNode: _passwordFocusNode,
                state: state,
                onSubmit: _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              _AdminsListPanel(state: state),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    context.read<AdminsCubit>().createAdmin(
      user: _userController.text,
      password: _passwordController.text,
    );
  }
}

class _AdminCreationPanel extends StatelessWidget {
  const _AdminCreationPanel({
    required this.userController,
    required this.passwordController,
    required this.userFocusNode,
    required this.passwordFocusNode,
    required this.state,
    required this.onSubmit,
  });

  final TextEditingController userController;
  final TextEditingController passwordController;
  final FocusNode userFocusNode;
  final FocusNode passwordFocusNode;
  final AdminsState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.status == AdminsStatus.submitting;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FocusTraversalGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Generate New Admin', style: AppTextStyles.headlineSm),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: userController,
                      focusNode: userFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'User',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      onSubmitted: (_) => passwordFocusNode.requestFocus(),
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      onSubmitted: (_) => onSubmit(),
                    ),
                  ),
                  SizedBox(
                    height: AppSizes.buttonHeight,
                    child: FilledButton.icon(
                      onPressed: isSubmitting ? null : onSubmit,
                      icon: isSubmitting
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded),
                      label: Text(isSubmitting ? 'Creating' : 'Create Admin'),
                    ),
                  ),
                ],
              ),
              if (state.message != null) ...[
                const SizedBox(height: AppSpacing.md),
                _AdminsMessage(
                  message: state.message!,
                  isError: state.status == AdminsStatus.failure,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminsMessage extends StatelessWidget {
  const _AdminsMessage({required this.message, required this.isError});

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
        child: Text(
          message,
          style: AppTextStyles.bodyMd.copyWith(color: color),
        ),
      ),
    );
  }
}

class _AdminsListPanel extends StatelessWidget {
  const _AdminsListPanel({required this.state});

  final AdminsState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Admins', style: AppTextStyles.headlineSm),
                Text(
                  '${state.admins.length} admins',
                  style: AppTextStyles.labelCaps,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.status == AdminsStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (state.admins.isEmpty)
              _EmptyChartMessage(
                icon: Icons.admin_panel_settings_rounded,
                title: 'No admins yet',
                message: 'Create the first admin above.',
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Admin')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: state.admins.map((admin) {
                    return DataRow(
                      cells: [
                        DataCell(Text(admin.user)),
                        DataCell(Text(_formatDate(admin.createdAt))),
                        DataCell(
                          _DeleteUserButton(
                            userName: admin.user,
                            onConfirmed: () => context
                                .read<AdminsCubit>()
                                .deleteAdmin(admin.id),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeleteUserButton extends StatefulWidget {
  const _DeleteUserButton({required this.userName, required this.onConfirmed});

  final String userName;
  final VoidCallback onConfirmed;

  @override
  State<_DeleteUserButton> createState() => _DeleteUserButtonState();
}

class _DeleteUserButtonState extends State<_DeleteUserButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: IconButton(
        tooltip: 'Delete user',
        onPressed: () => _confirmDelete(context),
        icon: Icon(
          Icons.delete_outline_rounded,
          color: _isHovered ? AppColors.error : AppColors.onSurfaceVariant,
        ),
        style: IconButton.styleFrom(
          backgroundColor: _isHovered
              ? AppColors.error.withValues(alpha: 0.12)
              : AppColors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.regularBorder,
            side: BorderSide(
              color: _isHovered
                  ? AppColors.error.withValues(alpha: 0.52)
                  : AppColors.border,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Admin'),
          content: Text(
            'Are you sure you want to delete admin "${widget.userName}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      widget.onConfirmed();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onReportSelected});

  final ValueChanged<ReportKind> onReportSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 760),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(Assets.imagesAppLogo, height: 80),
                    Expanded(
                      child: Text(
                        'WattWise Dashboard',
                        style: AppTextStyles.displayLg.copyWith(fontSize: 40),
                        softWrap: true,
                      ),
                    ),
                  ],
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
        ),
        _ReportActions(onReportSelected: onReportSelected),
      ],
    );
  }
}

class _ReportActions extends StatelessWidget {
  const _ReportActions({required this.onReportSelected});

  final ValueChanged<ReportKind> onReportSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.end,
      children: [
        _GhostActionButton(
          icon: Icons.description_outlined,
          label: 'Specific Report',
          onTap: () => onReportSelected(ReportKind.specific),
        ),
        _GhostActionButton(
          icon: Icons.download_outlined,
          label: 'Monthly Report',
          onTap: () => onReportSelected(ReportKind.monthly),
        ),
      ],
    );
  }
}

class _GhostActionButton extends StatelessWidget {
  const _GhostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: _HoverBorder(
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
        ),
      ),
    );
  }
}

class _LiveMonitoringModule extends StatefulWidget {
  const _LiveMonitoringModule();

  @override
  State<_LiveMonitoringModule> createState() => _LiveMonitoringModuleState();
}

class _LiveMonitoringModuleState extends State<_LiveMonitoringModule> {
  late final Future<List<TenantModel>> _tenantsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tenantsFuture = TenantsRepoImpl(DioConsumer()).getTenants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerPaddingDesktop),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Monitoring',
                        style: AppTextStyles.displayLg.copyWith(fontSize: 40),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Live trend charts for each tenant BTU meter.',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _RangeSelector(selectedRange: state.selectedRange),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _formatPeriodLabel(state.selectedRange),
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FutureBuilder<List<TenantModel>>(
                future: _tenantsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 360,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 360,
                      child: _EmptyChartMessage(
                        icon: Icons.wifi_off_rounded,
                        title: 'Unable to load tenants',
                        message:
                            'Live monitoring charts are created from tenants.',
                      ),
                    );
                  }

                  final tenants = snapshot.data ?? const <TenantModel>[];
                  final filteredTenants = _filterTenants(tenants);
                  if (tenants.isEmpty) {
                    return const SizedBox(
                      height: 360,
                      child: _EmptyChartMessage(
                        icon: Icons.group_rounded,
                        title: 'No tenant charts yet',
                        message:
                            'Create tenants to generate one live chart each.',
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LiveMonitoringControls(
                        controller: _searchController,
                        tenantCount: tenants.length,
                        visibleCount: filteredTenants.length,
                        onChanged: (value) {
                          setState(() => _searchQuery = value.trim());
                        },
                        onClear: _searchQuery.isEmpty
                            ? null
                            : () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (filteredTenants.isEmpty)
                        const SizedBox(
                          height: 260,
                          child: _EmptyChartMessage(
                            icon: Icons.search_off_rounded,
                            title: 'No tenants match',
                            message: 'Adjust the search text and try again.',
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                                _liveMonitoringCrossAxisCount(
                                  constraints.maxWidth,
                                );

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredTenants.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: AppSpacing.md,
                                    crossAxisSpacing: AppSpacing.md,
                                    mainAxisExtent: 340,
                                  ),
                              itemBuilder: (context, index) {
                                return _TenantLiveChartPanel(
                                  tenant: filteredTenants[index],
                                  state: state,
                                );
                              },
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<TenantModel> _filterTenants(List<TenantModel> tenants) {
    final query = _searchQuery.toLowerCase();
    if (query.isEmpty) {
      return tenants;
    }
    return tenants
        .where((tenant) => tenant.user.toLowerCase().contains(query))
        .toList();
  }
}

int _liveMonitoringCrossAxisCount(double width) {
  if (width >= 1380) {
    return 4;
  }
  if (width >= 1040) {
    return 3;
  }
  if (width >= 680) {
    return 2;
  }
  return 1;
}

class _LiveMonitoringControls extends StatelessWidget {
  const _LiveMonitoringControls({
    required this.controller,
    required this.tenantCount,
    required this.visibleCount,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final int tenantCount;
  final int visibleCount;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 360,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  labelText: 'Search tenants',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: onClear == null
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: onClear,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            Text(
              '$visibleCount of $tenantCount charts',
              style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TenantLiveChartPanel extends StatelessWidget {
  const _TenantLiveChartPanel({required this.tenant, required this.state});

  final TenantModel tenant;
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final readings = state.readings
        .where((reading) => reading.tenantId == tenant.id)
        .toList();
    final points = _buildChartPoints(readings, state.selectedRange);
    final visibleReadings = readings.where((reading) {
      final start = state.selectedRange.startDate(DateTime.now());
      return !reading.createdAt.isBefore(start);
    }).toList();
    final total = visibleReadings.fold<double>(
      0,
      (sum, reading) => sum + reading.relativeValue,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tenant.user,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineSm,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _TenantMetricPill(
                  label: 'Readings',
                  value: visibleReadings.length.toString(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'BTU meter trend',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(1)} kWh',
                  style: AppTextStyles.dataTabular.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppDurations.t500,
                child: _buildTenantChartContent(readings, points),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantChartContent(
    List<ReadingModel> readings,
    List<_ChartPoint> points,
  ) {
    if (state.status == HomeStatus.loading && state.readings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HomeStatus.failure && state.readings.isEmpty) {
      return _EmptyChartMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to load live readings',
        message: state.errorMessage ?? 'Check the API server and try again.',
      );
    }

    if (readings.isEmpty) {
      return _EmptyChartMessage(
        icon: Icons.show_chart_rounded,
        title: 'Waiting for ${tenant.user} readings',
        message: 'This tenant has a BTU meter but no readings yet.',
      );
    }

    return _TrendLineChart(points: points);
  }
}

class _TenantMetricPill extends StatelessWidget {
  const _TenantMetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(value, style: AppTextStyles.dataTabular),
          ],
        ),
      ),
    );
  }
}

class _LiveChartPanel extends StatefulWidget {
  const _LiveChartPanel({required this.state, required this.tenantsRepo});

  final HomeState state;
  final TenantsRepo tenantsRepo;

  @override
  State<_LiveChartPanel> createState() => _LiveChartPanelState();
}

class _LiveChartPanelState extends State<_LiveChartPanel> {
  late final Future<List<TenantModel>> _tenantsFuture;

  @override
  void initState() {
    super.initState();
    _tenantsFuture = widget.tenantsRepo.getTenants();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TenantModel>>(
      future: _tenantsFuture,
      builder: (context, snapshot) {
        final tenantNames = {
          for (final tenant in snapshot.data ?? const <TenantModel>[])
            tenant.id: tenant.user,
        };
        final bars = _buildLatestTenantBars(widget.state.readings, tenantNames);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.border),
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
                _DashboardBarToolbar(state: widget.state, bars: bars),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 420,
                  child: AnimatedSwitcher(
                    duration: AppDurations.t500,
                    child: _buildChartContent(
                      context,
                      bars,
                      isLoadingTenants:
                          snapshot.connectionState != ConnectionState.done,
                      tenantLoadFailed: snapshot.hasError,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartContent(
    BuildContext context,
    List<_TenantBarPoint> bars, {
    required bool isLoadingTenants,
    required bool tenantLoadFailed,
  }) {
    if ((widget.state.status == HomeStatus.loading &&
            widget.state.readings.isEmpty) ||
        isLoadingTenants) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tenantLoadFailed) {
      return const _EmptyChartMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to load tenants',
        message: 'Tenant names are required for this dashboard chart.',
      );
    }

    if (widget.state.status == HomeStatus.failure &&
        widget.state.readings.isEmpty) {
      return _EmptyChartMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to load live readings',
        message:
            widget.state.errorMessage ?? 'Check the API server and try again.',
      );
    }

    if (widget.state.readings.isEmpty) {
      return const _EmptyChartMessage(
        icon: Icons.bar_chart_rounded,
        title: 'Waiting for tenant readings',
        message: 'Tenant accumulative values will appear here when available.',
      );
    }

    if (bars.isEmpty) {
      return const _EmptyChartMessage(
        icon: Icons.bar_chart_rounded,
        title: 'No tenant values yet',
        message: 'No latest accumulative values are available.',
      );
    }

    return _TenantAccumulationBarChart(points: bars);
  }
}

class _DashboardBarToolbar extends StatelessWidget {
  const _DashboardBarToolbar({required this.state, required this.bars});

  final HomeState state;
  final List<_TenantBarPoint> bars;

  @override
  Widget build(BuildContext context) {
    final total = bars.fold<double>(0, (sum, bar) => sum + bar.value);

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
                Text(
                  'Latest Accumulative Values',
                  style: AppTextStyles.headlineSm,
                ),
                const SizedBox(width: AppSpacing.sm),
                _TenantMetricPill(
                  label: 'Tenants',
                  value: bars.length.toString(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${total.toStringAsFixed(1)} kWh total across latest tenant readings',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
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
      ],
    );
  }
}

class _TenantAccumulationBarChart extends StatelessWidget {
  const _TenantAccumulationBarChart({required this.points});

  final List<_TenantBarPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxValue = points
        .map((point) => point.value)
        .reduce((a, b) => a > b ? a : b);
    final yPadding = maxValue <= 0 ? 10.0 : maxValue * 0.18;

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxValue + yPadding,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: _chartInterval(0, maxValue),
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
              reservedSize: 58,
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
              reservedSize: 46,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: SizedBox(
                    width: 80,
                    child: Text(
                      points[index].label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelCaps.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.overlay,
            tooltipBorder: const BorderSide(color: AppColors.border),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final point = points[group.x.toInt()];
              return BarTooltipItem(
                '${point.label}\n${point.value.toStringAsFixed(2)} kWh\n${point.timestamp}',
                AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
              );
            },
          ),
        ),
        barGroups: [
          for (var index = 0; index < points.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: points[index].value,
                  width: points.length > 10 ? 18 : 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.58),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: AppDurations.t500,
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
              color: _isHovered ? AppColors.primary : AppColors.border,
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
            color: _isHovered ? AppColors.primary : AppColors.border,
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
  const _TrendLineChart({required this.points});

  final List<_ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final values = points
        .map((point) => point.value)
        .whereType<double>()
        .toList();
    final minValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b);
    final padding = ((maxValue - minValue) * 0.18).clamp(4, 80).toDouble();
    final spots = [
      for (var index = 0; index < points.length; index++)
        if (points[index].value == null)
          FlSpot.nullSpot
        else
          FlSpot(index.toDouble(), points[index].value!),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
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
              interval: _bottomInterval(points.length),
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    points[index].label,
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
            tooltipBorder: const BorderSide(color: AppColors.border),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                if (spot.isNull()) {
                  return null;
                }
                final point = points[spot.x.toInt()];
                return LineTooltipItem(
                  '${point.value!.toStringAsFixed(2)} kWh\n${point.tooltip}',
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
              show: points.length <= 16,
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

class _ChartPoint {
  const _ChartPoint({
    required this.label,
    required this.value,
    required this.tooltip,
  });

  final String label;
  final double? value;
  final String tooltip;
}

class _TenantBarPoint {
  const _TenantBarPoint({
    required this.tenantId,
    required this.label,
    required this.value,
    required this.timestamp,
  });

  final int tenantId;
  final String label;
  final double value;
  final String timestamp;
}

List<_TenantBarPoint> _buildLatestTenantBars(
  List<ReadingModel> readings,
  Map<int, String> tenantNames,
) {
  final latestByTenant = <int, ReadingModel>{};

  for (final reading in readings) {
    final current = latestByTenant[reading.tenantId];
    if (current == null || reading.createdAt.isAfter(current.createdAt)) {
      latestByTenant[reading.tenantId] = reading;
    }
  }

  final points = latestByTenant.values.map((reading) {
    return _TenantBarPoint(
      tenantId: reading.tenantId,
      label: tenantNames[reading.tenantId] ?? 'Unknown tenant',
      value: reading.accumulativeValue,
      timestamp: _formatDate(reading.createdAt),
    );
  }).toList()..sort((a, b) => a.tenantId.compareTo(b.tenantId));

  return points;
}

List<_ChartPoint> _buildChartPoints(
  List<ReadingModel> readings,
  ChartRange range,
) {
  final now = DateTime.now();

  return switch (range) {
    ChartRange.day => _buildDayPoints(readings, now),
    ChartRange.week => _buildWeekPoints(readings, now),
    ChartRange.month => _buildMonthPoints(readings, now),
    ChartRange.sixMonths => _buildSixMonthPoints(readings, now),
    ChartRange.year => _buildYearPoints(readings, now),
  };
}

List<_ChartPoint> _buildDayPoints(List<ReadingModel> readings, DateTime now) {
  final today = _dateOnly(now);

  return List.generate(24, (hour) {
    final label = '${_twoDigits(hour)}:00';
    final isFutureHour = hour > now.hour;
    final value = isFutureHour
        ? null
        : readings
              .where(
                (reading) =>
                    _isSameDate(reading.createdAt, today) &&
                    reading.createdAt.hour == hour,
              )
              .fold<double>(0, (sum, reading) => sum + reading.relativeValue);

    return _ChartPoint(label: label, value: value, tooltip: 'Today at $label');
  });
}

List<_ChartPoint> _buildWeekPoints(List<ReadingModel> readings, DateTime now) {
  final today = _dateOnly(now);
  final daysSinceSaturday = (today.weekday - DateTime.saturday) % 7;
  final weekStart = today.subtract(Duration(days: daysSinceSaturday));
  const labels = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  return List.generate(7, (index) {
    final day = weekStart.add(Duration(days: index));
    final isFutureDay = day.isAfter(today);
    final value = isFutureDay
        ? null
        : readings
              .where((reading) => _isSameDate(reading.createdAt, day))
              .fold<double>(0, (sum, reading) => sum + reading.relativeValue);

    return _ChartPoint(
      label: labels[index],
      value: value,
      tooltip: '${labels[index]}, ${_formatDate(day)}',
    );
  });
}

List<_ChartPoint> _buildMonthPoints(List<ReadingModel> readings, DateTime now) {
  final nextMonthStart = DateTime(now.year, now.month + 1);
  final monthEnd = nextMonthStart.subtract(const Duration(days: 1));
  final ranges = [
    (start: 1, end: 7),
    (start: 8, end: 14),
    (start: 15, end: 21),
    (start: 22, end: monthEnd.day),
  ];

  return List.generate(ranges.length, (index) {
    final range = ranges[index];
    final start = DateTime(now.year, now.month, range.start);
    final end = DateTime(now.year, now.month, range.end);
    final isFutureWeek = start.isAfter(_dateOnly(now));
    final value = isFutureWeek
        ? null
        : readings
              .where(
                (reading) =>
                    !reading.createdAt.isBefore(start) &&
                    reading.createdAt.isBefore(
                      end.add(const Duration(days: 1)),
                    ),
              )
              .fold<double>(0, (sum, reading) => sum + reading.relativeValue);

    return _ChartPoint(
      label: 'Week ${index + 1}',
      value: value,
      tooltip: '${_formatDate(start)} - ${_formatDate(end)}',
    );
  });
}

List<_ChartPoint> _buildSixMonthPoints(
  List<ReadingModel> readings,
  DateTime now,
) {
  final firstMonth = DateTime(now.year, now.month - 5);

  return List.generate(6, (index) {
    final month = DateTime(firstMonth.year, firstMonth.month + index);
    return _buildMonthPoint(readings, month, now: now, includeYear: false);
  });
}

List<_ChartPoint> _buildYearPoints(List<ReadingModel> readings, DateTime now) {
  return List.generate(12, (index) {
    final month = DateTime(now.year, index + 1);
    return _buildMonthPoint(readings, month, now: now, includeYear: false);
  });
}

_ChartPoint _buildMonthPoint(
  List<ReadingModel> readings,
  DateTime month, {
  required DateTime now,
  required bool includeYear,
}) {
  final monthStart = DateTime(month.year, month.month);
  final nextMonthStart = DateTime(month.year, month.month + 1);
  final monthEnd = nextMonthStart.subtract(const Duration(days: 1));
  final currentMonth = DateTime(now.year, now.month);
  final value = monthStart.isAfter(currentMonth)
      ? null
      : readings
            .where(
              (reading) =>
                  !reading.createdAt.isBefore(monthStart) &&
                  reading.createdAt.isBefore(nextMonthStart),
            )
            .fold<double>(0, (sum, reading) => sum + reading.relativeValue);
  final label = includeYear
      ? '${_shortMonth(month.month)} ${month.year}'
      : _shortMonth(month.month);

  return _ChartPoint(
    label: label,
    value: value,
    tooltip: '${_formatDate(monthStart)} - ${_formatDate(monthEnd)}',
  );
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

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _formatPeriodLabel(ChartRange range) {
  final now = DateTime.now();

  return switch (range) {
    ChartRange.day => 'Today, ${_formatDate(now)}',
    ChartRange.week => _formatWeekPeriod(now),
    ChartRange.month => _formatMonthPeriod(now),
    ChartRange.sixMonths => _formatSixMonthPeriod(now),
    ChartRange.year => 'Year period, Jan - Dec ${now.year}',
  };
}

String _formatWeekPeriod(DateTime now) {
  final today = _dateOnly(now);
  final daysSinceSaturday = (today.weekday - DateTime.saturday) % 7;
  final start = today.subtract(Duration(days: daysSinceSaturday));
  final end = start.add(const Duration(days: 6));

  return 'Week period, ${_formatDate(start)} - ${_formatDate(end)}';
}

String _formatMonthPeriod(DateTime now) {
  final start = DateTime(now.year, now.month);
  final end = DateTime(
    now.year,
    now.month + 1,
  ).subtract(const Duration(days: 1));

  return 'Month period, ${_formatDate(start)} - ${_formatDate(end)}';
}

String _formatSixMonthPeriod(DateTime now) {
  final start = DateTime(now.year, now.month - 5);
  final end = DateTime(
    now.year,
    now.month + 1,
  ).subtract(const Duration(days: 1));

  return '6 month period, ${_formatDate(start)} - ${_formatDate(end)}';
}

String _formatDate(DateTime value) {
  return '${_shortMonth(value.month)} ${value.day}, ${value.year}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _shortMonth(int month) {
  return const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}
