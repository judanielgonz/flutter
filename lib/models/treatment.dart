class Treatment {
  final String medicamentoId;
  final String nombreMedicamento;

  Treatment({
    required this.medicamentoId,
    required this.nombreMedicamento,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      medicamentoId: json['_id']?.toString() ?? '',
      nombreMedicamento: json['nombre']?.toString() ?? '',
    );
  }
}