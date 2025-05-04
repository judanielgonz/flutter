import 'package:flutter/material.dart';
import 'package:saludgest_app/api_service.dart';
import 'package:saludgest_app/historial_dialogs.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';

class HistorialPage extends StatefulWidget {
  final String correo;
  final String tipoUsuario;
  final String? medicoCorreo;
  final String? nombre; // Hacer 'nombre' opcional

  const HistorialPage({
    required this.correo,
    required this.tipoUsuario,
    this.medicoCorreo,
    this.nombre, // Cambiado a opcional
    Key? key,
  }) : super(key: key);

  @override
  _HistorialPageState createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  List<dynamic> historial = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();

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
    final dialogs = HistorialDialogs(
      correo: widget.correo,
      tipoUsuario: widget.tipoUsuario,
      medicoCorreo: widget.medicoCorreo,
      nombrePaciente: widget.nombre ?? 'Paciente', // Usar valor predeterminado si 'nombre' es null
      historial: historial,
      context: context,
      onHistorialUpdated: _fetchHistorial,
    );
    dialogs.showAgregarEntradaDialog();
  }

  void _mostrarContenidoCompleto(String title, String contenido, Color accentColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: accentColor),
        ),
        content: SingleChildScrollView(
          child: Text(
            contenido,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: contenido));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contenido copiado al portapapeles'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Copiar', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForRole();
    return DefaultTabController(
      length: 7,
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
                Tab(text: 'Órdenes de Análisis'),
                Tab(text: 'Análisis'),
                Tab(text: 'Diagnósticos'),
                Tab(text: 'Tratamiento'),
                Tab(text: 'Medicamentos'),
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
                            _buildOrdenesAnalisisTab('ordenes_analisis', Icons.science, colors),
                            _buildAnalisisTab('resultados_analisis', Icons.analytics, colors),
                            _buildTabContent('diagnosticos', Icons.medical_information, colors),
                            _buildTabContent('tratamientos', Icons.healing, colors),
                            _buildTabContent('medicamentos', Icons.medication, colors),
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
                    widget.nombre ?? 'Paciente', // Usar valor predeterminado si 'nombre' es null
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
                detalle = 'Resultado: ${entry['resultados'] ?? 'Sin resultados'}';
              }

              const int maxLength = 100;
              bool isTruncated = detalle.length > maxLength;
              String displayText = isTruncated ? '${detalle.substring(0, maxLength)}...' : detalle;

              String relacionado = '';
              if (key == 'diagnosticos') {
                if (entry['sintomas_relacionados'] != null && entry['sintomas_relacionados'].isNotEmpty) {
                  final sintomaId = entry['sintomas_relacionados'][0];
                  String? descripcionSintoma;
                  for (var hist in historial) {
                    final sintoma = hist['sintomas']?.firstWhere(
                      (s) => s['_id'] == sintomaId,
                      orElse: () => null,
                    );
                    if (sintoma != null) {
                      descripcionSintoma = sintoma['descripcion'];
                      break;
                    }
                  }
                  relacionado = descripcionSintoma ?? 'Síntoma no encontrado (ID: $sintomaId)';
                }
                if (entry['documento_relacionado'] != null) {
                  final documentoId = entry['documento_relacionado'];
                  String? nombreDocumento;
                  for (var hist in historial) {
                    final documento = hist['documentos']?.firstWhere(
                      (d) => d['_id'] == documentoId,
                      orElse: () => null,
                    );
                    if (documento != null) {
                      nombreDocumento = documento['nombre'];
                      break;
                    }
                  }
                  if (nombreDocumento != null) {
                    relacionado = (relacionado.isNotEmpty ? '$relacionado\n' : '') + nombreDocumento;
                  }
                }
              } else if (key == 'tratamientos') {
                if (entry['diagnostico_relacionado'] != null) {
                  final diagnosticoId = entry['diagnostico_relacionado'];
                  String? descripcionDiagnostico;
                  for (var hist in historial) {
                    final diagnostico = hist['diagnosticos']?.firstWhere(
                      (d) => d['_id'] == diagnosticoId,
                      orElse: () => null,
                    );
                    if (diagnostico != null) {
                      descripcionDiagnostico = diagnostico['descripcion'];
                      break;
                    }
                  }
                  relacionado = descripcionDiagnostico ?? 'Diagnóstico no encontrado (ID: $diagnosticoId)';
                }
              } else if (key == 'medicamentos') {
                if (entry['tratamiento_relacionado'] != null) {
                  final tratamientoId = entry['tratamiento_relacionado'];
                  String? descripcionTratamiento;
                  for (var hist in historial) {
                    final tratamiento = hist['tratamientos']?.firstWhere(
                      (t) => t['_id'] == tratamientoId,
                      orElse: () => null,
                    );
                    if (tratamiento != null) {
                      descripcionTratamiento = tratamiento['descripcion'];
                      break;
                    }
                  }
                  relacionado = descripcionTratamiento ?? 'Tratamiento no encontrado (ID: $tratamientoId)';
                }
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(icon, color: colors['accent'], size: 30),
                      title: Text(
                        displayText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha: $fecha',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (relacionado.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.link,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      relacionado,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade800,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        String title;
                        switch (key) {
                          case 'sintomas':
                            title = 'Síntoma';
                            break;
                          case 'diagnosticos':
                            title = 'Diagnóstico';
                            break;
                          case 'tratamientos':
                            title = 'Tratamiento';
                            break;
                          case 'medicamentos':
                            title = 'Medicamento';
                            break;
                          case 'resultados_analisis':
                            title = 'Resultado de Análisis';
                            break;
                          default:
                            title = 'Entrada';
                        }
                        _mostrarContenidoCompleto(title, detalle, colors['accent']!);
                      },
                      trailing: isTruncated
                          ? Icon(Icons.expand_more, color: colors['accent'])
                          : null,
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildAnalisisTab(String key, IconData icon, Map<String, Color> colors) {
    List<dynamic> analisis = [];
    for (var entry in historial) {
      if (entry[key]?.isNotEmpty ?? false) {
        analisis.addAll(entry[key].map((e) => {...e, 'historialId': entry['_id']}));
      }
    }

    return analisis.isEmpty
        ? const Center(
            child: Text(
              'No hay resultados de análisis',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: analisis.length,
            itemBuilder: (context, index) {
              final resultado = analisis[index];
              String fecha = resultado['fecha'] ?? 'Sin fecha';
              String historialId = resultado['historialId'] ?? '';
              String documentoId = '';
              String nombreDocumento = 'Resultado de Análisis';
              String ordenId = resultado['orden_id'] ?? '';

              for (var hist in historial) {
                final doc = hist['documentos']?.firstWhere(
                  (d) =>
                      d['tipo'] == 'resultado_analisis' &&
                      hist['resultados_analisis']
                          ?.any((r) => r['orden_id'] == ordenId && r['resultados'] == d['nombre']) ==
                      true,
                  orElse: () => null,
                );
                if (doc != null) {
                  documentoId = doc['_id'];
                  nombreDocumento = doc['nombre'] ?? 'Resultado de Análisis';
                  break;
                }
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
                      nombreDocumento,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    subtitle: Text(
                      'Fecha: $fecha',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: documentoId.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.download, color: colors['accent']),
                            onPressed: () => _descargarDocumento(historialId, documentoId),
                            tooltip: 'Descargar y abrir PDF',
                          )
                        : null,
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

    List<dynamic> otherDocuments = documents.where((doc) {
      return doc['tipo'] != 'resultado_analisis';
    }).toList();

    return otherDocuments.isEmpty
        ? const Center(
            child: Text(
              'No hay documentos',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: otherDocuments.length,
            itemBuilder: (context, index) {
              final doc = otherDocuments[index];
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
                    title: Text(
                      doc['nombre'] ?? 'Documento PDF',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
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

  Widget _buildOrdenesAnalisisTab(String key, IconData icon, Map<String, Color> colors) {
    List<dynamic> ordenes = [];
    for (var entry in historial) {
      if (entry[key]?.isNotEmpty ?? false) {
        ordenes.addAll(entry[key].map((e) => {...e, 'historialId': entry['_id']}));
      }
    }

    return ordenes.isEmpty
        ? const Center(
            child: Text(
              'No hay órdenes de análisis pendientes',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordenes.length,
            itemBuilder: (context, index) {
              final orden = ordenes[index];
              String tipo = orden['tipo'] ?? 'Sin tipo';
              String fecha = orden['fecha'] ?? 'Sin fecha';
              String estado = orden['estado'] ?? 'Pendiente';

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
                      tipo,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    subtitle: Text(
                      'Fecha: $fecha | Estado: $estado',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
  }
}