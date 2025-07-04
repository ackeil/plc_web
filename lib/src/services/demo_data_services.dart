import '../models/user_model.dart';
import '../models/equipment_model.dart';
import '../models/log_model.dart';

/// Serviço centralizado para gerenciar todos os dados de demonstração
/// 
/// Este serviço fornece dados mockados completos para permitir demonstrações
/// totalmente offline do sistema AFT-PLC-WEB. Simula um ambiente real com
/// múltiplas empresas, usuários, equipamentos e logs operacionais.
class DemoDataService {
  // Singleton para garantir consistência dos dados
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();
  
  // ===== DADOS DE EMPRESAS =====
  final Map<String, Map<String, dynamic>> demoCompanies = {
    'alfatronic-demo': {
      'id': 'alfatronic-demo',
      'name': 'Alfatronic Demo',
      'type': 'manufacturer',
      'cnpj': '00.000.000/0001-00',
      'address': 'Rua Demo, 123 - Porto Alegre/RS',
      'phone': '(51) 3333-3333',
      'responsibleName': 'Administrador Demo',
      'responsibleEmail': 'teste@ucs.br',
      'createdAt': DateTime(2024, 1, 1),
      'isActive': true,
    },
    'empresa-abc': {
      'id': 'empresa-abc',
      'name': 'Empresa ABC Equipamentos',
      'type': 'manufacturer',
      'cnpj': '11.111.111/0001-11',
      'address': 'Av. Industrial, 456 - Caxias do Sul/RS',
      'phone': '(54) 3222-2222',
      'responsibleName': 'João Silva',
      'responsibleEmail': 'gerente1@demo.com',
      'createdAt': DateTime(2024, 2, 1),
      'isActive': true,
    },
    'integrador-xyz': {
      'id': 'integrador-xyz',
      'name': 'Integrador XYZ',
      'type': 'integrator',
      'cnpj': '22.222.222/0001-22',
      'address': 'Rua Montagem, 789 - Bento Gonçalves/RS',
      'phone': '(54) 3111-1111',
      'responsibleName': 'Maria Santos',
      'responsibleEmail': 'gerente2@demo.com',
      'createdAt': DateTime(2024, 2, 15),
      'isActive': true,
    },
  };
  
