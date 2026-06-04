import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:sitecard/providers/usuario_provider.dart'; 
import 'package:sitecard/screens/home_screen.dart';
import 'package:sitecard/screens/profesor_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // La llave para validar el formulario
  final _formKey = GlobalKey<FormState>();
  
  // El controlador que atrapa los números de control
  final TextEditingController _controlNumberController = TextEditingController();

  @override
  void dispose() {
    _controlNumberController.dispose();
    super.dispose();
  }

  // Cambia esta parte de tu función _iniciarSesion
  Future<void> _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      String numeroControlInput = _controlNumberController.text.trim();
      
      // REGLA MÁGICA: Si digitan '9999', entra como Profesor Administrador
      if (numeroControlInput == '9999') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfesorScreen()),
        );
        return; // Detiene la ejecución para que no busque el '9999' en los alumnos
      }

      // Si no es la clave de profesor, sigue el flujo normal de buscar al alumno
      bool encontrado = await Provider.of<UsuarioProvider>(context, listen: false)
          .cargarDatosAlumno(numeroControlInput);

      if (encontrado) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Matrícula no encontrada. Verifica tu número.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/images/logo_sitecard.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bienvenido a SiteCard',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A1226),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa tus datos institucionales para activar tu credencial digital',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6F4E37),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Campo de texto para los 14 números
                TextFormField(
                  controller: _controlNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 14,
                  decoration: InputDecoration(
                    labelText: 'Número de Control Escolar',
                    labelStyle: const TextStyle(color: Color(0xFF6F4E37)),
                    prefixIcon: const Icon(Icons.badge, color: Color(0xFF5A1226)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFF5A1226), width: 2.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, ingresa tu número de control';
                    }
                    // IMPORTANTE: Modificado temporalmente a menor que 4 para permitir digitar '9999'
                    if (value.length < 4) {
                      return 'El número de control no es válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Botón Guinda
                ElevatedButton(
                  onPressed: _iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A1226),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'ACTIVAR CREDENCIAL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'CETis 131 • Control de Acceso Seguro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}