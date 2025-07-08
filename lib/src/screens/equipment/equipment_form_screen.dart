// lib/src/screens/equipment/equipment_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/equipment_model.dart';
import '../../services/auth_service.dart';
import '../../services/demo_data_services.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

/// Tela de formulário para cadastro e edição de equipamentos
/// 
/// Permite criar novos equipamentos ou editar existentes com:
/// - Informações básicas (serial, modelo, AFT)
/// - Dados do cliente
/// - Configurações de manutenção
/// - Seleção de operadores autorizados
/// - Upload de fotos
class EquipmentFormScreen extends StatefulWidget {
  final String? equipmentId;
  
  const EquipmentFormScreen({
    Key? key,
    this.equipmentId,
  }) : super(key: key);

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  // Serviços
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();
  
  // Form key
  final _formKey = GlobalKey<FormState>();
  
  // Controllers - Informações básicas
  final _serialNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _equipmentAFTController = TextEditingController();
  final _companyNameController = TextEditingController();
  
  // Controllers - Informações do cliente
  final _clientController = TextEditingController();
  final _clientContactController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  
  // Controllers - Manutenção
  final _maintenanceHoursController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Dados
  UserModel? _currentUser;
  Map<String, dynamic>? _originalEquipment;
  List<UserModel> _availableOperators = [];
  List<String> _selectedOperatorIds = [];
  DateTime? _manufacturingDate;
  DateTime? _deliveryDate;
  DateTime? _lastMaintenanceDate;
  String? _selectedImagePath;
  
  // Estados
  bool _isLoading = true;
  bool _isSaving = false;
  bool get _isEditing => widget.equipmentId != null;
  
  // Steps do formulário
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    // Dispose all controllers
    _serialNumberController.dispose();
    _modelController.dispose();
    _equipmentAFTController.dispose();
    _companyNameController.dispose();
    _clientController.dispose();
    _clientContactController.dispose();
    _vehicleModelController.dispose();
    _vehiclePlateController.dispose();
    _maintenanceHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  /// Carrega dados iniciais
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Busca usuário atual
      final user = await _authService.getCurrentUser();
      
      // Busca operadores disponíveis
      final allUsers = await _authService.getAllUsers();
      final operators = allUsers
          .where((u) => u.role == UserRole.operator)
          .toList();
      
