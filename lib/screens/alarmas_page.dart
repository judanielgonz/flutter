import 'package:flutter/material.dart';
import '../widgets/alarm_dialogs.dart' as alarmDialog;
import '../api_service.dart';
import '../models/alarm.dart';
import '../models/treatment.dart';

class AlarmasPage extends StatefulWidget {
  final String correo;

  const AlarmasPage({super.key, required this.correo});

  @override
  _AlarmasPageState createState() => _AlarmasPageState();
}

class _AlarmasPageState extends State<AlarmasPage> {
  List<Alarm> alarmas = [];
  List<Treatment> tratamientos = [];

  @override
  void initState() {
    super.initState();
    _loadAlarmas();
    _loadTratamientos();
  }

  Future<void> _loadAlarmas() async {
    try {
      final response = await ApiService().getAlarmas(widget.correo);
      setState(() {
        alarmas = response.map((json) => Alarm.fromJson(json)).toList().cast<Alarm>();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar alarmas: $e')),
      );
    }
  }

  Future<void> _loadTratamientos() async {
    try {
      final response = await ApiService().getHistorialMedico(widget.correo);
      setState(() {
        List<Map<String, dynamic>> medicamentos = [];
        for (var historial in response) {
          if (historial['medicamentos'] != null) {
            List<dynamic> meds = historial['medicamentos'];
            for (var med in meds) {
              medicamentos.add(med);
            }
          }
        }
        tratamientos = medicamentos.map((json) => Treatment.fromJson(json)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar medicamentos: $e')),
      );
    }
  }

  Future<void> _createAlarma(Alarm nuevaAlarma) async {
    try {
      await ApiService().registrarAlarma(widget.correo, {
        'medicamentoId': nuevaAlarma.medicamentoId,
        'nombreMedicamento': nuevaAlarma.nombreMedicamento,
        'dosis': nuevaAlarma.dosis,
        'frecuencia': nuevaAlarma.frecuencia,
        'hora': nuevaAlarma.hora,
        'dias': nuevaAlarma.dias,
        'tratamientoId': nuevaAlarma.tratamientoId,
      });
      await _loadAlarmas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarma creada exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear alarma: $e')),
      );
    }
  }

  Future<void> _editarAlarma(String id, Alarm alarmaActualizada) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID de alarma inválido');
      }
      print('Intentando editar alarma con ID: $id'); // Depuración
      await ApiService().editarAlarma(id, {
        'medicamentoId': alarmaActualizada.medicamentoId,
        'nombreMedicamento': alarmaActualizada.nombreMedicamento,
        'dosis': alarmaActualizada.dosis,
        'frecuencia': alarmaActualizada.frecuencia,
        'hora': alarmaActualizada.hora,
        'dias': alarmaActualizada.dias,
        'tratamientoId': alarmaActualizada.tratamientoId,
      });
      await _loadAlarmas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarma actualizada exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al editar alarma: $e')),
      );
    }
  }

  Future<void> _eliminarAlarma(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID de alarma inválido');
      }
      print('Intentando eliminar alarma con ID: $id'); // Depuración
      await ApiService().eliminarAlarma(id);
      await _loadAlarmas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarma eliminada exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar alarma: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarmas de Medicamentos'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Column(
        children: [
          Expanded(
            child: alarmas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.alarm_off, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          'No hay alarmas registradas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: alarmas.length,
                    itemBuilder: (context, index) {
                      final alarma = alarmas[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            alarma.nombreMedicamento,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hora: ${alarma.hora}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              Text(
                                'Días: ${alarma.dias.join(', ')}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  print('Botón de edición presionado para ID: ${alarma.id}'); // Depuración
                                  if (tratamientos.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No hay tratamientos disponibles para editar')),
                                    );
                                    return;
                                  }
                                  final alarmaEditada = await showDialog<Alarm>(
                                    context: context,
                                    builder: (context) => alarmDialog.AlarmDialog(
                                      tratamientos: tratamientos,
                                      alarma: alarma,
                                    ),
                                  );
                                  if (alarmaEditada != null) {
                                    await _editarAlarma(alarma.id, alarmaEditada);
                                  }
                                },
                                tooltip: 'Editar alarma',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  print('Botón de eliminación presionado para ID: ${alarma.id}'); // Depuración
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar eliminación'),
                                      content: const Text('¿Estás seguro de que deseas eliminar esta alarma?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmar == true) {
                                    await _eliminarAlarma(alarma.id);
                                  }
                                },
                                tooltip: 'Eliminar alarma',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                if (tratamientos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No hay tratamientos disponibles para crear una alarma')),
                  );
                  return;
                }
                final nuevaAlarma = await showDialog<Alarm>(
                  context: context,
                  builder: (context) => alarmDialog.AlarmDialog(tratamientos: tratamientos),
                );
                if (nuevaAlarma != null) {
                  await _createAlarma(nuevaAlarma);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Nueva Alarma'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}