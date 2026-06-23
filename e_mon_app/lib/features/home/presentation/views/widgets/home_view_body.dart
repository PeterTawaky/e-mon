import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/core/routes/app_routes.dart';
import 'package:e_mon_app/core/services/networking/dio_consumer.dart';
import 'package:e_mon_app/core/utils/app_assets.dart';
import 'package:e_mon_app/core/utils/app_durations.dart';
import 'package:e_mon_app/features/home/data/models/reading_model.dart';
import 'package:e_mon_app/features/home/presentation/managers/chart_range.dart';
import 'package:e_mon_app/features/home/presentation/managers/home_cubit.dart';
import 'package:e_mon_app/features/reports/data/repositories/reports_repo_impl.dart';
import 'package:e_mon_app/features/reports/domain/services/energy_report_calculator.dart';
import 'package:e_mon_app/features/reports/domain/services/report_pdf_service.dart';
import 'package:e_mon_app/features/reports/presentation/managers/reports_cubit.dart';
import 'package:e_mon_app/features/reports/presentation/views/widgets/reports_module.dart';
import 'package:e_mon_app/features/users/data/repositories/users_repo_impl.dart';
import 'package:e_mon_app/features/users/presentation/managers/users_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

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
  });

  final _MenuDestination selectedDestination;
  final ReportKind selectedReportKind;
  final ValueChanged<ReportKind> onReportSelected;

  @override
  Widget build(BuildContext context) {
    if (selectedDestination == _MenuDestination.users) {
      return BlocProvider(
        create: (_) => UsersCubit(UsersRepoImpl(DioConsumer()))..loadUsers(),
        child: const _UsersModule(),
      );
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
              _LiveChartPanel(state: state),
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
  users('Users', Icons.manage_accounts_rounded),
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
        border: Border.all(color: AppColors.goldBorder),
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
        border: Border(bottom: BorderSide(color: AppColors.goldBorder)),
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
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.36),
            ),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: AppColors.primary,
            size: 26,
          ),
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
            border: Border.all(color: AppColors.goldBorder),
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

class _UsersModule extends StatefulWidget {
  const _UsersModule();

  @override
  State<_UsersModule> createState() => _UsersModuleState();
}

class _UsersModuleState extends State<_UsersModule> {
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
    return BlocConsumer<UsersCubit, UsersState>(
      listener: (context, state) {
        if (state.status == UsersStatus.success && state.message != null) {
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
                'Users',
                style: AppTextStyles.displayLg.copyWith(fontSize: 40),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create dashboard users and review existing system access.',
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _UserCreationPanel(
                userController: _userController,
                passwordController: _passwordController,
                userFocusNode: _userFocusNode,
                passwordFocusNode: _passwordFocusNode,
                state: state,
                onSubmit: _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              _UsersListPanel(state: state),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    context.read<UsersCubit>().createUser(
      user: _userController.text,
      password: _passwordController.text,
    );
  }
}

class _UserCreationPanel extends StatelessWidget {
  const _UserCreationPanel({
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
  final UsersState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.status == UsersStatus.submitting;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.goldBorder),
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
                  Text('Generate New User', style: AppTextStyles.headlineSm),
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
                      label: Text(isSubmitting ? 'Creating' : 'Create User'),
                    ),
                  ),
                ],
              ),
              if (state.message != null) ...[
                const SizedBox(height: AppSpacing.md),
                _UsersMessage(
                  message: state.message!,
                  isError: state.status == UsersStatus.failure,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersMessage extends StatelessWidget {
  const _UsersMessage({required this.message, required this.isError});

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

class _UsersListPanel extends StatelessWidget {
  const _UsersListPanel({required this.state});

  final UsersState state;

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('System Users', style: AppTextStyles.headlineSm),
                Text(
                  '${state.users.length} users',
                  style: AppTextStyles.labelCaps,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.status == UsersStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (state.users.isEmpty)
              _EmptyChartMessage(
                icon: Icons.manage_accounts_rounded,
                title: 'No users yet',
                message: 'Create the first system user above.',
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Password')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: state.users.map((user) {
                    return DataRow(
                      cells: [
                        DataCell(Text(user.user)),
                        DataCell(Text(user.password)),
                        DataCell(Text(_formatDate(user.createdAt))),
                        DataCell(
                          _DeleteUserButton(
                            userName: user.user,
                            onConfirmed: () =>
                                context.read<UsersCubit>().deleteUser(user.id),
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
          title: const Text('Delete User'),
          content: Text(
            'Are you sure you want to delete "${widget.userName}"? This action cannot be undone.',
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
                    Image.asset(Assets.imagesLogo, height: 80),
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

class _LiveChartPanel extends StatelessWidget {
  const _LiveChartPanel({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final chartPoints = _buildChartPoints(state.readings, state.selectedRange);

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
                child: _buildChartContent(context, chartPoints),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent(BuildContext context, List<_ChartPoint> points) {
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

    if (state.readings.isEmpty) {
      return const _EmptyChartMessage(
        icon: Icons.show_chart_rounded,
        title: 'Waiting for device data',
        message: 'The simulation service will add a new reading each minute.',
      );
    }

    return _TrendLineChart(points: points);
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
            Text(
              _formatPeriodLabel(state.selectedRange),
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
            tooltipBorder: const BorderSide(color: AppColors.goldBorder),
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