      // Se editando, carrega dados do equipamento
      if (_isEditing) {
        final equipments = _demoDataService.getDemoEquipments();
        final equipment = equipments.firstWhere(
          (e) => e['id'] == widget.equipmentId,
          orElse: () => <String, dynamic>{},
        );
        
        if (equipment.isEmpty) {
          throw Exception('Equipamento não encontrado');
        }
        
        _originalEquipment = equipment;
        _populateForm(equipment);
      } else {
        // Valores padrão para novo equipamento
        _modelController.text = 'TRM6-MAX';
        _maintenanceHoursController.text = '500';
        _companyNameController.text = user?.companyName ?? '';
        
        // Gera número de série sugerido
        final year = DateTime.now().year;
        final nextNumber = (_getNextSerialNumber() + 1).toString().padLeft(3, '0');
        _serialNumberController.text = 'TRM6-MAX-$year$nextNumber';
      }
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _availableOperators = operators;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erro ao carregar dados');
        Navigator.pop(context);
      }
    }
  }
  
  /// Popula formulário com dados do equipamento
  void _populateForm(Map<String, dynamic> equipment) {
    _serialNumberController.text = equipment['serialNumber'] ?? '';
    _modelController.text = equipment['model'] ?? 'TRM6-MAX';
    _equipmentAFTController.text = equipment['equipmentAFT'] ?? '';
    _companyNameController.text = equipment['companyName'] ?? '';
    
    _clientController.text = equipment['client'] ?? '';
    _clientContactController.text = equipment['clientContact'] ?? '';
    _vehicleModelController.text = equipment['vehicleModel'] ?? '';
    _vehiclePlateController.text = equipment['vehiclePlate'] ?? '';
    
    _maintenanceHoursController.text = (equipment['maintenanceHours'] ?? 500).toString();
    _notesController.text = equipment['notes'] ?? '';
    
    _manufacturingDate = equipment['manufacturingDate'];
    _deliveryDate = equipment['deliveryDate'];
    _lastMaintenanceDate = equipment['lastMaintenance'];
    
    _selectedOperatorIds = List<String>.from(equipment['authorizedOperators'] ?? []);
  }
  
  /// Obtém próximo número de série disponível
  int _getNextSerialNumber() {
    final equipments = _demoDataService.getDemoEquipments();
    final year = DateTime.now().year.toString();
    
    final numbers = equipments
        .map((e) => e['serialNumber'] as String?)
        .where((serial) => serial != null && serial.contains(year))
        .map((serial) {
          final match = RegExp(r'(\d{7})$').firstMatch(serial!);
          return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
        })
        .toList();
    
    return numbers.isEmpty ? 0 : numbers.reduce((a, b) => a > b ? a : b);
  }
  
  /// Seleciona data
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );
    
    if (picked != null) {
      setState(() => onSelected(picked));
    }
  }
  
  /// Seleciona imagem
  Future<void> _selectImage() async {
    // TODO: Implementar seleção de imagem
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seleção de imagem ainda não implementada'),
        backgroundColor: AppColors.warning,
      ),
    );
  }
  
  /// Valida e salva o formulário
  Future<void> _saveEquipment() async {
    // Valida formulário
    if (!_formKey.currentState!.validate()) {
      // Vai para o primeiro step com erro
      for (int i = 0; i < 3; i++) {
        if (!_validateStep(i)) {
          setState(() => _currentStep = i);
          break;
        }
      }
      return;
    }
    
    // Confirma salvamento
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;
    
    setState(() => _isSaving = true);
    
    try {
      // Simula salvamento
      await _demoDataService.simulateNetworkDelay(milliseconds: 1500);
      
      // Monta objeto do equipamento
      final equipment = {
        'id': _isEditing ? widget.equipmentId : 'equip-${DateTime.now().millisecondsSinceEpoch}',
        'serialNumber': _serialNumberController.text.trim(),
        'model': _modelController.text.trim(),
        'equipmentAFT': _equipmentAFTController.text.trim(),
        'companyId': _currentUser?.companyId ?? 'demo-company',
        'companyName': _companyNameController.text.trim(),
        'manufacturingDate': _manufacturingDate ?? DateTime.now(),
        'deliveryDate': _deliveryDate,
        'client': _clientController.text.trim(),
        'clientContact': _clientContactController.text.trim(),
        'vehicleModel': _vehicleModelController.text.trim(),
        'vehiclePlate': _vehiclePlateController.text.trim(),
        'maintenanceHours': int.tryParse(_maintenanceHoursController.text) ?? 500,
        'lastMaintenance': _lastMaintenanceDate,
        'nextMaintenance': _calculateNextMaintenance(),
        'authorizedOperators': _selectedOperatorIds,
        'notes': _notesController.text.trim(),
        'createdAt': _isEditing ? _originalEquipment!['createdAt'] : DateTime.now(),
        'lastSync': DateTime.now(),
        'status': 'active',
        'alerts': 0,
        'operations': _isEditing ? _originalEquipment!['operations'] ?? 0 : 0,
        'totalHours': _isEditing ? _originalEquipment!['totalHours'] ?? 0.0 : 0.0,
      };
      
      // TODO: Salvar no Firebase
      print('Equipamento salvo: $equipment');
      
      if (mounted) {
        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Equipamento atualizado!' : 'Equipamento cadastrado!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Volta para tela anterior
        Navigator.pop(context, equipment);
      }
    } catch (e) {
      print('Erro ao salvar: $e');
      _showError('Erro ao salvar equipamento');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  
  /// Calcula próxima manutenção
  DateTime? _calculateNextMaintenance() {
    if (_lastMaintenanceDate == null) return null;
    
    final maintenanceHours = int.tryParse(_maintenanceHoursController.text) ?? 500;
    // Assumindo 8 horas de trabalho por dia
    final days = (maintenanceHours / 8).ceil();
    
    return _lastMaintenanceDate!.add(Duration(days: days));
  }
  
  /// Valida step específico
  bool _validateStep(int step) {
    switch (step) {
      case 0: // Informações básicas
        return _serialNumberController.text.isNotEmpty &&
               _modelController.text.isNotEmpty &&
               _equipmentAFTController.text.isNotEmpty &&
               _manufacturingDate != null;
      case 1: // Cliente e veículo
        return _clientController.text.isNotEmpty;
      case 2: // Configurações
        return _maintenanceHoursController.text.isNotEmpty &&
               _selectedOperatorIds.isNotEmpty;
      default:
        return true;
    }
  }
  
  /// Mostra diálogo de confirmação
  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Confirmar Alterações' : 'Confirmar Cadastro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_isEditing 
                ? 'Deseja salvar as alterações no equipamento?' 
                : 'Deseja cadastrar este novo equipamento?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Número de Série: ${_serialNumberController.text}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Cliente: ${_clientController.text}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
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
  
  /// Constrói step de informações básicas
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações Básicas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dados de identificação do equipamento',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          
          // Número de série
          CustomTextField(
            controller: _serialNumberController,
            label: 'Número de Série *',
            hint: 'TRM6-MAX-YYYYNNN',
            prefixIcon: Icons.qr_code,
            textInputAction: TextInputAction.next,
            validator: Validators.serialNumber,
            enabled: !_isEditing, // Não pode editar em modo edição
          ),
          
          const SizedBox(height: 16),
          
          // Modelo
          CustomTextField(
            controller: _modelController,
            label: 'Modelo *',
            hint: 'TRM6-MAX',
            prefixIcon: Icons.category,
            textInputAction: TextInputAction.next,
            validator: (value) => Validators.required(value, fieldName: 'Modelo'),
          ),
          
          const SizedBox(height: 16),
          
          // Número AFT
          CustomTextField(
            controller: _equipmentAFTController,
            label: 'Equipamento AFT *',
            hint: '45.700',
            prefixIcon: Icons.tag,
            textInputAction: TextInputAction.next,
            validator: (value) => Validators.required(value, fieldName: 'Equipamento AFT'),
          ),
          
          const SizedBox(height: 16),
          
          // Empresa/Fabricante
          CustomTextField(
            controller: _companyNameController,
            label: 'Empresa/Fabricante',
            hint: 'Nome da empresa',
            prefixIcon: Icons.business,
            enabled: false, // Pega automaticamente do usuário
          ),
          
          const SizedBox(height: 24),
          
          // Data de fabricação
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
            ),
            title: const Text('Data de Fabricação *'),
            subtitle: Text(
              _manufacturingDate != null
                  ? _formatDate(_manufacturingDate!)
                  : 'Selecione a data',
              style: TextStyle(
                color: _manufacturingDate != null 
                    ? AppColors.textPrimary 
                    : AppColors.textSecondary,
              ),
            ),
            onTap: () => _selectDate(
              context, 
              _manufacturingDate,
              (date) => _manufacturingDate = date,
            ),
          ),
          
          const Divider(),
          
          // Data de entrega
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_shipping,
                color: AppColors.info,
              ),
            ),
            title: const Text('Data de Entrega'),
            subtitle: Text(
              _deliveryDate != null
                  ? _formatDate(_deliveryDate!)
                  : 'Selecione a data (opcional)',
              style: TextStyle(
                color: _deliveryDate != null 
                    ? AppColors.textPrimary 
                    : AppColors.textSecondary,
              ),
            ),
            onTap: () => _selectDate(
              context, 
              _deliveryDate,
              (date) => _deliveryDate = date,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói step de cliente e veículo
  Widget _buildClientStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cliente e Veículo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Informações do cliente e veículo onde será instalado',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          
          // Cliente
          CustomTextField(
            controller: _clientController,
            label: 'Cliente *',
            hint: 'Nome do cliente ou empresa',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: (value) => Validators.required(value, fieldName: 'Cliente'),
          ),
          
          const SizedBox(height: 16),
          
          // Contato do cliente
          CustomTextField(
            controller: _clientContactController,
            label: 'Contato do Cliente',
            hint: 'Nome - (XX) XXXXX-XXXX',
            prefixIcon: Icons.phone,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 24),
          
          const Divider(),
          
          const SizedBox(height: 24),
          
          // Modelo do veículo
          CustomTextField(
            controller: _vehicleModelController,
            label: 'Modelo do Veículo',
            hint: 'Ex: Mercedes 1933',
            prefixIcon: Icons.local_shipping,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 16),
          
          // Placa do veículo
          CustomTextField(
            controller: _vehiclePlateController,
            label: 'Placa do Veículo',
            hint: 'ABC-1234 ou ABC1D23',
            prefixIcon: Icons.confirmation_number,
            textInputAction: TextInputAction.next,
            validator: Validators.vehiclePlate,
            textCapitalization: TextCapitalization.characters,
          ),
          
          const SizedBox(height: 24),
          
          // Upload de foto
          Card(
            child: InkWell(
              onTap: _selectImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.background,
                ),
                child: _selectedImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Adicionar Foto do Equipamento',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Toque para selecionar',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói step de configurações
  Widget _buildConfigStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manutenção e operadores autorizados',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          
          // Intervalo de manutenção
          CustomTextField(
            controller: _maintenanceHoursController,
            label: 'Intervalo de Manutenção (horas) *',
            hint: '500',
            prefixIcon: Icons.schedule,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) => Validators.minValue(value, 1, fieldName: 'Intervalo'),
          ),
          
          const SizedBox(height: 16),
          
          // Última manutenção
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.build,
                color: AppColors.warning,
              ),
            ),
            title: const Text('Última Manutenção'),
            subtitle: Text(
              _lastMaintenanceDate != null
                  ? _formatDate(_lastMaintenanceDate!)
                  : 'Não realizada',
              style: TextStyle(
                color: _lastMaintenanceDate != null 
                    ? AppColors.textPrimary 
                    : AppColors.textSecondary,
              ),
            ),
            onTap: () => _selectDate(
              context, 
              _lastMaintenanceDate,
              (date) => _lastMaintenanceDate = date,
            ),
          ),
          
          const Divider(),
          
          // Observações
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Observações',
              hintText: 'Anotações sobre o equipamento...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 4,
          ),
          
          const SizedBox(height: 24),
          
          // Operadores autorizados
          const Text(
            'Operadores Autorizados *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecione os operadores que podem usar este equipamento',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_availableOperators.isEmpty)
            Card(
              color: AppColors.warning.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Nenhum operador cadastrado.\nCadastre operadores antes de continuar.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: _availableOperators.map((operator) {
                  final isSelected = _selectedOperatorIds.contains(operator.id);
                  
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedOperatorIds.add(operator.id);
                        } else {
                          _selectedOperatorIds.remove(operator.id);
                        }
                      });
                    },
                    title: Text(operator.name),
                    subtitle: Text(operator.email),
                    secondary: CircleAvatar(
                      backgroundColor: isSelected 
                          ? AppColors.primary 
                          : AppColors.textSecondary.withOpacity(0.2),
                      child: Text(
                        operator.name.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          if (_selectedOperatorIds.isEmpty && _availableOperators.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selecione pelo menos um operador',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Equipamento' : 'Novo Equipamento'),
        ),
        body: Center(
          child: LoadingWidget(
            message: 'Carregando formulário...',
          ),
        ),
      );
    }
    
    return WillPopScope(
      onWillPop: () async {
        if (_isSaving) return false;
        
        // Verifica se há alterações não salvas
        final hasChanges = !_isEditing || _hasUnsavedChanges();
        if (!hasChanges) return true;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Descartar Alterações?'),
            content: const Text('Existem alterações não salvas. Deseja descartar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Descartar'),
              ),
            ],
          ),
        );
        
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Equipamento' : 'Novo Equipamento'),
          actions: [
            // Botão de salvar no AppBar
            TextButton.icon(
              onPressed: _isSaving ? null : _saveEquipment,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Salvar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              
              // Stepper content
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: Stepper(
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_currentStep < 2) {
                        if (_validateStep(_currentStep)) {
                          setState(() => _currentStep++);
                        } else {
                          _showError('Preencha todos os campos obrigatórios');
                        }
                      } else {
                        _saveEquipment();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      }
                    },
                    onStepTapped: (step) {
                      setState(() => _currentStep = step);
                    },
                    controlsBuilder: (context, details) {
                      final isLastStep = _currentStep == 2;
                      
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            if (!isLastStep)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  child: const Text('Próximo'),
                                ),
                              ),
                            if (isLastStep)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveEquipment,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: Text(_isEditing ? 'Salvar Alterações' : 'Cadastrar'),
                                ),
                              ),
                            if (_currentStep > 0) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: details.onStepCancel,
                                child: const Text('Voltar'),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    steps: [
                      Step(
                        title: const Text('Informações Básicas'),
                        content: _buildBasicInfoStep(),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0 && _validateStep(0)
                            ? StepState.complete
                            : _currentStep == 0
                                ? StepState.editing
                                : StepState.indexed,
                      ),
                      Step(
                        title: const Text('Cliente e Veículo'),
                        content: _buildClientStep(),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1 && _validateStep(1)
                            ? StepState.complete
                            : _currentStep == 1
                                ? StepState.editing
                                : StepState.indexed,
                      ),
                      Step(
                        title: const Text('Configurações'),
                        content: _buildConfigStep(),
                        isActive: _currentStep >= 2,
                        state: _currentStep == 2
                            ? StepState.editing
                            : StepState.indexed,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Verifica se há alterações não salvas
  bool _hasUnsavedChanges() {
    if (_originalEquipment == null) return false;
    
    // Compara valores principais
    return _serialNumberController.text != (_originalEquipment!['serialNumber'] ?? '') ||
           _modelController.text != (_originalEquipment!['model'] ?? '') ||
           _equipmentAFTController.text != (_originalEquipment!['equipmentAFT'] ?? '') ||
           _clientController.text != (_originalEquipment!['client'] ?? '') ||
           _notesController.text != (_originalEquipment!['notes'] ?? '');
  }
}