// lib/src/screens/equipment/equipment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/equipment_model.dart';
import '../../models/log_model.dart';
import '../../services/auth_service.dart';
import '../../services/demo_data_services.dart';
import '../../widgets/loading_widget.dart';
import '../../models/log_model.dart';

/// Tela de detalhes do equipamento
/// 
/// Exibe todas as informações do equipamento em abas organizadas:
/// - Informações gerais
/// - Logs de operação
/// - Manutenção
/// - Localização
class EquipmentDetailScreen extends StatefulWidget {
  final String equipmentId;
  
  const EquipmentDetailScreen({
    Key? key,
    required this.equipmentId,
  }) : super(key: key);

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen>
    with TickerProviderStateMixin {
  // Serviços
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();
  
  // Controllers
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  // Dados
  UserModel? _currentUser;
  Map<String, dynamic>? _equipment;
  List<Map<String, dynamic>> _logs = [];
  
  // Estados
  bool _isLoading = true;
  bool _isBluetoothConnecting = false;
  
  // Animações
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Configura tabs
    _tabController = TabController(length: 4, vsync: this);
    
    // Configura animações
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    // Carrega dados
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  /// Carrega dados do equipamento
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Simula delay de rede
      await _demoDataService.simulateNetworkDelay();
      
      // Busca usuário atual
      final user = await _authService.getCurrentUser();
      
      // Busca equipamento
      final equipments = _demoDataService.getDemoEquipments();
      final equipment = equipments.firstWhere(
        (e) => e['id'] == widget.equipmentId,
        orElse: () => <String, dynamic>{},
      );
      
      if (equipment.isEmpty) {
        throw Exception('Equipamento não encontrado');
      }
      
      // Busca logs do equipamento
      final logs = _demoDataService.getEquipmentLogs(widget.equipmentId);
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _equipment = equipment;
          _logs = logs;
          _isLoading = false;
        });
        
        _fadeController.forward();
      }
    } catch (e) {
      print('Erro ao carregar equipamento: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erro ao carregar dados do equipamento');
      }
    }
  }
  
  /// Conecta via Bluetooth
  Future<void> _connectBluetooth() async {
    setState(() => _isBluetoothConnecting = true);
    
    // Simula tentativa de conexão
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isBluetoothConnecting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidade Bluetooth ainda não implementada'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
  
  /// Mostra diálogo de exclusão
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Equipamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja excluir este equipamento?'),
            const SizedBox(height: 8),
            Text(
              _equipment!['serialNumber'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita!',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEquipment();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
  
  /// Exclui equipamento
  Future<void> _deleteEquipment() async {
    // TODO: Implementar exclusão real
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Equipamento excluído com sucesso'),
        backgroundColor: AppColors.success,
      ),
    );
  }
  
  /// Mostra mensagem de erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
  
  /// Constrói o header com informações principais
  Widget _buildHeader() {
    if (_equipment == null) return const SizedBox.shrink();
    
    final status = _equipment!['status'] as String?;
    final statusColor = AppColors.getEquipmentStatusColor(status ?? 'inactive');
    
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Informações principais
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Número de série e status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _equipment!['serialNumber'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _equipment!['model'] ?? 'TRM6-MAX',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Estatísticas rápidas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                        'Horas Totais',
                        '${_equipment!['totalHours']?.toStringAsFixed(1) ?? '0'}',
                        Icons.timer,
                      ),
                      _buildQuickStat(
                        'Operações',
                        '${_equipment!['operations'] ?? 0}',
                        Icons.functions,
                      ),
                      _buildQuickStat(
                        'Alertas',
                        '${_equipment!['alerts'] ?? 0}',
                        Icons.warning,
                        valueColor: _equipment!['alerts'] > 0 
                            ? AppColors.warning 
                            : Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Informações'),
                Tab(text: 'Logs'),
                Tab(text: 'Manutenção'),
                Tab(text: 'Localização'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói estatística rápida
  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
  
  /// Constrói aba de informações
  Widget _buildInfoTab() {
    if (_equipment == null) return const SizedBox.shrink();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card de informações básicas
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informações do Equipamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Número AFT', _equipment!['equipmentAFT'] ?? '-'),
                _buildInfoRow('Fabricante', _equipment!['companyName'] ?? '-'),
                _buildInfoRow(
                  'Data de Fabricação',
                  _formatDate(_equipment!['manufacturingDate']),
                ),
                _buildInfoRow(
                  'Data de Entrega',
                  _formatDate(_equipment!['deliveryDate']),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Card de informações do cliente
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informações do Cliente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Cliente', _equipment!['client'] ?? '-'),
                _buildInfoRow('Contato', _equipment!['clientContact'] ?? '-'),
                _buildInfoRow('Modelo do Veículo', _equipment!['vehicleModel'] ?? '-'),
                _buildInfoRow('Placa', _equipment!['vehiclePlate'] ?? '-'),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Card de observações
        if (_equipment!['notes'] != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Observações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _equipment!['notes'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Operadores autorizados
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Operadores Autorizados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_currentUser?.role != UserRole.operator)
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: AppColors.primary,
                        onPressed: () {
                          // TODO: Implementar adição de operador
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Adicionar operador - não implementado'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ...(_equipment!['authorizedOperators'] as List<String>? ?? [])
                    .map((operatorId) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text('Operador ID: $operatorId'),
                          subtitle: const Text('Autorizado'),
                          trailing: _currentUser?.role != UserRole.operator
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppColors.error,
                                  onPressed: () {
                                    // TODO: Implementar remoção
                                  },
                                )
                              : null,
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Constrói aba de logs
  Widget _buildLogsTab() {
    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum log registrado',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return _buildLogItem(log);
      },
    );
  }
  
  /// Constrói item de log
  Widget _buildLogItem(Map<String, dynamic> log) {
    final type = log['type'] as String?;
    final severity = log['severity'] as String?;
    final timestamp = log['timestamp'] is DateTime
    ? log['timestamp']
    : DateTime.parse(log['timestamp']);
    
    IconData icon;
    Color color;
    
    switch (type) {
      case 'operation_start':
        icon = Icons.play_circle;
        color = AppColors.success;
        break;
      case 'operation_end':
        icon = Icons.stop_circle;
        color = AppColors.info;
        break;
      case 'alert':
        icon = Icons.warning;
        color = severity == 'critical' ? AppColors.error : AppColors.warning;
        break;
      case 'maintenance':
      case 'maintenance_request':
        icon = Icons.build_circle;
        color = AppColors.warning;
        break;
      case 'sync':
        icon = Icons.sync;
        color = AppColors.info;
        break;
      default:
        icon = Icons.info;
        color = AppColors.textSecondary;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          log['description'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              log['operatorName'] ?? 'Sistema',
              style: const TextStyle(fontSize: 12),
            ),
            if (log['location'] != null)
              Text(
                log['location']['address'] ?? 'GPS disponível',
                style: const TextStyle(fontSize: 12),
              ),
            if (log['parameters'] != null)
              ...Map<String, dynamic>.from(log['parameters'])
                  .entries
                  .take(2)
                  .map((entry) => Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ))
                  .toList(),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(timestamp),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatDate(timestamp),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Mostrar detalhes do log
          _showLogDetails(log);
        },
      ),
    );
  }
  
  /// Mostra detalhes do log
  void _showLogDetails(Map<String, dynamic> log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Detalhes do Log',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailItem('Tipo', _getLogTypeDescription(log['type'])),
                    _buildDetailItem('Descrição', log['description'] ?? '-'),
                    _buildDetailItem('Operador', log['operatorName'] ?? 'Sistema'),
                    _buildDetailItem(
                      'Data/Hora',
                      '${_formatDate(log['timestamp'])} ${_formatTime(log['timestamp'])}',
                    ),
                    if (log['severity'] != null)
                      _buildDetailItem('Severidade', _getSeverityDescription(log['severity'])),
                    if (log['location'] != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Localização',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailItem('Endereço', log['location']['address'] ?? '-'),
                      _buildDetailItem(
                        'Coordenadas',
                        '${log['location']['latitude']}, ${log['location']['longitude']}',
                      ),
                    ],
                    if (log['parameters'] != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Parâmetros',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...Map<String, dynamic>.from(log['parameters'])
                          .entries
                          .map((entry) => _buildDetailItem(
                                entry.key,
                                entry.value.toString(),
                              ))
                          .toList(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói aba de manutenção
  Widget _buildMaintenanceTab() {
    final lastMaintenance = _equipment!['lastMaintenance'] as DateTime?;
    final nextMaintenance = _equipment!['nextMaintenance'] as DateTime?;
    final maintenanceHours = _equipment!['maintenanceHours'] ?? 500;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status de manutenção
        Card(
          color: nextMaintenance != null && DateTime.now().isAfter(nextMaintenance)
              ? AppColors.error.withOpacity(0.1)
              : AppColors.success.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  nextMaintenance != null && DateTime.now().isAfter(nextMaintenance)
                      ? Icons.warning
                      : Icons.check_circle,
                  size: 48,
                  color: nextMaintenance != null && DateTime.now().isAfter(nextMaintenance)
                      ? AppColors.error
                      : AppColors.success,
                ),
                const SizedBox(height: 8),
                Text(
                  nextMaintenance != null && DateTime.now().isAfter(nextMaintenance)
                      ? 'Manutenção Atrasada!'
                      : 'Manutenção em Dia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: nextMaintenance != null && DateTime.now().isAfter(nextMaintenance)
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Informações de manutenção
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Histórico de Manutenção',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Intervalo de Manutenção',
                  '$maintenanceHours horas',
                ),
                _buildInfoRow(
                  'Última Manutenção',
                  lastMaintenance != null
                      ? _formatDate(lastMaintenance)
                      : 'Não realizada',
                ),
                _buildInfoRow(
                  'Próxima Manutenção',
                  nextMaintenance != null
                      ? _formatDate(nextMaintenance)
                      : 'Não agendada',
                ),
                if (nextMaintenance != null)
                  _buildInfoRow(
                    'Dias Restantes',
                    '${nextMaintenance.difference(DateTime.now()).inDays} dias',
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Ações de manutenção
        if (_currentUser?.role != UserRole.operator) ...[
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar agendamento
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Agendar manutenção - não implementado'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text('Agendar Manutenção'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          
          const SizedBox(height: 8),
          
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementar registro
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registrar manutenção - não implementado'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            icon: const Icon(Icons.check),
            label: const Text('Registrar Manutenção Realizada'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ],
    );
  }
  
  /// Constrói aba de localização
  Widget _buildLocationTab() {
    final location = _equipment!['location'] as Map<String, dynamic>?;
    
    if (location == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Localização não disponível',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Conecte o equipamento para obter a localização',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Mapa placeholder
        Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Mapa não implementado',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.surface,
                  onPressed: () {
                    // TODO: Abrir em mapa externo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Abrir no mapa - não implementado'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.open_in_new,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Informações de localização
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Última Localização',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Endereço',
                  location['address'] ?? 'Não disponível',
                ),
                _buildInfoRow(
                  'Latitude',
                  location['latitude']?.toString() ?? '-',
                ),
                _buildInfoRow(
                  'Longitude',
                  location['longitude']?.toString() ?? '-',
                ),
                _buildInfoRow(
                  'Última Atualização',
                  _formatDateTime(location['lastUpdate'] as DateTime?),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Histórico de localização
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Histórico de Rotas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Ver histórico completo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Histórico de rotas - não implementado'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                      },
                      child: const Text('Ver Tudo'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Funcionalidade em desenvolvimento',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Constrói linha de informação
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói item de detalhe
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  // Funções auxiliares
  String _getStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'maintenance':
        return 'Em Manutenção';
      case 'inactive':
        return 'Inativo';
      default:
        return 'Desconhecido';
    }
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return '${_formatDate(date)} ${_formatTime(date)}';
  }
  
  String _getLogTypeDescription(String? type) {
    switch (type) {
      case 'operation_start':
        return 'Início de Operação';
      case 'operation_end':
        return 'Fim de Operação';
      case 'alert':
        return 'Alerta';
      case 'maintenance':
        return 'Manutenção';
      case 'maintenance_request':
        return 'Solicitação de Manutenção';
      case 'sync':
        return 'Sincronização';
      case 'error':
        return 'Erro';
      default:
        return 'Informação';
    }
  }
  
  String _getSeverityDescription(String? severity) {
    switch (severity) {
      case 'critical':
        return 'Crítico';
      case 'warning':
        return 'Aviso';
      case 'info':
        return 'Informativo';
      default:
        return '-';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: LoadingWidget(
            message: 'Carregando equipamento...',
          ),
        ),
      );
    }
    
    if (_equipment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Equipamento'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Equipamento não encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
              ),
              actions: [
                // Botão de Bluetooth
                if (_currentUser?.role == UserRole.operator)
                  _isBluetoothConnecting
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.bluetooth),
                          onPressed: _connectBluetooth,
                        ),
                
                // Menu de opções
                if (_currentUser?.role != UserRole.operator)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: AppColors.error),
                          title: Text(
                            'Excluir',
                            style: TextStyle(color: AppColors.error),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          Navigator.pushNamed(
                            context,
                            '/equipment/form',
                            arguments: widget.equipmentId,
                          );
                          break;
                        case 'delete':
                          _showDeleteDialog();
                          break;
                      }
                    },
                  ),
              ],
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(),
              _buildLogsTab(),
              _buildMaintenanceTab(),
              _buildLocationTab(),
            ],
          ),
        ),
      ),
      
      // FAB para conectar Bluetooth (apenas operadores)
      floatingActionButton: _currentUser?.role == UserRole.operator
          ? FloatingActionButton.extended(
              onPressed: _isBluetoothConnecting ? null : _connectBluetooth,
              icon: _isBluetoothConnecting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.bluetooth),
              label: Text(_isBluetoothConnecting ? 'Conectando...' : 'Conectar'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}