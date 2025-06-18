import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.splashScreen,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Verificar se o usuário está logado
        final currentUser = AuthService().currentUser;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                currentUser != null ? const HomeScreen() : const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado da barbearia
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary, width: 3),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(
                        Icons.content_cut,
                        color: AppColors.secondary,
                        size: 100,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: const Text(
                    'BARBER SHOP',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: const Text(
                    'ESTILO & ELEGÂNCIA',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