  // ===== DADOS DE EQUIPAMENTOS =====
  List<Map<String, dynamic>> getDemoEquipments() {
    final now = DateTime.now();
    
    return [
      {
        'id': 'equip-001',
        'serialNumber': 'TRM6-MAX-2024001',
        'model': 'TRM6-MAX',
        'equipmentAFT': '45.700',
        'companyId': 'empresa-abc',
        'companyName': 'Empresa ABC Equipamentos',
        'manufacturingDate': DateTime(2024, 1, 15),
        'deliveryDate': DateTime(2024, 2, 1),
        'client': 'Vale S.A.',
        'clientContact': 'José Santos - (11) 98765-4321',
        'vehicleModel': 'Mercedes 1933',
        'vehiclePlate': 'ABC-1234',
        'maintenanceHours': 500,
        'lastMaintenance': DateTime(2024, 6, 1),
        'nextMaintenance': DateTime(2024, 12, 1),
        'authorizedOperators': ['demo-operator-001', 'demo-operator-002'],
        'location': {
          'lastUpdate': now.subtract(const Duration(hours: 2)),
          'latitude': -29.1685,
          'longitude': -51.1794,
          'address': 'Mina de Ferro - Caxias do Sul/RS'
        },
        'status': 'active',
        'alerts': 0,
        'operations': 1247,
        'totalHours': 3420.5,
        'imageUrl': null, // Em demo, podemos usar placeholder
        'notes': 'Equipamento em perfeito estado de funcionamento.',
        'createdAt': DateTime(2024, 2, 1),
        'lastSync': now.subtract(const Duration(minutes: 30)),
      },
      {
        'id': 'equip-002',
        'serialNumber': 'TRM6-MAX-2024002',
        'model': 'TRM6-MAX',
        'equipmentAFT': '85.000',
        'companyId': 'empresa-abc',
        'companyName': 'Empresa ABC Equipamentos',
        'manufacturingDate': DateTime(2024, 1, 20),
        'deliveryDate': DateTime(2024, 2, 5),
        'client': 'Vale S.A.',
        'clientContact': 'Maria Silva - (11) 98765-4322',
        'vehicleModel': 'Volvo FH 540',
        'vehiclePlate': 'XYZ-5678',
        'maintenanceHours': 500,
        'lastMaintenance': DateTime(2024, 5, 15),
        'nextMaintenance': DateTime(2024, 11, 15),
        'authorizedOperators': ['demo-operator-001', 'demo-operator-002'],
        'location': {
          'lastUpdate': now.subtract(const Duration(hours: 5)),
          'latitude': -29.2254,
          'longitude': -51.3467,
          'address': 'Centro de Distribuição - Farroupilha/RS'
        },
        'status': 'maintenance',
        'alerts': 2, // Mostra equipamento com alertas
        'operations': 980,
        'totalHours': 2850.3,
        'imageUrl': null,
        'notes': 'Manutenção preventiva em andamento. Previsão de conclusão: 2 dias.',
        'createdAt': DateTime(2024, 2, 5),
        'lastSync': now.subtract(const Duration(hours: 5)),
      },
      {
        'id': 'equip-003',
        'serialNumber': 'TRM6-MAX-2024003',
        'model': 'TRM6-MAX',
        'equipmentAFT': '45.700',
        'companyId': 'empresa-abc',
        'companyName': 'Empresa ABC Equipamentos',
        'manufacturingDate': DateTime(2024, 2, 1),
        'deliveryDate': DateTime(2024, 2, 20),
        'client': 'Excel Construções',
        'clientContact': 'Pedro Costa - (54) 99876-5432',
        'vehicleModel': 'Scania P360',
        'vehiclePlate': 'DEF-9012',
        'maintenanceHours': 500,
        'lastMaintenance': DateTime(2024, 7, 1),
        'nextMaintenance': DateTime(2025, 1, 1),
        'authorizedOperators': ['demo-operator-001'],
        'location': {
          'lastUpdate': now.subtract(const Duration(minutes: 45)),
          'latitude': -29.1234,
          'longitude': -51.2345,
          'address': 'Obra Residencial Vida Nova - Caxias do Sul/RS'
        },
        'status': 'active',
        'alerts': 0,
        'operations': 567,
        'totalHours': 1234.7,
        'imageUrl': null,
        'notes': 'Operando normalmente em obra residencial.',
        'createdAt': DateTime(2024, 2, 20),
        'lastSync': now.subtract(const Duration(minutes: 45)),
      },
      {
        'id': 'equip-004',
        'serialNumber': 'TRM6-MAX-2024004',
        'model': 'TRM6-MAX',
        'equipmentAFT': '22.000',
        'companyId': 'empresa-abc',
        'companyName': 'Empresa ABC Equipamentos',
        'manufacturingDate': DateTime(2024, 3, 1),
        'deliveryDate': DateTime(2024, 3, 15),
        'client': 'Mercúrio Logística',
        'clientContact': 'Ana Paula - (51) 98888-7777',
        'vehicleModel': 'Mercedes 2426',
        'vehiclePlate': 'GHI-3456',
        'maintenanceHours': 500,
        'lastMaintenance': DateTime(2024, 8, 1),
        'nextMaintenance': DateTime(2025, 2, 1),
        'authorizedOperators': ['demo-operator-002'],
        'location': {
          'lastUpdate': now.subtract(const Duration(days: 1)),
          'latitude': -30.0346,
          'longitude': -51.2177,
          'address': 'Porto de Porto Alegre - Porto Alegre/RS'
        },
        'status': 'inactive',
        'alerts': 1,
        'operations': 234,
        'totalHours': 890.2,
        'imageUrl': null,
        'notes': 'Equipamento parado aguardando peças de reposição.',
        'createdAt': DateTime(2024, 3, 15),
        'lastSync': now.subtract(const Duration(days: 1)),
      },
      {
        'id': 'equip-005',
        'serialNumber': 'TRM6-MAX-2024005',
        'model': 'TRM6-MAX',
        'equipmentAFT': '52.000',
        'companyId': 'integrador-xyz',
        'companyName': 'Integrador XYZ',
        'manufacturingDate': DateTime(2024, 3, 10),
        'deliveryDate': DateTime(2024, 3, 25),
        'client': 'Grillo Transportes',
        'clientContact': 'Roberto Costa - (54) 99999-8888',
        'vehicleModel': 'Iveco Tector',
        'vehiclePlate': 'JKL-7890',
        'maintenanceHours': 500,
        'lastMaintenance': DateTime(2024, 9, 1),
        'nextMaintenance': DateTime(2025, 3, 1),
        'authorizedOperators': ['demo-operator-003'],
        'location': {
          'lastUpdate': now.subtract(const Duration(days: 7)),
          'latitude': -29.0906,
          'longitude': -51.1851,
          'address': 'Última localização: BR-116 - Nova Petrópolis/RS'
        },
        'status': 'inactive',
        'alerts': 0,
        'operations': 123,
        'totalHours': 456.8,
        'imageUrl': null,
        'notes': 'Operador desativado. Equipamento sem comunicação há 7 dias.',
        'createdAt': DateTime(2024, 3, 25),
        'lastSync': now.subtract(const Duration(days: 7)),
      },
    ];
  }
  
