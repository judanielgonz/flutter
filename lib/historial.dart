import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class HistorialPage extends StatefulWidget {
  final String correo;
  final String tipoUsuario;
  final String? medicoCorreo;

  const HistorialPage({
    required this.correo,
    required this.tipoUsuario,
    this.medicoCorreo,
    Key? key,
  }) : super(key: key);

  @override
  _HistorialPageState createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  List<dynamic> historial = [];
  bool isLoading = true;
  bool isGeneratingDiagnosis = false; // Nueva variable para controlar la animación de carga
  final ApiService apiService = ApiService();

  final TextEditingController _sintomaController = TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _tratamientoController = TextEditingController();
  final TextEditingController _medicamentoNombreController = TextEditingController();
  final TextEditingController _medicamentoDosisController = TextEditingController();
  final TextEditingController _medicamentoFrecuenciaController = TextEditingController();
  final TextEditingController _sintomasParaDiagnosticoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    try {
      final historialData = await apiService.getHistorialMedico(widget.correo);
      setState(() {
        historial = historialData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar el historial: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _guardarEntrada(String tipo, Map<String, dynamic> datos) async {
    try {
      final String correoRegistrador = widget.tipoUsuario == 'medico' ? widget.medicoCorreo ?? '' : widget.correo;
      if (correoRegistrador.isEmpty) {
        throw Exception('Correo del registrador no proporcionado');
      }

      await apiService.guardarEntradaHistorial(
        correoRegistrador,
        tipo,
        widget.correo,
        datos,
      );
      await _fetchHistorial();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$tipo guardado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _subirDocumento() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        final String correoRegistrador = widget.tipoUsuario == 'medico' ? widget.medicoCorreo ?? '' : widget.correo;
        if (correoRegistrador.isEmpty) {
          throw Exception('Correo del registrador no proporcionado');
        }

        await apiService.subirDocumento(correoRegistrador, widget.correo, file);
        await _fetchHistorial();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento PDF subido con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se seleccionó ningún archivo'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir el documento: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _descargarDocumento(String historialId, String documentoId) async {
    try {
      final filePath = await apiService.descargarDocumento(historialId, documentoId);
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el documento: ${result.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar el documento: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _generarDiagnostico(String sintomasText) async {
    try {
      if (sintomasText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay síntomas para analizar'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Mostrar animación de carga
      setState(() {
        isGeneratingDiagnosis = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false, // Evitar que el usuario cierre el diálogo mientras carga
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _getColorsForRole()['accent']),
              const SizedBox(height: 16),
              const Text('Generando diagnóstico...'),
            ],
          ),
        ),
      );

      // Generar el diagnóstico
      final diagnosticoData = await apiService.generarDiagnostico(sintomasText);

      // Cerrar el diálogo de carga
      Navigator.pop(context);
      setState(() {
        isGeneratingDiagnosis = false;
      });

      // Mostrar el diagnóstico generado
      _mostrarDialogoDiagnostico(diagnosticoData);
    } catch (e) {
      Navigator.pop(context); // Cerrar el diálogo de carga en caso de error
      setState(() {
        isGeneratingDiagnosis = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar diagnóstico: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _mostrarDialogoDiagnostico(Map<String, dynamic> diagnosticoData) {
    final colors = _getColorsForRole();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Diagnóstico Generado por IA',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors['accent']),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Síntomas Detectados:',
                style: TextStyle(fontWeight: FontWeight.bold, color: colors['accent']),
              ),
              const SizedBox(height: 5),
              ...diagnosticoData['symptoms'].map<Widget>((sintoma) => Text('- $sintoma')).toList(),
              const SizedBox(height: 10),
              Text(
                'Posibles Diagnósticos:',
                style: TextStyle(fontWeight: FontWeight.bold, color: colors['accent']),
              ),
              const SizedBox(height: 5),
              ...diagnosticoData['possibleDiagnoses'].map<Widget>((diag) => Text(
                  '- ${diag['diagnosis']} (${(diag['probability'] * 100).toStringAsFixed(0)}%)')),
              const SizedBox(height: 10),
              Text(
                'Diagnóstico Principal:',
                style: TextStyle(fontWeight: FontWeight.bold, color: colors['accent']),
              ),
              const SizedBox(height: 5),
              Text(diagnosticoData['diagnosis']),
              const SizedBox(height: 10),
              Text(
                'Recomendaciones:',
                style: TextStyle(fontWeight: FontWeight.bold, color: colors['accent']),
              ),
              const SizedBox(height: 5),
              Text(diagnosticoData['treatment']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  String _extraerSintomasDelHistorial() {
    List<String> sintomas = [];
    for (var entry in historial) {
      if (entry['sintomas']?.isNotEmpty ?? false) {
        for (var sintoma in entry['sintomas']) {
          if (sintoma['descripcion'] != null && sintoma['descripcion'].isNotEmpty) {
            sintomas.add(sintoma['descripcion']);
          }
        }
      }
    }
    return sintomas.isNotEmpty ? 'Paciente con ${sintomas.join(", ")}.' : '';
  }

  Map<String, Color> _getColorsForRole() {
    switch (widget.tipoUsuario) {
      case 'medico':
        return {
          'header': Colors.red.shade600,
          'headerGradient': Colors.red.shade400,
          'accent': Colors.red.shade500,
          'iconBackground': Colors.red.shade500,
        };
      case 'paciente':
        return {
          'header': Colors.blue.shade600,
          'headerGradient': Colors.blue.shade400,
          'accent': Colors.blue.shade500,
          'iconBackground': Colors.blue.shade500,
        };
      default:
        return {
          'header': Colors.teal.shade600,
          'headerGradient': Colors.teal.shade400,
          'accent': Colors.teal.shade500,
          'iconBackground': Colors.teal.shade500,
        };
    }
  }

  void _mostrarDialogoAgregarEntrada() {
    if (widget.tipoUsuario == 'paciente') {
      _mostrarDialogoAgregarSintoma();
    } else if (widget.tipoUsuario == 'medico') {
      _mostrarDialogoSeleccionTipo();
    }
  }

  void _mostrarDialogoSeleccionTipo() {
    final colors = _getColorsForRole();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Seleccionar Tipo de Entrada',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors['accent']),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Síntoma', () => _mostrarDialogoAgregarSintoma(), colors['accent']!),
            _buildDialogOption('Diagnóstico', () => _mostrarDialogoAgregarDiagnostico(), colors['accent']!),
            _buildDialogOption('Tratamiento', () => _mostrarDialogoAgregarTratamiento(), colors['accent']!),
            _buildDialogOption('Medicamento', () => _mostrarDialogoAgregarMedicamento(), colors['accent']!),
            _buildDialogOption('Subir Documento PDF', () => _subirDocumento(), colors['accent']!),
            _buildDialogOption('Generar Diagnóstico con IA', () => _mostrarDialogoSeleccionMetodoDiagnostico(), colors['accent']!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoSeleccionMetodoDiagnostico() {
    final colors = _getColorsForRole();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Seleccionar Método',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors['accent']),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Escribir Síntomas', () => _mostrarDialogoEscribirSintomas(), colors['accent']!),
            _buildDialogOption('Usar Síntomas del Historial', () => _usarSintomasDelHistorial(), colors['accent']!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _usarSintomasDelHistorial() {
    final sintomasText = _extraerSintomasDelHistorial();
    if (sintomasText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron síntomas en el historial'),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context);
      return;
    }
    _generarDiagnostico(sintomasText);
  }

  Widget _buildDialogOption(String title, VoidCallback onTap, Color accentColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: accentColor, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  void _mostrarDialogoAgregarSintoma() {
    final colors = _getColorsForRole();
    _sintomaController.clear();
    _mostrarDialogo(
      title: 'Agregar Síntoma',
      content: TextField(
        controller: _sintomaController,
        decoration: InputDecoration(
          labelText: 'Descripción del síntoma',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.sick, color: colors['accent']),
        ),
        maxLines: 3,
      ),
      onSave: () {
        if (_sintomaController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa un síntoma'), backgroundColor: Colors.redAccent),
          );
          return;
        }
        _guardarEntrada('sintomas', {'descripcion': _sintomaController.text});
      },
      accentColor: colors['accent']!,
    );
  }

  void _mostrarDialogoAgregarDiagnostico() {
    final colors = _getColorsForRole();
    _diagnosticoController.clear();
    _mostrarDialogo(
      title: 'Agregar Diagnóstico',
      content: TextField(
        controller: _diagnosticoController,
        decoration: InputDecoration(
          labelText: 'Descripción del diagnóstico',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.medical_information, color: colors['accent']),
        ),
        maxLines: 3,
      ),
      onSave: () {
        if (_diagnosticoController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa un diagnóstico'), backgroundColor: Colors.redAccent),
          );
          return;
        }
        _guardarEntrada('diagnosticos', {'descripcion': _diagnosticoController.text});
      },
      accentColor: colors['accent']!,
    );
  }

  void _mostrarDialogoAgregarTratamiento() {
    final colors = _getColorsForRole();
    _tratamientoController.clear();
    _mostrarDialogo(
      title: 'Agregar Tratamiento',
      content: TextField(
        controller: _tratamientoController,
        decoration: InputDecoration(
          labelText: 'Descripción del tratamiento',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.healing, color: colors['accent']),
        ),
        maxLines: 3,
      ),
      onSave: () {
        if (_tratamientoController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa un tratamiento'), backgroundColor: Colors.redAccent),
          );
          return;
        }
        _guardarEntrada('tratamientos', {'descripcion': _tratamientoController.text});
      },
      accentColor: colors['accent']!,
    );
  }

  void _mostrarDialogoAgregarMedicamento() {
    final colors = _getColorsForRole();
    _medicamentoNombreController.clear();
    _medicamentoDosisController.clear();
    _medicamentoFrecuenciaController.clear();
    _mostrarDialogo(
      title: 'Agregar Medicamento',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _medicamentoNombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del medicamento',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication, color: colors['accent']),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _medicamentoDosisController,
              decoration: InputDecoration(
                labelText: 'Dosis',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_pharmacy, color: colors['accent']),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _medicamentoFrecuenciaController,
              decoration: InputDecoration(
                labelText: 'Frecuencia',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule, color: colors['accent']),
              ),
            ),
          ],
        ),
      ),
      onSave: () {
        if (_medicamentoNombreController.text.isEmpty ||
            _medicamentoDosisController.text.isEmpty ||
            _medicamentoFrecuenciaController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, completa todos los campos'), backgroundColor: Colors.redAccent),
          );
          return;
        }
        _guardarEntrada('medicamentos', {
          'nombre': _medicamentoNombreController.text,
          'dosis': _medicamentoDosisController.text,
          'frecuencia': _medicamentoFrecuenciaController.text,
          'fecha_inicio': DateTime.now().toIso8601String(),
        });
      },
      accentColor: colors['accent']!,
    );
  }

  void _mostrarDialogoEscribirSintomas() {
    final colors = _getColorsForRole();
    _sintomasParaDiagnosticoController.clear();
    _mostrarDialogo(
      title: 'Generar Diagnóstico con IA',
      content: TextField(
        controller: _sintomasParaDiagnosticoController,
        decoration: InputDecoration(
          labelText: 'Describe los síntomas del paciente',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.analytics, color: colors['accent']),
        ),
        maxLines: 3,
      ),
      onSave: () => _generarDiagnostico(_sintomasParaDiagnosticoController.text),
      accentColor: colors['accent']!,
    );
  }

  void _mostrarDialogo({
    required String title,
    required Widget content,
    required VoidCallback onSave,
    required Color accentColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: accentColor),
        ),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Diagnosticar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForRole();
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(colors),
            TabBar(
              isScrollable: true,
              indicatorColor: colors['accent'],
              labelColor: colors['accent'],
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Síntomas'),
                Tab(text: 'Diagnósticos'),
                Tab(text: 'Tratamientos'),
                Tab(text: 'Medicamentos'),
                Tab(text: 'Análisis'),
                Tab(text: 'Documentos'),
              ],
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: colors['accent']))
                  : historial.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay registros en el historial',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : TabBarView(
                          children: [
                            _buildTabContent('sintomas', Icons.sick, colors),
                            _buildTabContent('diagnosticos', Icons.medical_information, colors),
                            _buildTabContent('tratamientos', Icons.healing, colors),
                            _buildTabContent('medicamentos', Icons.medication, colors),
                            _buildTabContent('resultados_analisis', Icons.analytics, colors),
                            _buildDocumentTab('documentos', Icons.picture_as_pdf, colors),
                          ],
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _mostrarDialogoAgregarEntrada,
          backgroundColor: colors['accent'],
          child: const Icon(Icons.add, color: Colors.white, size: 30),
          elevation: 6,
          tooltip: 'Agregar entrada',
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors['header']!, colors['headerGradient']!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colors['iconBackground'],
                child: Icon(
                  widget.tipoUsuario == 'medico' ? Icons.medical_services : Icons.person,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historial Médico',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.correo,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String key, IconData icon, Map<String, Color> colors) {
    List<dynamic> entries = [];
    for (var entry in historial) {
      if (entry[key]?.isNotEmpty ?? false) {
        entries.addAll(entry[key].map((e) => {...e, 'historialId': entry['_id']}));
      }
    }

    return entries.isEmpty
        ? const Center(
            child: Text(
              'No hay registros',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              String detalle = '';
              String fecha = entry['fecha'] ?? entry['fecha_inicio'] ?? 'Sin fecha';

              if (key == 'sintomas' || key == 'diagnosticos' || key == 'tratamientos') {
                detalle = entry['descripcion'] ?? 'Sin descripción';
              } else if (key == 'medicamentos') {
                detalle = '${entry['nombre']} - ${entry['dosis']} (${entry['frecuencia']})';
              } else if (key == 'resultados_analisis') {
                detalle = entry['resultados'].toString();
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: colors['accent']!),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Icon(icon, color: colors['accent'], size: 30),
                    title: Text(
                      detalle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    subtitle: Text(
                      'Fecha: $fecha',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildDocumentTab(String key, IconData icon, Map<String, Color> colors) {
    List<dynamic> documents = [];
    for (var entry in historial) {
      if (entry[key]?.isNotEmpty ?? false) {
        documents.addAll(entry[key].map((e) => {...e, 'historialId': entry['_id']}));
      }
    }

    return documents.isEmpty
        ? const Center(
            child: Text(
              'No hay documentos',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              String documentoId = doc['_id'] ?? 'Sin ID';
              String fecha = doc['fecha'] ?? 'Sin fecha';
              String historialId = doc['historialId'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: colors['accent']!),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Icon(icon, color: colors['accent'], size: 30),
                    title: const Text(
                      'Documento PDF',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    subtitle: Text(
                      'Fecha: $fecha',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.download, color: colors['accent']),
                      onPressed: () => _descargarDocumento(historialId, documentoId),
                      tooltip: 'Descargar y abrir PDF',
                    ),
                  ),
                ),
              );
            },
          );
  }

  @override
  void dispose() {
    _sintomaController.dispose();
    _diagnosticoController.dispose();
    _tratamientoController.dispose();
    _medicamentoNombreController.dispose();
    _medicamentoDosisController.dispose();
    _medicamentoFrecuenciaController.dispose();
    _sintomasParaDiagnosticoController.dispose();
    super.dispose();
  }
}