import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/core/routes/router_generator.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'WattWise',
      theme: AppTheme.dark,
      routerConfig: RouterGenerator.mainRouting,
    );
  }
}
