import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/features/tenants/presentation/managers/tenants_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TenantsModule extends StatefulWidget {
  const TenantsModule({super.key});

  @override
  State<TenantsModule> createState() => _TenantsModuleState();
}

class _TenantsModuleState extends State<TenantsModule> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _registerNoController = TextEditingController();
  final TextEditingController _gatewayIpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final FocusNode _userFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _registerNoController.dispose();
    _gatewayIpController.dispose();
    _emailController.dispose();
    _phoneNoController.dispose();
    _userFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TenantsCubit, TenantsState>(
      listener: (context, state) {
        if (state.status == TenantsStatus.success && state.message != null) {
          _userController.clear();
          _passwordController.clear();
          _registerNoController.clear();
          _gatewayIpController.clear();
          _emailController.clear();
          _phoneNoController.clear();
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerPaddingDesktop),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tenants',
                style: AppTextStyles.displayLg.copyWith(fontSize: 40),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create tenants and review tenant access details.',
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TenantCreationPanel(
                userController: _userController,
                passwordController: _passwordController,
                registerNoController: _registerNoController,
                gatewayIpController: _gatewayIpController,
                emailController: _emailController,
                phoneNoController: _phoneNoController,
                userFocusNode: _userFocusNode,
                passwordFocusNode: _passwordFocusNode,
                state: state,
                onSubmit: _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              _TenantsListPanel(state: state),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    context.read<TenantsCubit>().createTenant(
      user: _userController.text,
      password: _passwordController.text,
      registerNo: _registerNoController.text,
      gatewayIp: _gatewayIpController.text,
      email: _emailController.text,
      phoneNo: _phoneNoController.text,
    );
  }
}

class _TenantCreationPanel extends StatelessWidget {
  const _TenantCreationPanel({
    required this.userController,
    required this.passwordController,
    required this.registerNoController,
    required this.gatewayIpController,
    required this.emailController,
    required this.phoneNoController,
    required this.userFocusNode,
    required this.passwordFocusNode,
    required this.state,
    required this.onSubmit,
  });

  final TextEditingController userController;
  final TextEditingController passwordController;
  final TextEditingController registerNoController;
  final TextEditingController gatewayIpController;
  final TextEditingController emailController;
  final TextEditingController phoneNoController;
  final FocusNode userFocusNode;
  final FocusNode passwordFocusNode;
  final TenantsState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.status == TenantsStatus.submitting;

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
                  const Icon(Icons.group_add_rounded, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Generate New Tenant', style: AppTextStyles.headlineSm),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _TenantTextField(
                    controller: userController,
                    focusNode: userFocusNode,
                    label: 'Tenant',
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => passwordFocusNode.requestFocus(),
                  ),
                  _TenantTextField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                  _TenantTextField(
                    controller: registerNoController,
                    label: 'Register No.',
                    icon: Icons.confirmation_number_outlined,
                  ),
                  _TenantTextField(
                    controller: gatewayIpController,
                    label: 'Gateway IP',
                    icon: Icons.router_outlined,
                  ),
                  _TenantTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _TenantTextField(
                    controller: phoneNoController,
                    label: 'Phone No.',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onSubmit(),
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
                      label: Text(isSubmitting ? 'Creating' : 'Create Tenant'),
                    ),
                  ),
                ],
              ),
              if (state.message != null) ...[
                const SizedBox(height: AppSpacing.md),
                _TenantsMessage(
                  message: state.message!,
                  isError: state.status == TenantsStatus.failure,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TenantTextField extends StatelessWidget {
  const _TenantTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _TenantsMessage extends StatelessWidget {
  const _TenantsMessage({required this.message, required this.isError});

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

class _TenantsListPanel extends StatelessWidget {
  const _TenantsListPanel({required this.state});

  final TenantsState state;

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
                Text('Tenants', style: AppTextStyles.headlineSm),
                Text(
                  '${state.tenants.length} tenants',
                  style: AppTextStyles.labelCaps,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.status == TenantsStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (state.tenants.isEmpty)
              _EmptyTenantsMessage()
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Tenant')),
                    DataColumn(label: Text('Register No.')),
                    DataColumn(label: Text('Gateway IP')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: state.tenants.map((tenant) {
                    return DataRow(
                      cells: [
                        DataCell(Text(tenant.user)),
                        DataCell(Text(tenant.registerNo ?? '-')),
                        DataCell(Text(tenant.gatewayIp ?? '-')),
                        DataCell(Text(tenant.email ?? '-')),
                        DataCell(Text(tenant.phoneNo ?? '-')),
                        DataCell(Text(_formatDate(tenant.createdAt))),
                        DataCell(
                          IconButton(
                            tooltip: 'Delete tenant',
                            onPressed: () => context
                                .read<TenantsCubit>()
                                .deleteTenant(tenant.id),
                            icon: const Icon(Icons.delete_outline_rounded),
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

class _EmptyTenantsMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.regularBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Icon(
              Icons.group_rounded,
              color: AppColors.onSurfaceVariant,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('No tenants yet', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create the first tenant above.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
