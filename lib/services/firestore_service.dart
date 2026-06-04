import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Esta función busca en la base de datos si existe el número de control
  Future<Map<String, dynamic>?> obtenerDatosAlumno(String numeroControl) async {
    try {
      DocumentSnapshot doc = await _db.collection('alumnos').doc(numeroControl).get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null; // No encontró al alumno
      }
    } catch (e) {
      return null;
    }
  }
    // Nueva función para traer las asistencias del alumno en tiempo real
  Stream<QuerySnapshot> obtenerHistorialAsistencias(String numeroControl) {
    return _db
        .collection('alumnos')
        .doc(numeroControl)
        .collection('asistencias')
        .snapshots(); // .snapshots() hace que si el prefecto borra o pone una asistencia, cambie en la app al instante
  }
}