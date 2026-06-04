import 'package:flutter/material.dart';
import 'package:sitecard/services/firestore_service.dart';

class UsuarioProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Datos del alumno
  String _nombreCompleto = "Cargando...";
  String _numeroControl = "";
  String _especialidad = "";
  String _grupo = "";
  String _correo = "";
  String _tipoSanguineo = "";
  String _alergias = "";

  // Getters
  String get nombreCompleto => _nombreCompleto;
  String get numeroControl => _numeroControl;
  String get especialidad => _especialidad;
  String get grupo => _grupo;
  String get correo => _correo;
  String get tipoSanguineo => _tipoSanguineo;
  String get alergias => _alergias;

  // FUNCIÓN ESTRELLA: Busca al alumno en Firebase
  Future<bool> cargarDatosAlumno(String numeroControl) async {
    final datos = await _firestoreService.obtenerDatosAlumno(numeroControl);

    if (datos != null) {
      _nombreCompleto = datos['nombre'] ?? 'Sin nombre';
      _numeroControl = numeroControl;
      _especialidad = datos['especialidad'] ?? 'N/A';
      _grupo = datos['grupo'] ?? 'N/A';
      _correo = datos['correo'] ?? 'N/A';
      _tipoSanguineo = datos['tipoSanguineo'] ?? 'N/A';
      _alergias = datos['alergias'] ?? 'N/A';
      
      notifyListeners(); // Avisa a toda la app que los datos cambiaron
      return true; // Éxito: El alumno existe
    } else {
      return false; // Error: El alumno no existe
    }
  }

  void cerrarSesion() {
    _nombreCompleto = "Cargando...";
    _numeroControl = "";
    notifyListeners();
  }
}