  // ===== DADOS DE LOGS OPERACIONAIS =====
  List<Map<String, dynamic>> getEquipmentLogs(String equipmentId) {
    final now = DateTime.now();
    final logs = <Map<String, dynamic>>[];
    
    // Gera logs diferentes para cada equipamento
    if (equipmentId == 'equip-001') {
      logs.addAll([
        {
          'id': 'log-001-001',
          'equipmentId': equipmentId,
          'operatorId': 'demo-operator-001',
          'operatorName': 'Carlos Oliveira',
          'timestamp': now.subtract(const Duration(hours: 2)),
          'type': 'operation_start',
          'description': 'Início de operação',
          'location': {
            'latitude': -29.1685,
            'longitude': -51.1794,
            'address': 'Mina de Ferro - Caxias do Sul/RS'
          },
          'parameters': {
            'engine_hours': 3418.5,
            'fuel_level': 85,
            'hydraulic_pressure': 220,
            'oil_temperature': 75,
          },
        },
        {
          'id': 'log-001-002',
          'equipmentId': equipmentId,
          'operatorId': 'demo-operator-001',
          'operatorName': 'Carlos Oliveira',
          'timestamp': now.subtract(const Duration(hours: 1, minutes: 30)),
          'type': 'alert',
          'severity': 'warning',
          'description': 'Pressão hidráulica acima do normal',
          'location': {
            'latitude': -29.1685,
            'longitude': -51.1794,
            'address': 'Mina de Ferro - Caxias do Sul/RS'
          },
          'parameters': {
            'hydraulic_pressure': 280,
            'max_pressure': 250,
          },
        },
        {
          'id': 'log-001-003',
          'equipmentId': equipmentId,
          'operatorId': 'demo-operator-001',
          'operatorName': 'Carlos Oliveira',
          'timestamp': now.subtract(const Duration(minutes: 30)),
          'type': 'operation_end',
          'description': 'Fim de operação',
          'location': {
            'latitude': -29.1685,
            'longitude': -51.1794,
            'address': 'Mina de Ferro - Caxias do Sul/RS'
          },
          'parameters': {
            'engine_hours': 3420.5,
            'total_operation_time': '2h',
            'material_moved': '150 ton',
          },
        },
      ]);
    } else if (equipmentId == 'equip-002') {
      logs.addAll([
        {
          'id': 'log-002-001',
          'equipmentId': equipmentId,
          'operatorId': 'demo-operator-002',
          'operatorName': 'Ana Paula',
          'timestamp': now.subtract(const Duration(days: 1)),
          'type': 'alert',
          'severity': 'critical',
          'description': 'Temperatura do motor crítica',
          'location': {
            'latitude': -29.2254,
            'longitude': -51.3467,
            'address': 'Centro de Distribuição - Farroupilha/RS'
          },
          'parameters': {
            'engine_temperature': 110,
            'max_temperature': 95,
          },
        },
        {
          'id': 'log-002-002',
          'equipmentId': equipmentId,
          'operatorId': 'demo-operator-002',
          'operatorName': 'Ana Paula',
          'timestamp': now.subtract(const Duration(hours: 23)),
          'type': 'maintenance_request',
          'description': 'Solicitação de manutenção preventiva',
          'location': {
            'latitude': -29.2254,
            'longitude': -51.3467,
            'address': 'Centro de Distribuição - Farroupilha/RS'
          },
          'parameters': {
            'reason': 'Superaquecimento recorrente',
            'priority': 'high',
          },
        },
      ]);
    }
    
    // Adiciona logs genéricos para todos os equipamentos
    logs.add({
      'id': 'log-${equipmentId}-sync',
      'equipmentId': equipmentId,
      'operatorId': 'system',
      'operatorName': 'Sistema',
      'timestamp': now.subtract(const Duration(minutes: 5)),
      'type': 'sync',
      'description': 'Sincronização de dados realizada',
      'parameters': {
        'data_points': 145,
        'sync_duration': '2.3s',
      },
    });
    
    return logs;
  }
  
