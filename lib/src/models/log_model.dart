// lib/models/log_model.dart

/// Tipos de log
enum LogType {
  operationStart,
  operationEnd,
  alert,
  maintenance,
  sync,
  error,
  info,
  maintenanceRequest
}

/// Severidade dos alertas
enum AlertSeverity {
  info,
  warning,
  critical
}

/// Modelo de log operacional
class LogModel {
  final String id;
  final String equipmentId;
  final String operatorId;
  final String operatorName;
  final DateTime timestamp;
  final LogType type;
  final String description;
  final AlertSeverity? severity;
  final Map<String, dynamic>? parameters;
  final LocationData? location;
  
  LogModel({
    required this.id,
    required this.equipmentId,
    required this.operatorId,
    required this.operatorName,
    required this.timestamp,
    required this.type,
    required this.description,
    this.severity,
    this.parameters,
    this.location,
  });
  
  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'description': description,
      'severity': severity?.toString().split('.').last,
      'parameters': parameters,
      'location': location?.toMap(),
    };
  }
  
  /// Cria a partir de um Map
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['id'] ?? '',
      equipmentId: map['equipmentId'] ?? '',
      operatorId: map['operatorId'] ?? '',
      operatorName: map['operatorName'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      type: _parseLogType(map['type']),
      description: map['description'] ?? '',
      severity: map['severity'] != null ? _parseAlertSeverity(map['severity']) : null,
      parameters: map['parameters'],
      location: map['location'] != null 
          ? LocationData.fromMap(map['location']) 
          : null,
    );
  }
  
  /// Converte string em LogType
  static LogType _parseLogType(String? type) {
    switch (type) {
      case 'operationStart':
        return LogType.operationStart;
      case 'operationEnd':
        return LogType.operationEnd;
      case 'alert':
        return LogType.alert;
      case 'maintenance':
        return LogType.maintenance;
      case 'sync':
        return LogType.sync;
      case 'error':
        return LogType.error;
      case 'maintenanceRequest':
        return LogType.maintenanceRequest;
      case 'info':
      default:
        return LogType.info;
    }
  }
  
  /// Converte string em AlertSeverity
  static AlertSeverity _parseAlertSeverity(String? severity) {
    switch (severity) {
      case 'warning':
        return AlertSeverity.warning;
      case 'critical':
        return AlertSeverity.critical;
      case 'info':
      default:
        return AlertSeverity.info;
    }
  }
  
  /// Tipo em português
  String get typeDescription {
    switch (type) {
      case LogType.operationStart:
        return 'Início de Operação';
      case LogType.operationEnd:
        return 'Fim de Operação';
      case LogType.alert:
        return 'Alerta';
      case LogType.maintenance:
        return 'Manutenção';
      case LogType.sync:
        return 'Sincronização';
      case LogType.error:
        return 'Erro';
      case LogType.info:
        return 'Informação';
      case LogType.maintenanceRequest:
        return 'Solicitação de Manutenção';
    }
  }
  
  /// Severidade em português
  String get severityDescription {
    switch (severity) {
      case AlertSeverity.info:
        return 'Informativo';
      case AlertSeverity.warning:
        return 'Aviso';
      case AlertSeverity.critical:
        return 'Crítico';
      case null:
        return '';
    }
  }
}

/// Dados de localização
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  
  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
  
  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'],
    );
  }
}