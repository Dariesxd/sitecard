import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // IMPORTANTE: Para escuchar al cerebro
import 'package:sitecard/providers/usuario_provider.dart'; // Tu molde de datos
import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORTANTE: Agregar este import al inicio del archivo si no está
import 'package:sitecard/services/firestore_service.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Asegúrate de tener este import arriba

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Empezamos directo en la pestaña de la Credencial

  // Lista de las diferentes pantallas
  final List<Widget> _pantallas = [
    const VistaInicio(),
    const VistaCredencial(),
    const VistaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SITECARD',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5A1226), // Guinda
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      
      body: _pantallas[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF5A1226), // Guinda
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Credencial'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ==========================================
// VISTA 1: PANTALLA DE INICIO (CON AVISOS DESDE FIREBASE)
// ==========================================
class VistaInicio extends StatefulWidget {
  const VistaInicio({super.key});

  @override
  State<VistaInicio> createState() => _VistaInicioState();
}

class _VistaInicioState extends State<VistaInicio> {
  String categoriaSeleccionada = 'Seguridad';
  final TextEditingController reporteController = TextEditingController();

  void _abrirModalReporte() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Buzón de Incidencias Anónimas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A1226))),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Tu reporte será enviado de forma 100% confidencial a las autoridades del plantel.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    decoration: const InputDecoration(labelText: 'Categoría del Reporte', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Seguridad', child: Text('Seguridad / Acoso')),
                      DropdownMenuItem(value: 'Infraestructura', child: Text('Fallas de Infraestructura')),
                      DropdownMenuItem(value: 'Emergencia Médica', child: Text('Emergencia Médica')),
                    ],
                    onChanged: (val) => setModalState(() => categoriaSeleccionada = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reporteController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Describe la situación con detalles...', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (reporteController.text.trim().isNotEmpty) {
                        try {
                          await FirebaseFirestore.instance.collection('reportes').add({
                            'categoria': categoriaSeleccionada,
                            'descripcion': reporteController.text.trim(),
                            'fecha': "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
                            'hora': "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                            reporteController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reporte enviado de forma anónima con éxito.'), backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al enviar: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A1226), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('ENVIAR REPORTE SEGURO', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tablero de Avisos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5A1226))),
                  IconButton(
                    icon: const Icon(Icons.gavel, color: Color(0xFF5A1226), size: 28),
                    tooltip: 'Buzón Anónimo',
                    onPressed: _abrirModalReporte,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('avisos').orderBy('fecha', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay avisos institucionales vigentes.', style: TextStyle(color: Colors.grey)));
                  }

                  final listaAvisos = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: listaAvisos.length,
                    itemBuilder: (context, index) {
                      final aviso = listaAvisos[index].data() as Map<String, dynamic>;
                      String cat = aviso['categoria'] ?? 'AVISO';
                      bool esUrgente = cat == 'URGENTE';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: esUrgente ? Colors.red[100] : Colors.blue[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      cat,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: esUrgente ? Colors.red[900] : Colors.blue[900]),
                                    ),
                                  ),
                                  const Icon(Icons.notifications_none, size: 18, color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(aviso['titulo'] ?? 'Sin Título', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(aviso['contenido'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// VISTA 2: TU CREDENCIAL DIGITAL (DINÁMICA)
// ==========================================
class VistaCredencial extends StatelessWidget {
  const VistaCredencial({super.key});

  @override
  Widget build(BuildContext context) {
    // CAMBIO CRÍTICO: Aquí nos conectamos al Provider para jalar la info en tiempo real
    final usuario = Provider.of<UsuarioProvider>(context);

    // Generamos un "token" único para el QR (Número de control + fecha)
    String dataQr = "${usuario.numeroControl}|${DateTime.now().toString().substring(0, 10)}";

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ESTUDIANTE',
                          style: TextStyle(color: Color(0xFF5A1226), fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                        ),
                        Image.asset('assets/images/logo_sitecard.png', height: 35),
                      ],
                    ),
                    const Divider(color: Color(0xFF6F4E37), thickness: 1.5),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF5A1226),
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=11'), // Simula una foto de estudiante real
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nombre:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text(usuario.nombreCompleto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Matrícula / No. Control:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              // ¡AQUÍ YA MUESTRA TU NÚMERO REAL ESCRITO!
                              Text(usuario.numeroControl.isEmpty ? 'Sin Registro' : usuario.numeroControl, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                              const SizedBox(height: 8),
                              const Text('Especialidad:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text(usuario.especialidad, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6F4E37))),
                              const SizedBox(height: 8),
                              const Text('Grupo:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text(usuario.grupo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          // EL CÓDIGO QR DINÁMICO
                          QrImageView(
                            data: dataQr,
                            version: QrVersions.auto,
                            size: 160.0,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CÓDIGO DE ACCESO DINÁMICO',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Estatus: Alumno Regular / Acceso Permitido',
                      style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// VISTA 3: PANTALLA DE PERFIL (CON HISTORIAL EN TIEMPO REAL)
// ==========================================
class VistaPerfil extends StatelessWidget {
  const VistaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UsuarioProvider>(context);
    final FirestoreService firestoreService = FirestoreService();

    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF5A1226),
              backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=11'),
            ),
            const SizedBox(height: 12),
            Text(usuario.nombreCompleto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(usuario.correo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 24),
            
            // SECCIÓN: FICHA MÉDICA DE EMERGENCIA
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.medical_services, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text(
                          'Ficha Médica de Emergencia',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tipo de Sangre:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(usuario.tipoSanguineo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Alergias:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(usuario.alergias, style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SECCIÓN: HISTORIAL DE ASISTENCIA (AHORA REAL DESDE FIREBASE)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.history, color: Color(0xFF6F4E37)),
                        SizedBox(width: 8),
                        Text(
                          'Historial de Accesos Real',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6F4E37)),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // La antena que conecta a la subcolección de Firebase
                    StreamBuilder<QuerySnapshot>(
                      stream: firestoreService.obtenerHistorialAsistencias(usuario.numeroControl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No hay registros de asistencia todavía.', style: TextStyle(fontSize: 13, color: Colors.grey));
                        }

                        final docs = snapshot.data!.docs;

                        return Column(
                          children: docs.map((doc) {
                            final acceso = doc.data() as Map<String, dynamic>;
                            bool esRetardo = acceso['estado'] == 'Retardo';

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.login, 
                                        size: 16, 
                                        color: esRetardo ? Colors.orange : Colors.green
                                      ),
                                      const SizedBox(width: 8),
                                      Text(acceso['fecha'] ?? '--/--/----', style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  Text(acceso['hora'] ?? '--:-- --', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: esRetardo ? Colors.orange[50] : Colors.green[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      acceso['estado'] ?? 'Desconocido',
                                      style: TextStyle(
                                        fontSize: 11, 
                                        fontWeight: FontWeight.bold, 
                                        color: esRetardo ? Colors.orange[800] : Colors.green[800]
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // BOTÓN: CERRAR SESIÓN
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Provider.of<UsuarioProvider>(context, listen: false).cerrarSesion();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreenPlaceholder()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreenPlaceholder extends StatelessWidget {
  const LoginScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}