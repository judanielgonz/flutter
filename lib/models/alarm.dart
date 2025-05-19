class Alarm {
  final String id; // Nuevo campo para almacenar el ID de la alarma
  final String pacienteCorreo;
  final String medicamentoId;
  final String nombreMedicamento;
  final String dosis;
  final String frecuencia;
  final String hora;
  final List<String> dias;
  final String tratamientoId;
  final bool activo;

  Alarm({
    this.id = '',
    required this.pacienteCorreo,
    required this.medicamentoId,
    required this.nombreMedicamento,
    required this.dosis,
    required this.frecuencia,
    required this.hora,
    required this.dias,
    required this.tratamientoId,
    this.activo = true,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['_id']?.toString() ?? '',
      pacienteCorreo: json['pacienteCorreo'] ?? '',
      medicamentoId: json['medicamentoId'] ?? '',
      nombreMedicamento: json['nombreMedicamento'] ?? '',
      dosis: json['dosis'] ?? '',
      frecuencia: json['frecuencia'] ?? '',
      hora: json['hora'] ?? '',
      dias: List<String>.from(json['dias'] ?? []),
      tratamientoId: json['tratamientoId'] ?? '',
      activo: json['activo'] ?? true,
    );
  }
}