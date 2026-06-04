import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sitecard/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configuramos la animación para que el logo aparezca suavemente
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Tarda segundo y medio en aparecer
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Arranca la animación
    _animationController.forward();

    // Temporizador: Espera 3 segundos en esta pantalla y luego hará algo
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
);
    });
  }

  @override
  void dispose() {
    // Limpiamos la memoria del teléfono al cerrar la pantalla
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white, // Fondo blanco limpio para resaltar el logotipo
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Este bloque se encarga de mostrar tu logo con la animación suave
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Llama al logo que guardaste en assets
                  Image.asset(
                    'assets/images/logo_sitecard.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24), // Espacio de separación
                  const Text(
                    'SITECARD',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0, // Separa un poco las letras para que se vea elegante
                      color: Color(0xFF5A1226), // Tu color guinda oficial
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Indicador de carga circular abajo, en color guinda
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A1226)),
            ),
            const SizedBox(height: 60), // Margen inferior
          ],
        ),
      ),
    );
  }
}