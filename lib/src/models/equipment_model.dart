// lib/models/equipment_model.dart

/// Status possíveis de um equipamento
enum EquipmentStatus {
  active,
  maintenance,
  inactive,
  alert
}

/// Modelo de equipamento
class EquipmentModel {
  final String id;
  final String serialNumber;
  final String model;
  final String equipmentAFT;
  final String companyId;
  final String companyName;
  final DateTime manufacturingDate;
  final DateTime? deliveryDate;
  final String? client;
  final String? clientContact;
  final String? vehicleModel;
  final String? vehiclePlate;
  final int maintenanceHours;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;
  final List<String> authorizedOperators;
  final LocationData? location;
  final EquipmentStatus status;
  final int alerts;
  final int operations;
  final double totalHours;
  final String? imageUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime? lastSync;
  
  EquipmentModel({
    required this.id,
    required this.serialNumber,
    required this.model,
    required this.equipmentAFT,
    required this.companyId,
    required this.companyName,
    required this.manufacturingDate,
    this.deliveryDate,
    this.client,
    this.clientContact,
    this.vehicleModel,
    this.vehiclePlate,
    this.maintenanceHours = 500,
    this.lastMaintenance,
    this.nextMaintenance,
    required this.authorizedOperators,
    this.location,
    this.status = EquipmentStatus.active,
    this.alerts = 0,
    this.operations = 0,
    this.totalHours = 0.0,
    this.imageUrl,
    this.notes,
    required this.createdAt,
    this.lastSync,
  });
  
  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serialNumber': serialNumber,
      'model': model,
      'equipmentAFT': equipmentAFT,
      'companyId': companyId,
      'companyName': companyName,
      'manufacturingDate': manufacturingDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'client': client,
      'clientContact': clientContact,
      'vehicleModel': vehicleModel,
      'vehiclePlate': vehiclePlate,
      'maintenanceHours': maintenanceHours,
      'lastMaintenance': lastMaintenance?.toIso8601String(),
      'nextMaintenance': nextMaintenance?.toIso8601String(),
      'authorizedOperators': authorizedOperators,
      'location': location?.toMap(),
      'status': status.toString().split('.').last,
      'alerts': alerts,
      'operations': operations,
      'totalHours': totalHours,
      'imageUrl': imageUrl,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'lastSync': lastSync?.toIso8601String(),
    };
  }
  
  /// Cria a partir de um Map
  factory EquipmentModel.fromMap(Map<String, dynamic> map) {
    return EquipmentModel(
      id: map['id'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
      model: map['model'] ?? 'TRM6-MAX',
      equipmentAFT: map['equipmentAFT'] ?? '',
      companyId: map['companyId'] ?? '',
      companyName: map['companyName'] ?? '',
      manufacturingDate: DateTime.parse(map['manufacturingDate']),
      deliveryDate: map['deliveryDate'] != null 
          ? DateTime.parse(map['deliveryDate']) 
          : null,
      client: map['client'],
      clientContact: map['clientContact'],
      vehicleModel: map['vehicleModel'],
      vehiclePlate: map['vehiclePlate'],
      maintenanceHours: map['maintenanceHours'] ?? 500,
      lastMaintenance: map['lastMaintenance'] != null 
          ? DateTime.parse(map['lastMaintenance']) 
          : null,
      nextMaintenance: map['nextMaintenance'] != null 
          ? DateTime.parse(map['nextMaintenance']) 
          : null,
      authorizedOperators: map['authorizedOperators'] != null 
          ? List<String>.from(map['authorizedOperators']) 
          : [],
      location: map['location'] != null 
          ? LocationData.fromMap(map['location']) 
          : null,
      status: _parseEquipmentStatus(map['status']),
      alerts: map['alerts'] ?? 0,
      operations: map['operations'] ?? 0,
      totalHours: (map['totalHours'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      lastSync: map['lastSync'] != null 
          ? DateTime.parse(map['lastSync']) 
          : null,
    );
  }
  
  /// Converte string em EquipmentStatus
  static EquipmentStatus _parseEquipmentStatus(String? status) {
    switch (status) {
      case 'active':
        return EquipmentStatus.active;
      case 'maintenance':
        return EquipmentStatus.maintenance;
      case 'inactive':
        return EquipmentStatus.inactive;
      case 'alert':
        return EquipmentStatus.alert;
      default:
        return EquipmentStatus.inactive;
    }
  }
  
  /// Verifica se precisa de manutenção
  bool get needsMaintenance {
    if (nextMaintenance == null) return false;
    return DateTime.now().isAfter(nextMaintenance!);
  }
  
  /// Verifica se está offline
  bool get isOffline {
    if (lastSync == null) return true;
    final daysSinceSync = DateTime.now().difference(lastSync!).inDays;
    return daysSinceSync > 1;
  }
  
  /// Status em português
  String get statusDescription {
    switch (status) {
      case EquipmentStatus.active:
        return 'Ativo';
      case EquipmentStatus.maintenance:
        return 'Em Manutenção';
      case EquipmentStatus.inactive:
        return 'Inativo';
      case EquipmentStatus.alert:
        return 'Com Alertas';
    }
  }
}

/// Dados de localização
class LocationData {
  final DateTime lastUpdate;
  final double latitude;
  final double longitude;
  final String? address;
  
  LocationData({
    required this.lastUpdate,
    required this.latitude,
    required this.longitude,
    this.address,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'lastUpdate': lastUpdate.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
  
  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      lastUpdate: DateTime.parse(map['lastUpdate']),
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'],
    );
  }
}