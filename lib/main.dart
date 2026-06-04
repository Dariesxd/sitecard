import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:sitecard/providers/usuario_provider.dart'; 
import 'package:sitecard/screens/splash_screen.dart';
// IMPORTAMOS LAS NUEVAS LIBRERÍAS DE GOOGLE
import 'package:firebase_core/firebase_core.dart';
import 'package:sitecard/firebase_options.dart';

void main() async {
  // Asegura que los canales nativos del teléfono estén listos antes de arrancar Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // ¡ENCENDEMOS EL MOTOR DE FIREBASE EN LA NUBE!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SiteCardApp());
}

class SiteCardApp extends StatelessWidget {
  const SiteCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
      ],
      child: MaterialApp(
        title: 'SiteCard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF5A1226),
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5A1226),
            secondary: const Color(0xFF6F4E37),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}