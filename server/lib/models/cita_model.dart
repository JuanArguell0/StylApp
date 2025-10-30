// lib/models/cita_model.dart
class CitaModel {
  final int? id;
  final int clienteId;
  final int barberoId;
  final int servicioId;
  final DateTime fecha;
  final String hora; // formato HH:mm
  final String estado;

  CitaModel({
    this.id,
    required this.clienteId,
    required this.barberoId,
    required this.servicioId,
    required this.fecha,
    required this.hora,
    this.estado = 'pendiente',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cliente_id': clienteId,
        'barbero_id': barberoId,
        'servicio_id': servicioId,
        'fecha': fecha.toIso8601String(),
        'hora': hora,
        'estado': estado,
      };
}
