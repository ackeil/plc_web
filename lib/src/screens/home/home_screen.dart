// lib/src/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/equipment_model.dart';
import '../../services/auth_service.dart';
import '../../services/demo_data_services.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/equipment_card.dart';
import '../equipment/equipment_detail_screen.dart';

/// Tela principal do sistema AFT-PLC-WEB
/// 
/// Exibe dashboard com estatísticas e lista de equipamentos
/// com navegação para todas as funcionalidades do sistema
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Serviços
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();
  
  // Dados
  UserModel? _currentUser;
  List<Map<String, dynamic>> _equipments = [];
  Map<String, dynamic> _stats = {};
  
  // Controle de UI
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  
  // Animação
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Configura animações
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    // Carrega dados
    _loadData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  /// Carrega todos os dados necessários
  Future<void> _loadData() async {
    try {
      // Simula delay de rede
      await _demoDataService.simulateNetworkDelay();
      
      // Busca usuário atual
      final user = await _authService.getCurrentUser();
      
      // Busca equipamentos
      final equipments = _demoDataService.getDemoEquipments();
      
      // Busca estatísticas
      final stats = _demoDataService.getDashboardStats(
        companyId: user?.companyId,
      );
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _equipments = equipments;
          _stats = stats;
          _isLoading = false;
        });
        
        // Inicia animação
        _animationController.forward();
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// Filtra equipamentos baseado no filtro selecionado
  List<Map<String, dynamic>> get _filteredEquipments {
    var filtered = _equipments;
    
    // Aplica filtro de status
    if (_selectedFilter != 'all') {
      filtered = filtered.where((e) => e['status'] == _selectedFilter).toList();
    }
    
    // Aplica busca por texto
    if (_searchController.text.isNotEmpty) {
      final search = _searchController.text.toLowerCase();
      filtered = filtered.where((e) {
        final serialNumber = (e['serialNumber'] ?? '').toLowerCase();
        final client = (e['client'] ?? '').toLowerCase();
        final model = (e['model'] ?? '').toLowerCase();
        
        return serialNumber.contains(search) ||
               client.contains(search) ||
               model.contains(search);
      }).toList();
    }
    
    return filtered;
  }
  
  /// Constrói card de estatística
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói o drawer de navegação
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header do drawer
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _currentUser?.name.substring(0, 2).toUpperCase() ?? 'US',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            accountName: Text(
              _currentUser?.name ?? 'Usuário',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_currentUser?.email ?? ''),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentUser?.roleDisplayName ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // Opções do menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  selected: true,
                  selectedTileColor: AppColors.primary.withOpacity(0.1),
                  onTap: () => Navigator.pop(context),
                ),
                
                const Divider(),
                
                // Seção Equipamentos
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'EQUIPAMENTOS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                
                ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('Lista de Equipamentos'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/equipment');
                  },
                ),
                
                if (_currentUser?.role != UserRole.operator)
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Cadastrar Equipamento'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/equipment/form');
                    },
                  ),
                
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: const Text('Conectar via Bluetooth'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implementar tela de conexão Bluetooth
                    _showFeatureNotImplemented('Conexão Bluetooth');
                  },
                ),
                
                const Divider(),
                
                // Seção Relatórios
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'ANÁLISES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Relatórios'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/reports');
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Exportar Dados'),
                  onTap: () {
                    Navigator.pop(context);
                    _showExportDialog();
                  },
                ),
                
                // Seção Administração (apenas para admin e gerente)
                if (_currentUser?.role != UserRole.operator) ...[
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'ADMINISTRAÇÃO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Usuários'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/users');
                    },
                  ),
                ],
                
                const Divider(),
                
                // Seção Sistema
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notificações'),
                  trailing: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeatureNotImplemented('Notificações');
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configurações'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Column(
              children: [
                if (_demoDataService == DemoDataService()) // Modo demo
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Modo Demonstração',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  'AFT-PLC-WEB v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Mostra diálogo de exportação
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Dados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel (.xlsx)'),
              subtitle: const Text('Formato compatível com Microsoft Excel'),
              onTap: () {
                Navigator.pop(context);
                _showFeatureNotImplemented('Exportar Excel');
              },
            ),
            ListTile(
              leading: const Icon(Icons.csv, color: Colors.blue),
              title: const Text('CSV (.csv)'),
              subtitle: const Text('Valores separados por vírgula'),
              onTap: () {
                Navigator.pop(context);
                _showFeatureNotImplemented('Exportar CSV');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
  
  /// Mostra mensagem de funcionalidade não implementada
  void _showFeatureNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature ainda não implementado'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: LoadingWidget(
            message: 'Carregando dashboard...',
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
        actions: [
          // Botão de notificações
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => _showFeatureNotImplemented('Notificações'),
          ),
          
          // Menu de perfil
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surface,
              child: Text(
                _currentUser?.name.substring(0, 2).toUpperCase() ?? 'US',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Meu Perfil'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Configurações'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: AppColors.error),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  _showFeatureNotImplemented('Perfil');
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/settings');
                  break;
                case 'logout':
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                  break;
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // Cards de estatísticas
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isTablet ? 1.5 : 1.3,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildStatCard(
                      title: 'Total de Equipamentos',
                      value: '${_stats['totalEquipments'] ?? 0}',
                      icon: Icons.inventory_2,
                      color: AppColors.info,
                      onTap: () => Navigator.pushNamed(context, '/equipment'),
                    ),
                    _buildStatCard(
                      title: 'Equipamentos Ativos',
                      value: '${_stats['activeEquipments'] ?? 0}',
                      icon: Icons.check_circle,
                      color: AppColors.success,
                      onTap: () {
                        setState(() => _selectedFilter = 'active');
                      },
                    ),
                    _buildStatCard(
                      title: 'Em Manutenção',
                      value: '${_stats['maintenanceEquipments'] ?? 0}',
                      icon: Icons.build,
                      color: AppColors.warning,
                      onTap: () {
                        setState(() => _selectedFilter = 'maintenance');
                      },
                    ),
                    _buildStatCard(
                      title: 'Alertas',
                      value: '${_stats['totalAlerts'] ?? 0}',
                      icon: Icons.warning,
                      color: AppColors.error,
                      onTap: () => _showFeatureNotImplemented('Alertas'),
                    ),
                  ]),
                ),
              ),
              
              // Título e filtros
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Equipamentos',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_currentUser?.role != UserRole.operator)
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: AppColors.primary,
                              onPressed: () {
                                Navigator.pushNamed(context, '/equipment/form');
                              },
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Barra de busca e filtros
                      Row(
                        children: [
                          // Campo de busca
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar por número de série, cliente...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Filtro de status
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFilter,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'all',
                                    child: Text('Todos'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'active',
                                    child: Text('Ativos'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'maintenance',
                                    child: Text('Manutenção'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'inactive',
                                    child: Text('Inativos'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFilter = value ?? 'all';
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Contador de resultados
                      Text(
                        '${_filteredEquipments.length} equipamento(s) encontrado(s)',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Lista de equipamentos
              if (_filteredEquipments.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Nenhum equipamento encontrado'
                              : 'Nenhum equipamento cadastrado',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_currentUser?.role != UserRole.operator) ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/equipment/form');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Cadastrar Equipamento'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final equipment = _filteredEquipments[index];
                        
                        return EquipmentListItem(
                          equipment: equipment,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/equipment/detail',
                              arguments: equipment['id'],
                            );
                          },
                        );
                      },
                      childCount: _filteredEquipments.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      
      // FAB para adicionar equipamento (apenas para admin e gerente)
      floatingActionButton: _currentUser?.role != UserRole.operator
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/equipment/form');
              },
              icon: const Icon(Icons.add),
              label: const Text('Novo Equipamento'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}

/// Widget para exibir item de equipamento na lista
class EquipmentListItem extends StatelessWidget {
  final Map<String, dynamic> equipment;
  final VoidCallback onTap;
  
  const EquipmentListItem({
    Key? key,
    required this.equipment,
    required this.onTap,
  }) : super(key: key);
  
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'maintenance':
        return AppColors.warning;
      case 'inactive':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
  
  String _getStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'maintenance':
        return 'Manutenção';
      case 'inactive':
        return 'Inativo';
      default:
        return 'Desconhecido';
    }
  }
  
  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'active':
        return Icons.check_circle;
      case 'maintenance':
        return Icons.build_circle;
      case 'inactive':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final status = equipment['status'] as String?;
    final alerts = equipment['alerts'] as int? ?? 0;
    final lastSync = equipment['lastSync'] as DateTime?;
    final location = equipment['location'] as Map<String, dynamic>?;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Ícone do equipamento
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Informações principais
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              equipment['serialNumber'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (alerts > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.error),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.warning,
                                      size: 14,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$alerts',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cliente: ${equipment['client'] ?? 'Não informado'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(status)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 16,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Informações adicionais
              Row(
                children: [
                  // Modelo
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          equipment['model'] ?? 'TRM6-MAX',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Total de horas
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${equipment['totalHours']?.toStringAsFixed(1) ?? '0'} horas',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Localização e última sincronização
              Row(
                children: [
                  // Localização
                  if (location != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              location['address'] ?? 'Localização desconhecida',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Última sincronização
                  if (lastSync != null) ...[
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.sync,
                          size: 16,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatLastSync(lastSync),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatLastSync(DateTime lastSync) {
    final difference = DateTime.now().difference(lastSync);
    
    if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours} horas';
    } else {
      return 'há ${difference.inDays} dias';
    }
  }
}