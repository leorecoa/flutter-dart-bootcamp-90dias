import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/barber.dart';
import 'models/service.dart';
import 'models/user.dart';
import 'screens/appointments_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'services/analytics_service.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/barber_service.dart';
import 'services/firebase_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente
  await dotenv.load(fileName: '.env');

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
  await AnalyticsService().init();

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
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/appointments': (context) => const AppointmentsScreen(),
        },
      ),
    );
  }
}
