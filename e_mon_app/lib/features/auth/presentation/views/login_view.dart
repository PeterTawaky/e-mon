import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/core/routes/app_routes.dart';
import 'package:e_mon_app/core/services/networking/dio_consumer.dart';
import 'package:e_mon_app/core/utils/app_assets.dart';
import 'package:e_mon_app/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:e_mon_app/features/auth/presentation/managers/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(AuthRepoImpl(DioConsumer())),
      child: const _LoginViewBody(),
    );
  }
}

class _LoginViewBody extends StatefulWidget {
  const _LoginViewBody();

  @override
  State<_LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<_LoginViewBody> {
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
    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            context.go(AppRoutes.homeView);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.containerPaddingDesktop),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.lgBorder,
                  border: Border.all(color: AppColors.goldBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      blurRadius: 38,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: FocusTraversalGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Assets.imagesLogo, height: 180),
                        // const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayLg.copyWith(fontSize: 36),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Sign in to WattWise power intelligence.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextField(
                          controller: _userController,
                          focusNode: _userFocusNode,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: 'User',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                          onSubmitted: (_) => _submit(context),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            if (state.status != LoginStatus.failure ||
                                state.errorMessage == null) {
                              return const SizedBox.shrink();
                            }

                            return _LoginError(message: state.errorMessage!);
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == LoginStatus.loading;

                            return FilledButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _submit(context),
                              child: isLoading
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Login'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    context.read<LoginCubit>().login(
      user: _userController.text,
      password: _passwordController.text,
    );
  }
}

class _LoginError extends StatelessWidget {
  const _LoginError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.18),
        borderRadius: AppRadius.regularBorder,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.42)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
