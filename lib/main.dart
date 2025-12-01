import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  di.sl<AuthBloc>().add(AuthCheckRequested());
  runApp(const SmartVitalsApp());
}

class SmartVitalsApp extends StatelessWidget {
  const SmartVitalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'SmartVitals',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getLightScene(),
        darkTheme: AppTheme.getHighContrastTheme(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
