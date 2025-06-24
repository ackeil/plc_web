import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/users_provider.dart';
import '../widgets/user_form.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UserFormPage extends StatefulWidget {
  final String? userId;
  
  const UserFormPage({super.key, this.userId});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  late final bool isEditing;
  
  @override
  void initState() {
    super.initState();
    isEditing = widget.userId != null;
    
    if (isEditing) {
      // Carregar dados do usuário para edição
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UsersProvider>().loadUser(widget.userId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserRole = authProvider.currentUser?.role ?? '';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuário' : 'Cadastrar Usuário'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Consumer<UsersProvider>(
        builder: (context, usersProvider, child) {
          if (usersProvider.isLoading && isEditing) {
            return const Center(child: LoadingWidget());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho
                Container(
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
                          Icon(
                            isEditing ? Icons.edit : Icons.person_add,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEditing ? 'Editar Informações' : 'Novo Usuário',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getSubtitleText(currentUserRole),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Formulário
                UserForm(
                  user: isEditing ? usersProvider.selectedUser?.toMap() : null,
                  currentUserRole: currentUserRole,
                  onSave: (userData) async {
                    if (isEditing) {
                      await usersProvider.updateUser(widget.userId!, userData);
                    } else {
                      await usersProvider.createUser(userData);
                    }
                    
                    if (mounted && !usersProvider.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing 
                              ? 'Usuário atualizado com sucesso!' 
                              : 'Usuário cadastrado com sucesso!',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context, true);
                    } else if (mounted && usersProvider.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(usersProvider.errorMessage ?? 'Erro ao salvar usuário'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  String _getSubtitleText(String currentUserRole) {
    if (currentUserRole == 'admin') {
      return 'Como administrador, você pode cadastrar gerentes e operadores';
    } else if (currentUserRole == 'manager') {
      return 'Como gerente, você pode cadastrar operadores';
    }
    return 'Preencha os dados do novo usuário';
  }
}