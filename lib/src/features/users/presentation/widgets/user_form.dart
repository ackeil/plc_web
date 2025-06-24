import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/user_role.dart';

class UserForm extends StatefulWidget {
  final Map<String, dynamic>? user;
  final String currentUserRole;
  final Function(Map<String, dynamic>) onSave;
  
  const UserForm({
    super.key,
    this.user,
    required this.currentUserRole,
    required this.onSave,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cpfController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  
  String _selectedRole = UserRole.operator;
  List<String> _assignedEquipments = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?['name'] ?? '');
    _emailController = TextEditingController(text: widget.user?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.user?['phone'] ?? '');
    _cpfController = TextEditingController(text: widget.user?['cpf'] ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    if (widget.user != null) {
      _selectedRole = widget.user!['role'] ?? UserRole.operator;
      _assignedEquipments = List<String>.from(widget.user!['assignedEquipments'] ?? []);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  List<String> _getAvailableRoles() {
    if (widget.currentUserRole == 'admin') {
      return [UserRole.manager, UserRole.operator];
    } else if (widget.currentUserRole == 'manager') {
      return [UserRole.operator];
    }
    return [];
  }
  
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'role': _selectedRole,
        'assignedEquipments': _assignedEquipments,
      };
      
      // Só incluir senha se for novo usuário ou se foi alterada
      if (widget.user == null || _passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      }
      
      widget.onSave(userData);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final availableRoles = _getAvailableRoles();
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informações Pessoais
          _buildSectionCard(
            title: 'Informações Pessoais',
            icon: Icons.person_outline,
            children: [
              // Nome
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _buildInputDecoration(
                  label: 'Nome Completo',
                  hint: 'João da Silva',
                  icon: Icons.badge_outlined,
                ),
                validator: Validators.required,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration(
                  label: 'E-mail',
                  hint: 'usuario@empresa.com',
                  icon: Icons.email_outlined,
                ),
                validator: Validators.email,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              
              // Telefone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _PhoneInputFormatter(),
                ],
                decoration: _buildInputDecoration(
                  label: 'Telefone',
                  hint: '(00) 00000-0000',
                  icon: Icons.phone_outlined,
                ),
                validator: Validators.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              
              // CPF
              TextFormField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CpfInputFormatter(),
                ],
                decoration: _buildInputDecoration(
                  label: 'CPF',
                  hint: '000.000.000-00',
                  icon: Icons.credit_card,
                ),
                validator: Validators.cpf,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Configurações de Acesso
          _buildSectionCard(
            title: 'Configurações de Acesso',
            icon: Icons.security,
            children: [
              // Tipo de usuário
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _buildInputDecoration(
                  label: 'Tipo de Usuário',
                  icon: Icons.admin_panel_settings_outlined,
                ),
                items: availableRoles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(_getRoleDisplayName(role)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione um tipo de usuário';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Senha (apenas para novos usuários ou edição)
              if (widget.user == null) ...[
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _buildInputDecoration(
                    label: 'Senha',
                    hint: 'Mínimo 8 caracteres',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: widget.user == null ? Validators.password : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _buildInputDecoration(
                    label: 'Confirmar Senha',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (widget.user == null) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme a senha';
                      }
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ] else ...[
                // Para edição, mostrar campo opcional de nova senha
                Text(
                  'Deixe em branco para manter a senha atual',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _buildInputDecoration(
                    label: 'Nova Senha (opcional)',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return Validators.password(value);
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
          
          // Botões de ação
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: widget.user == null ? 'Cadastrar' : 'Salvar Alterações',
                  onPressed: _handleSubmit,
                  height: 56,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
  
  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      filled: true,
      fillColor: AppColors.inputBackground,
    );
  }
  
  String _getRoleDisplayName(String role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.manager:
        return 'Gerente';
      case UserRole.operator:
        return 'Operador';
      default:
        return role;
    }
  }
}

// Formatador para telefone
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < newText.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      if (i >= 11) break;
      buffer.write(newText[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Formatador para CPF
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < newText.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      if (i >= 11) break;
      buffer.write(newText[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}