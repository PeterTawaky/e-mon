import 'package:e_mon_app/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/networking/dio_consumer.dart';
import '../../data/repositories/home_repo_impl.dart';
import '../../data/repositories/home_repo.dart';
import '../managers/home_cubit.dart';
import '../../../tenants/data/repositories/tenants_repo.dart';
import '../../../tenants/data/repositories/tenants_repo_impl.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    this.homeRepo,
    this.tenantsRepo,
    this.enableLiveUpdates = true,
  });

  final HomeRepo? homeRepo;
  final TenantsRepo? tenantsRepo;
  final bool enableLiveUpdates;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = HomeCubit(homeRepo ?? HomeRepoImpl(DioConsumer()));
        if (enableLiveUpdates) {
          cubit.startLiveUpdates();
        } else {
          cubit.loadInitialReadings();
        }
        return cubit;
      },
      child: HomeViewBody(
        tenantsRepo: tenantsRepo ?? TenantsRepoImpl(DioConsumer()),
      ),
    );
  }
}