  // ===== DADOS DE NOTIFICAÇÕES =====
  List<Map<String, dynamic>> getDemoNotifications(String userId) {
    final now = DateTime.now();
    final notifications = <Map<String, dynamic>>[];
    
    // Notificações para o admin demo
    if (userId == 'demo-admin-001') {
      notifications.addAll([
        {
          'id': 'notif-001',
          'userId': userId,
          'type': 'system',
          'title': 'Bem-vindo ao Modo Demonstração',
          'message': 'Você está usando o modo demonstração do AFT-PLC-WEB. '
                     'Todos os dados são simulados e as alterações não são persistidas.',
          'timestamp': now.subtract(const Duration(minutes: 1)),
          'read': false,
          'priority': 'info',
        },
        {
          'id': 'notif-002',
          'userId': userId,
          'type': 'user_created',
          'title': 'Novo Gerente Cadastrado',
          'message': 'João Silva foi cadastrado como gerente da Empresa ABC Equipamentos.',
          'timestamp': now.subtract(const Duration(days: 30)),
          'read': true,
          'priority': 'normal',
        },
      ]);
    }
    
    // Notificações para gerentes
    if (userId == 'demo-manager-001') {
      notifications.addAll([
        {
          'id': 'notif-003',
          'userId': userId,
          'type': 'equipment_alert',
          'title': 'Alerta Crítico - TRM6-MAX-2024002',
          'message': 'Temperatura do motor acima do limite. Manutenção necessária.',
          'timestamp': now.subtract(const Duration(days: 1)),
          'read': false,
          'priority': 'critical',
          'relatedId': 'equip-002',
        },
        {
          'id': 'notif-004',
          'userId': userId,
          'type': 'operator_login',
          'title': 'Operador Conectado',
          'message': 'Carlos Oliveira iniciou operação no equipamento TRM6-MAX-2024001.',
          'timestamp': now.subtract(const Duration(hours: 2)),
          'read': true,
          'priority': 'normal',
          'relatedId': 'equip-001',
        },
      ]);
    }
    
    return notifications;
  }
  
  // ===== MÉTODOS AUXILIARES =====
  
  /// Retorna estatísticas gerais para o dashboard
  Map<String, dynamic> getDashboardStats({String? companyId}) {
    final equipments = getDemoEquipments();
    final filteredEquipments = companyId != null
        ? equipments.where((e) => e['companyId'] == companyId).toList()
        : equipments;
    
    return {
      'totalEquipments': filteredEquipments.length,
      'activeEquipments': filteredEquipments.where((e) => e['status'] == 'active').length,
      'maintenanceEquipments': filteredEquipments.where((e) => e['status'] == 'maintenance').length,
      'inactiveEquipments': filteredEquipments.where((e) => e['status'] == 'inactive').length,
      'totalAlerts': filteredEquipments.fold<int>(0, (sum, e) => sum + (e['alerts'] as int)),
      'totalOperations': filteredEquipments.fold<int>(0, (sum, e) => sum + (e['operations'] as int)),
      'totalHours': filteredEquipments.fold<double>(0, (sum, e) => sum + (e['totalHours'] as double)),
      'lastUpdate': DateTime.now(),
    };
  }
  
  /// Simula um delay de rede para tornar a demo mais realista
  Future<void> simulateNetworkDelay({int milliseconds = 500}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
}