import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../models/treatment.dart';

class AlarmDialog extends StatefulWidget {
  final List<Treatment> tratamientos;
  final Alarm? alarma;

  const AlarmDialog({super.key, required this.tratamientos, this.alarma});

  @override
  _AlarmDialogState createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMedicamentoId;
  String _hora = '08:00';
  List<String> _dias = [];
  final List<String> _allDias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  @override
  void initState() {
    super.initState();
    if (widget.alarma != null) {
      _selectedMedicamentoId = widget.alarma!.medicamentoId;
      _hora = widget.alarma!.hora;
      _dias = widget.alarma!.dias;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_hora.split(':')[0]),
        minute: int.parse(_hora.split(':')[1]),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Aseguramos que la hora siempre tenga el formato HH:MM
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _hora = '$hour:$minute';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.alarma == null ? 'Nueva Alarma' : 'Editar Alarma',
        style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMedicamentoId,
                hint: const Text('Selecciona un medicamento'),
                items: widget.tratamientos.map((treatment) {
                  return DropdownMenuItem<String>(
                    value: treatment.medicamentoId,
                    child: Text(treatment.nombreMedicamento),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMedicamentoId = value;
                  });
                },
                validator: (value) => value == null ? 'Selecciona un medicamento' : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hora',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _hora,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.access_time, color: Colors.blue[600]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Días de la semana',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allDias.map((dia) {
                  return FilterChip(
                    label: Text(dia),
                    selected: _dias.contains(dia),
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue.shade600,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _dias.add(dia);
                        } else {
                          _dias.remove(dia);
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                  );
                }).toList(),
              ),
              if (_dias.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selecciona al menos un día',
                    style: TextStyle(color: Colors.red.shade500, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedMedicamentoId != null && _dias.isNotEmpty) {
              final tratamiento = widget.tratamientos.firstWhere(
                (t) => t.medicamentoId == _selectedMedicamentoId,
                orElse: () => Treatment(medicamentoId: '', nombreMedicamento: ''),
              );

              final nuevaAlarma = Alarm(
                id: widget.alarma?.id ?? '',
                pacienteCorreo: '',
                medicamentoId: tratamiento.medicamentoId,
                nombreMedicamento: tratamiento.nombreMedicamento,
                dosis: '',
                frecuencia: '',
                hora: _hora,
                dias: _dias,
                tratamientoId: '',
              );
              Navigator.pop(context, nuevaAlarma);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(widget.alarma == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }
}