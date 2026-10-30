import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_bloc.dart';

/// The app-wide blocs, provided by `bootstrap` above `App` and the router,
/// so they outlive every screen (architecture §5 rule 8). A feature bloc
/// joins this list rather than being provided by a screen.
abstract final class BlocsHelper {
  static List<BlocProvider> initializeBlocs() => [
    BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
    BlocProvider<SignUpBloc>(create: (_) => SignUpBloc()),
    BlocProvider<OnboardingBloc>(create: (_) => OnboardingBloc()),
    BlocProvider<FacilitiesBloc>(create: (_) => FacilitiesBloc()),
    BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
  ];
}
