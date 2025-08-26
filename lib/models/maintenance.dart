class Maintenance {
  final int? id;
  final String tipoServicio;
  final String fecha;
  final int kilometraje;
  final String? observaciones;

  Maintenance({
    this.id,
    required this.tipoServicio,
    required this.fecha,
    required this.kilometraje,
    this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo_servicio': tipoServicio,
      'fecha': fecha,
      'kilometraje': kilometraje,
      'observaciones': observaciones,
    };
  }

  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      id: map['id'],
      tipoServicio: map['tipo_servicio'],
      fecha: map['fecha'],
      kilometraje: map['kilometraje'],
      observaciones: map['observaciones'],
    );
  }
}