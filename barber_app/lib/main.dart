import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/barber.dart';
import 'models/service.dart';
import 'models/user.dart';
import 'screens/splash_screen.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/barber_service.dart';
import 'services/firebase_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientação do app para apenas retrato
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar estilo da barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar serviços
  await FirebaseService().init();
  await AuthService().init();
  await BarberService().init();

  runApp(const BarberApp());
}

class BarberApp extends StatelessWidget {
  const BarberApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth service provider
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
        // Barber service providers
        Provider<BarberService>(
          create: (_) => BarberService(),
        ),
        StreamProvider<List<Barber>>.value(
          value: BarberService().barbersStream,
          initialData: const [],
        ),
        StreamProvider<List<Service>>.value(
          value: BarberService().servicesStream,
          initialData: const [],
        ),
        // Appointment service provider
        Provider<AppointmentService>(
          create: (_) => AppointmentService(),
        ),
      ],
      child: MaterialApp(
        title: 'Barber Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.apply(
                  bodyColor: AppColors.textPrimary,
                  displayColor: AppColors.textPrimary,
                ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.secondary, width: 2),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.textSecondary.withAlpha(128)),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.accent),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
