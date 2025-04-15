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
  final ApiService apiService = ApiService();

  final TextEditingController _sintomaController = TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _tratamientoController = TextEditingController();
  final TextEditingController _medicamentoNombreController = TextEditingController();
  final TextEditingController _medicamentoDosisController = TextEditingController();
  final TextEditingController _medicamentoFrecuenciaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    try {
      final historialData = await apiService.getHistorialMedico(widget.correo);
      print('Historial recibido: $historialData'); // Para depurar
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
        {
          ...datos,
          'pacienteCorreo': widget.correo,
        },
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

  void _mostrarDialogoAgregarEntrada() {
    if (widget.tipoUsuario == 'paciente') {
      _mostrarDialogoAgregarSintoma();
    } else if (widget.tipoUsuario == 'medico') {
      _mostrarDialogoSeleccionTipo();
    }
  }

  void _mostrarDialogoSeleccionTipo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Seleccionar Tipo de Entrada',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Síntoma', () => _mostrarDialogoAgregarSintoma()),
            _buildDialogOption('Diagnóstico', () => _mostrarDialogoAgregarDiagnostico()),
            _buildDialogOption('Tratamiento', () => _mostrarDialogoAgregarTratamiento()),
            _buildDialogOption('Medicamento', () => _mostrarDialogoAgregarMedicamento()),
            _buildDialogOption('Subir Documento PDF', () => _subirDocumento()),
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

  Widget _buildDialogOption(String title, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  void _mostrarDialogoAgregarSintoma() {
    _sintomaController.clear();
    _mostrarDialogo(
      title: 'Agregar Síntoma',
      content: TextField(
        controller: _sintomaController,
        decoration: const InputDecoration(
          labelText: 'Descripción del síntoma',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.sick, color: Colors.teal),
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
    );
  }

  void _mostrarDialogoAgregarDiagnostico() {
    _diagnosticoController.clear();
    _mostrarDialogo(
      title: 'Agregar Diagnóstico',
      content: TextField(
        controller: _diagnosticoController,
        decoration: const InputDecoration(
          labelText: 'Descripción del diagnóstico',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.medical_information, color: Colors.teal),
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
    );
  }

  void _mostrarDialogoAgregarTratamiento() {
    _tratamientoController.clear();
    _mostrarDialogo(
      title: 'Agregar Tratamiento',
      content: TextField(
        controller: _tratamientoController,
        decoration: const InputDecoration(
          labelText: 'Descripción del tratamiento',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.healing, color: Colors.teal),
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
    );
  }

  void _mostrarDialogoAgregarMedicamento() {
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
              decoration: const InputDecoration(
                labelText: 'Nombre del medicamento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _medicamentoDosisController,
              decoration: const InputDecoration(
                labelText: 'Dosis',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_pharmacy, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _medicamentoFrecuenciaController,
              decoration: const InputDecoration(
                labelText: 'Frecuencia',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule, color: Colors.teal),
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
    );
  }

  void _mostrarDialogo({required String title, required Widget content, required VoidCallback onSave}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
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
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : historial.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay registros en el historial',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : _buildHistorialList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarEntrada,
        backgroundColor: Colors.teal.shade700,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        elevation: 6,
        tooltip: 'Agregar entrada',
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.teal.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.medical_services,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          const Text(
            "Historial Médico",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Paciente: ${widget.correo}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: historial.length,
      itemBuilder: (context, index) {
        final entrada = historial[index];
        return _buildHistorialCard(entrada);
      },
    );
  }

  Widget _buildHistorialCard(Map<String, dynamic> entrada) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            if (entrada['sintomas']?.isNotEmpty ?? false) ...[
              _buildCategorySection('Síntomas', entrada['sintomas'], Icons.sick, Colors.redAccent),
            ],
            if (entrada['diagnosticos']?.isNotEmpty ?? false) ...[
              _buildCategorySection('Diagnósticos', entrada['diagnosticos'], Icons.medical_information, Colors.blueAccent),
            ],
            if (entrada['tratamientos']?.isNotEmpty ?? false) ...[
              _buildCategorySection('Tratamientos', entrada['tratamientos'], Icons.healing, Colors.green),
            ],
            if (entrada['medicamentos']?.isNotEmpty ?? false) ...[
              _buildCategorySection('Medicamentos', entrada['medicamentos'], Icons.medication, Colors.orange),
            ],
            if (entrada['resultados_analisis']?.isNotEmpty ?? false) ...[
              _buildCategorySection('Resultados de Análisis', entrada['resultados_analisis'], Icons.analytics, Colors.purple),
            ],
            if (entrada['documentos']?.isNotEmpty ?? false) ...[
              _buildDocumentSection('Documentos', entrada['documentos'], entrada['_id'], Icons.picture_as_pdf, Colors.teal),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<dynamic> entries, IconData icon, Color color) {
    return ExpansionTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: color,
        ),
      ),
      children: entries.map((entry) {
        String detalle = '';
        String fecha = entry['fecha'] ?? entry['fecha_inicio'] ?? 'Sin fecha';

        if (title == 'Síntomas' || title == 'Diagnósticos' || title == 'Tratamientos') {
          detalle = entry['descripcion'] ?? 'Sin descripción';
        } else if (title == 'Medicamentos') {
          detalle = '${entry['nombre']} - ${entry['dosis']} (${entry['frecuencia']})';
        } else if (title == 'Resultados de Análisis') {
          detalle = entry['resultados'].toString();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detalle,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Fecha: $fecha',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocumentSection(String title, List<dynamic> documents, String historialId, IconData icon, Color color) {
    return ExpansionTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: color,
        ),
      ),
      children: documents.map((doc) {
        String documentoId = doc['_id'] ?? 'Sin ID';
        String fecha = doc['fecha'] ?? 'Sin fecha';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Documento PDF',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Fecha: $fecha',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.teal),
                  onPressed: () => _descargarDocumento(historialId, documentoId),
                  tooltip: 'Descargar y abrir PDF',
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
    super.dispose();
  }
}