import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ProfesorScreen extends StatefulWidget {
  const ProfesorScreen({super.key});

  @override
  State<ProfesorScreen> createState() => _ProfesorScreenState();
}

class _ProfesorScreenState extends State<ProfesorScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // 1. CONTROLADORES: ALTA DE ALUMNOS (INCLUYE SALUD)
  final _formAlumnoKey = GlobalKey<FormState>();
  final _ncController = TextEditingController();
  final _nombreController = TextEditingController();
  final _grupoController = TextEditingController();
  final _especialidadController = TextEditingController();
  final _sangreController = TextEditingController();
  final _alergiasController = TextEditingController();

  // 2. CONTROLADORES: PASE DE LISTA / ESCÁNER QR
  final _formAsistenciaKey = GlobalKey<FormState>();
  final _ncAsistenciaController = TextEditingController();
  String _estadoAsistencia = 'A Tiempo';

  // 3. CONTROLADORES: PUBLICAR AVISOS
  final _formAvisoKey = GlobalKey<FormState>();
  final _tituloAvisoController = TextEditingController();
  final _contenidoAvisoController = TextEditingController();
  String _categoriaAviso = 'AVISO';

  // FUNCIÓN: Guardar Alumno con Ficha Médica
  Future<void> _registrarAlumno() async {
    if (_formAlumnoKey.currentState!.validate()) {
      try {
        await _db.collection('alumnos').doc(_ncController.text.trim()).set({
          'nombre': _nombreController.text.trim(),
          'grupo': _grupoController.text.trim().toUpperCase(),
          'especialidad': _especialidadController.text.trim(),
          'correo': '${_ncController.text.trim()}@cetis131.edu.mx',
          'tipoSanguineo': _sangreController.text.trim().isEmpty ? 'No registrado' : _sangreController.text.trim(),
          'alergias': _alergiasController.text.trim().isEmpty ? 'Ninguna registrada' : _alergiasController.text.trim(),
        });

        _ncController.clear();
        _nombreController.clear();
        _grupoController.clear();
        _especialidadController.clear();
        _sangreController.clear();
        _alergiasController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Alumno y Ficha Médica guardados con éxito!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // FUNCIÓN: Registrar Acceso Manual o QR
  Future<void> _registrarAsistencia(String matricula) async {
    if (matricula.isEmpty) return;
    try {
      DocumentSnapshot alumnoDoc = await _db.collection('alumnos').doc(matricula).get();
      if (!alumnoDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La matrícula escaneada no existe.'), backgroundColor: Colors.orange),
        );
        return;
      }

      DateTime ahora = DateTime.now();
      String fechaActual = "${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}";
      String horaActual = "${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}";

      await _db.collection('alumnos').doc(matricula).collection('asistencias').add({
        'fecha': fechaActual,
        'hora': horaActual,
        'estado': _estadoAsistencia,
      });

      _ncAsistenciaController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡$_estadoAsistencia registrado para ${alumnoDoc['nombre']}!'), backgroundColor: Colors.blue),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // FUNCIÓN: Escáner QR de Cámara Real
  void _simularEscaneoQR() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        color: Colors.white,
        child: Column(
          children: [
            AppBar(
              title: const Text('Escáner de Credenciales QR', style: TextStyle(fontSize: 16)),
              backgroundColor: const Color(0xFF5A1226),
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      String detectado = barcode.rawValue!;
                      
                      // Si el QR viene con formato "matricula|fecha", extraemos solo la matrícula
                      if (detectado.contains('|')) {
                        detectado = detectado.split('|')[0];
                      }
                      
                      Navigator.pop(context); // Cierra la cámara
                      _registrarAsistencia(detectado); // Registra asistencia en Firebase
                      break;
                    }
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Coloque el código QR del alumno frente a la cámara', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // FUNCIÓN: Publicar nuevo aviso institucional
  Future<void> _publicarAviso() async {
    if (_formAvisoKey.currentState!.validate()) {
      try {
        await _db.collection('avisos').add({
          'titulo': _tituloAvisoController.text.trim(),
          'contenido': _contenidoAvisoController.text.trim(),
          'categoria': _categoriaAviso,
          'fecha': DateTime.now().toString(),
        });

        _tituloAvisoController.clear();
        _contenidoAvisoController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Aviso publicado a todo el plantel!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Cambiamos a 4 pestañas de administración masiva
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel Administrativo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF5A1226),
          elevation: 4,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Salir',
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            )
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            isScrollable: true, // Permite que las pestañas se deslicen cómodo
            tabs: [
              Tab(icon: Icon(Icons.person_add), text: 'Alumnos y Salud'),
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'Checador QR'),
              Tab(icon: Icon(Icons.add_alert), text: 'Publicar Avisos'),
              Tab(icon: Icon(Icons.gavel), text: 'Buzón de Reportes'),
            ],
          ),
        ),
        body: Container(
          color: const Color(0xFFF5F5F5),
          child: TabBarView(
            children: [
              // PESTAÑA 1: ALTA ALUMNOS + SALUD
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formAlumnoKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Expediente y Matrícula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5A1226))),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ncController,
                        decoration: const InputDecoration(labelText: 'Número de Control', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre del Alumno', border: OutlineInputBorder()),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _grupoController,
                              decoration: const InputDecoration(labelText: 'Grupo', border: OutlineInputBorder()),
                              validator: (value) => value!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _especialidadController,
                              decoration: const InputDecoration(labelText: 'Especialidad', border: OutlineInputBorder()),
                              validator: (value) => value!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Ficha Médica de Emergencia (Opcional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6F4E37))),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _sangreController,
                        decoration: const InputDecoration(labelText: 'Tipo de Sangre (Ej: O+)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _alergiasController,
                        decoration: const InputDecoration(labelText: 'Alergias o Padecimientos', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _registrarAlumno,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A1226), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('DAR DE ALTA SISTEMA', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),

              // PESTAÑA 2: CHECADOR / LECTOR QR
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formAsistenciaKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Escanear Credencial Escolar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5A1226))),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('ACTIVAR CÁMARA / ESCÁNER QR', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _simularEscaneoQR,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A1226), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)),
                      ),
                      const SizedBox(height: 24),
                      const Center(child: Text('O REGISTRO MANUAL DE MATRÍCULA', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ncAsistenciaController,
                        decoration: const InputDecoration(labelText: 'Digitar Número de Control', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      const Text('Estado del acceso:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Radio<String>(value: 'A Tiempo', groupValue: _estadoAsistencia, onChanged: (v) => setState(() => _estadoAsistencia = v!)),
                          const Text('A Tiempo'),
                          const SizedBox(width: 24),
                          Radio<String>(value: 'Retardo', groupValue: _estadoAsistencia, onChanged: (v) => setState(() => _estadoAsistencia = v!)),
                          const Text('Retardo'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _registrarAsistencia(_ncAsistenciaController.text.trim()),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6F4E37), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: const Text('ENVIAR REGISTRO MANUAL'),
                      )
                    ],
                  ),
                ),
              ),

              // PESTAÑA 3: PUBLICAR AVISOS EN LÍNEA
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formAvisoKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Crear Notificación General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5A1226))),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tituloAvisoController,
                        decoration: const InputDecoration(labelText: 'Título del Aviso', border: OutlineInputBorder()),
                        validator: (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contenidoAvisoController,
                        decoration: const InputDecoration(labelText: 'Cuerpo del Comunicado', border: OutlineInputBorder()),
                        maxLines: 4,
                        validator: (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _categoriaAviso,
                        decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'URGENTE', child: Text('URGENTE')),
                          DropdownMenuItem(value: 'ACADÉMICO', child: Text('ACADÉMICO')),
                          DropdownMenuItem(value: 'AVISO', child: Text('AVISO GENERAL')),
                        ],
                        onChanged: (v) => setState(() => _categoriaAviso = v!),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _publicarAviso,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A1226), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('PUBLICAR COMUNICADO', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),

              // PESTAÑA 4: MONITOREO DEL BUZÓN DE REPORTES ANÓNIMOS
              StreamBuilder<QuerySnapshot>(
                stream: _db.collection('reportes').orderBy('fecha', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No se han registrado incidencias anónimas. ¡Todo limpio!', style: TextStyle(color: Colors.grey)));
                  }

                  final reportes = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: reportes.length,
                    itemBuilder: (context, index) {
                      final r = reportes[index].data() as Map<String, dynamic>;
                      bool esEmergencia = r['categoria'] == 'Emergencia Médica' || r['categoria'] == 'Seguridad';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: esEmergencia ? Colors.red[100] : Colors.amber[100],
                            child: Icon(Icons.report_problem, color: esEmergencia ? Colors.red[900] : Colors.amber[900]),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(r['categoria'] ?? 'Incidencia', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('${r['fecha']} - ${r['hora']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(r['descripcion'] ?? 'Sin descripción', style: TextStyle(color: Colors.grey[800], height: 1.3)),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}