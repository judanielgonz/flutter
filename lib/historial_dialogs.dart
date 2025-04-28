import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class HistorialDialogs {
  final ApiService apiService = ApiService();
  final String correo;
  final String tipoUsuario;
  final String? medicoCorreo;
  final List<dynamic> historial;
  final BuildContext context;
  final VoidCallback onHistorialUpdated;

  // Controladores para los formularios
  final TextEditingController _sintomaController = TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _tratamientoController = TextEditingController();
  final TextEditingController _medicamentoNombreController = TextEditingController();
  final TextEditingController _medicamentoDosisController = TextEditingController();
  final TextEditingController _medicamentoFrecuenciaController = TextEditingController();
  final TextEditingController _sintomasParaDiagnosticoController = TextEditingController();
  final TextEditingController _ordenAnalisisTipoController = TextEditingController();
  final TextEditingController _medicoCorreoController = TextEditingController();

  HistorialDialogs({
    required this.correo,
    required this.tipoUsuario,
    required this.historial,
    required this.context,
    required this.onHistorialUpdated,
    this.medicoCorreo,
  });

  Map<String, Color> _getColorsForRole() {
    switch (tipoUsuario) {
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

  Future<void> _guardarEntrada(String tipo, Map<String, dynamic> datos) async {
    try {
      final String correoRegistrador = tipoUsuario == 'medico' ? medicoCorreo ?? '' : correo;
      if (correoRegistrador.isEmpty) {
        throw Exception('Correo del registrador no proporcionado');
      }

      await apiService.guardarEntradaHistorial(
        correoRegistrador,
        tipo,
        correo,
        datos,
      );
      onHistorialUpdated();
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
        final String correoRegistrador = tipoUsuario == 'medico' ? medicoCorreo ?? '' : correo;
        if (correoRegistrador.isEmpty) {
          throw Exception('Correo del registrador no proporcionado');
        }

        await apiService.subirDocumento(correoRegistrador, correo, file);
        onHistorialUpdated();
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

  Future<void> _subirResultadoAnalisis(String ordenId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        await apiService.subirResultadoAnalisis(correo, correo, ordenId, file);
        onHistorialUpdated();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resultado de análisis subido con éxito'),
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
          content: Text('Error al subir el resultado: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _generarDiagnostico(String sintomasText, bool isGenerating) async {
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

      if (isGenerating) {
        showDialog(
          context: context,
          barrierDismissible: false,
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
      }

      final diagnosticoData = await apiService.generarDiagnostico(sintomasText);

      if (isGenerating) {
        Navigator.pop(context);
      }

      _mostrarDialogoDiagnostico(diagnosticoData);
    } catch (e) {
      if (isGenerating) {
        Navigator.pop(context);
      }
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
            onPressed: () {
              Clipboard.setData(ClipboardData(text: diagnosticoData['fullDiagnosisText'] ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diagnóstico copiado al portapapeles'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Copiar', style: TextStyle(color: Colors.blue)),
          ),
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

  void showAgregarEntradaDialog() {
    if (tipoUsuario == 'paciente') {
      _mostrarDialogoSeleccionTipoPaciente();
    } else if (tipoUsuario == 'medico') {
      _mostrarDialogoSeleccionTipoMedico();
    }
  }

  void _mostrarDialogoSeleccionTipoPaciente() {
    final colors = _getColorsForRole();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Seleccionar Acción',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors['accent']),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Agregar Síntoma', () => _mostrarDialogoAgregarSintoma(), colors['accent']!),
            _buildDialogOption('Subir Resultado de Análisis', () => _mostrarDialogoSeleccionOrdenAnalisis(), colors['accent']!),
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

  void _mostrarDialogoSeleccionTipoMedico() {
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
            _buildDialogOption('Orden de Análisis', () => _mostrarDialogoAgregarOrdenAnalisis(), colors['accent']!),
            _buildDialogOption('Subir Documento PDF', () => _subirDocumento(), colors['accent']!),
            _buildDialogOption('Generar Diagnóstico con IA', () => _mostrarDialogoSeleccionMetodoDiagnostico(), colors['accent']!),
            _buildDialogOption('Otorgar Permiso a Otro Médico', () => _mostrarDialogoOtorgarPermiso(), colors['accent']!),
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

  void _mostrarDialogoSeleccionOrdenAnalisis() {
    final colors = _getColorsForRole();
    List<dynamic> ordenes = [];
    for (var entry in historial) {
      if (entry['ordenes_analisis']?.isNotEmpty ?? false) {
        ordenes.addAll(entry['ordenes_analisis'].map((e) => {...e, 'historialId': entry['_id']}));
      }
    }

    if (ordenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay órdenes de análisis pendientes'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Seleccionar Orden de Análisis',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors['accent']),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ordenes.map((orden) {
              return _buildDialogOption(
                orden['tipo'],
                () => _subirResultadoAnalisis(orden['orden_id']),
                colors['accent']!,
              );
            }).toList(),
          ),
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
    _generarDiagnostico(sintomasText, true);
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
    bool enlazarSintoma = false;
    String? sintomaId;

    List<dynamic> sintomas = [];
    for (var entry in historial) {
      if (entry['sintomas']?.isNotEmpty ?? false) {
        sintomas.addAll(entry['sintomas']);
      }
    }

    _mostrarDialogo(
      title: 'Agregar Diagnóstico',
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _diagnosticoController,
                  decoration: InputDecoration(
                    labelText: 'Descripción del diagnóstico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.medical_information, color: colors['accent']),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Enlazar a un síntoma?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors['accent'],
                  ),
                ),
                const SizedBox(height: 8),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  selectedBorderColor: colors['accent'],
                  fillColor: colors['accent'],
                  borderColor: Colors.grey.shade300,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('No'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Sí'),
                    ),
                  ],
                  isSelected: [!enlazarSintoma, enlazarSintoma],
                  onPressed: (index) {
                    setStateDialog(() {
                      enlazarSintoma = index == 1;
                      if (!enlazarSintoma) {
                        sintomaId = null;
                      }
                    });
                  },
                ),
                if (enlazarSintoma && sintomas.isEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'No hay síntomas registrados.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
                if (enlazarSintoma && sintomas.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Seleccionar síntoma',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors['accent'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: DropdownButton<String>(
                      value: sintomaId,
                      isExpanded: true,
                      hint: const Text('Selecciona un síntoma'),
                      items: sintomas.map((sintoma) {
                        return DropdownMenuItem<String>(
                          value: sintoma['_id'],
                          child: Text(
                            sintoma['descripcion'] ?? 'Sin descripción',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          sintomaId = newValue;
                        });
                      },
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: colors['accent'],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      onSave: () {
        if (_diagnosticoController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa un diagnóstico'), backgroundColor: Colors.redAccent),
          );
          return;
        }
        final datos = {
          'descripcion': _diagnosticoController.text,
          if (sintomaId != null) 'sintoma_id': sintomaId,
        };
        _guardarEntrada('diagnosticos', datos);
      },
      accentColor: colors['accent']!,
    );
  }

  void _mostrarDialogoAgregarTratamiento() {
    final colors = _getColorsForRole();
    _tratamientoController.clear();
    bool enlazarDiagnostico = false;
    String? diagnosticoId;

    List<dynamic> diagnosticos = [];
    for (var entry in historial) {
      if (entry['diagnosticos']?.isNotEmpty ?? false) {
        diagnosticos.addAll(entry['diagnosticos']);
      }
    }

    _mostrarDialogo(
      title: 'Agregar Tratamiento',
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _tratamientoController,
                  decoration: InputDecoration(
                    labelText: 'Descripción del tratamiento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.healing, color: colors['accent']),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Enlazar a un diagnóstico?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors['accent'],
                  ),
                ),
                const SizedBox(height: 8),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  selectedBorderColor: colors['accent'],
                  fillColor: colors['accent'],
                  borderColor: Colors.grey.shade300,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('No'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Sí'),
                    ),
                  ],
                  isSelected: [!enlazarDiagnostico, enlazarDiagnostico],
                  onPressed: (index) {
                    setStateDialog(() {
                      enlazarDiagnostico = index == 1;
                      if (!enlazarDiagnostico) {
                        diagnosticoId = null;
                      }
                    });
                  },
                ),
                if (enlazarDiagnostico && diagnosticos.isEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'No hay diagnósticos registrados.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
                if (enlazarDiagnostico && diagnosticos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Seleccionar diagnóstico',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors['accent'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: DropdownButton<String>(
                      value: diagnosticoId,
                      isExpanded: true,
                      hint: const Text('Selecciona un diagnóstico'),
                      items: diagnosticos.map((diagnostico) {
                        return DropdownMenuItem<String>(
                          value: diagnostico['_id'],
                          child: Text(
                            diagnostico['descripcion'] ?? 'Sin descripción',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          diagnosticoId = newValue;
                        });
                      },
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: colors['accent'],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      onSave: () {
        if (_tratamientoController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa un tratamiento'), backgroundColor: Colors.redAccent),
          );
          return;
        }
        final datos = {
          'descripcion': _tratamientoController.text,
          if (diagnosticoId != null) 'diagnostico_id': diagnosticoId,
        };
        _guardarEntrada('tratamientos', datos);
      },
      accentColor: colors['accent']!,
    );
  }

  void _mostrarDialogoAgregarMedicamento() {
    final colors = _getColorsForRole();
    _medicamentoNombreController.clear();
    _medicamentoDosisController.clear();
    _medicamentoFrecuenciaController.clear();
    bool enlazarTratamiento = false;
    String? tratamientoId;

    List<dynamic> tratamientos = [];
    for (var entry in historial) {
      if (entry['tratamientos']?.isNotEmpty ?? false) {
        tratamientos.addAll(entry['tratamientos']);
      }
    }

    _mostrarDialogo(
      title: 'Agregar Medicamento',
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _medicamentoNombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del medicamento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.medication, color: colors['accent']),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _medicamentoDosisController,
                  decoration: InputDecoration(
                    labelText: 'Dosis',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.local_pharmacy, color: colors['accent']),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _medicamentoFrecuenciaController,
                  decoration: InputDecoration(
                    labelText: 'Frecuencia',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.schedule, color: colors['accent']),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Enlazar a un tratamiento?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors['accent'],
                  ),
                ),
                const SizedBox(height: 8),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  selectedBorderColor: colors['accent'],
                  fillColor: colors['accent'],
                  borderColor: Colors.grey.shade300,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('No'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Sí'),
                    ),
                  ],
                  isSelected: [!enlazarTratamiento, enlazarTratamiento],
                  onPressed: (index) {
                    setStateDialog(() {
                      enlazarTratamiento = index == 1;
                      if (!enlazarTratamiento) {
                        tratamientoId = null;
                      }
                    });
                  },
                ),
                if (enlazarTratamiento && tratamientos.isEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'No hay tratamientos registrados.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
                if (enlazarTratamiento && tratamientos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Seleccionar tratamiento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors['accent'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: DropdownButton<String>(
                      value: tratamientoId,
                      isExpanded: true,
                      hint: const Text('Selecciona un tratamiento'),
                      items: tratamientos.map((tratamiento) {
                        return DropdownMenuItem<String>(
                          value: tratamiento['_id'],
                          child: Text(
                            tratamiento['descripcion'] ?? 'Sin descripción',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          tratamientoId = newValue;
                        });
                      },
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: colors['accent'],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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
        final datos = {
          'nombre': _medicamentoNombreController.text,
          'dosis': _medicamentoDosisController.text,
          'frecuencia': _medicamentoFrecuenciaController.text,
          'fecha_inicio': DateTime.now().toIso8601String(),
          if (tratamientoId != null) 'tratamiento_id': tratamientoId,
        };
        _guardarEntrada('medicamentos', datos);
      },
      accentColor: colors['accent']!,
    );
  }

  void _mostrarDialogoAgregarOrdenAnalisis() {
    final colors = _getColorsForRole();
    _ordenAnalisisTipoController.clear();
    _mostrarDialogo(
      title: 'Agregar Orden de Análisis',
      content: TextField(
        controller: _ordenAnalisisTipoController,
        decoration: InputDecoration(
          labelText: 'Tipo de análisis (ej. Análisis de sangre)',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.science, color: colors['accent']),
        ),
        maxLines: 1,
      ),
      onSave: () {
        if (_ordenAnalisisTipoController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa el tipo de análisis'), backgroundColor: Colors.redAccent),
          );
          return;
        }
        final uuid = Uuid();
        _guardarEntrada('ordenes_analisis', {
          'orden_id': uuid.v4(),
          'tipo': _ordenAnalisisTipoController.text,
          'estado': 'Pendiente',
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
      onSave: () => _generarDiagnostico(_sintomasParaDiagnosticoController.text, true),
      accentColor: colors['accent']!,
    );
  }

  void _mostrarDialogoOtorgarPermiso() {
    final colors = _getColorsForRole();
    _medicoCorreoController.clear();
    _mostrarDialogo(
      title: 'Otorgar Permiso a Otro Médico',
      content: TextField(
        controller: _medicoCorreoController,
        decoration: InputDecoration(
          labelText: 'Correo del médico',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.email, color: colors['accent']),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      onSave: () async {
        if (_medicoCorreoController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, ingresa el correo del médico'), backgroundColor: Colors.redAccent),
          );
          return;
        }
        try {
          final response = await apiService.otorgarPermisoHistorial(correo, _medicoCorreoController.text);
          Navigator.pop(context);
          if (response['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Permiso otorgado con éxito'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['error'] ?? 'Error al otorgar permiso'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al otorgar permiso: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
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
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void dispose() {
    _sintomaController.dispose();
    _diagnosticoController.dispose();
    _tratamientoController.dispose();
    _medicamentoNombreController.dispose();
    _medicamentoDosisController.dispose();
    _medicamentoFrecuenciaController.dispose();
    _sintomasParaDiagnosticoController.dispose();
    _ordenAnalisisTipoController.dispose();
    _medicoCorreoController.dispose();
  }
}