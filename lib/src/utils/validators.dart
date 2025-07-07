// lib/utils/validators.dart

/// Classe com validadores reutilizáveis para formulários
/// 
/// Centraliza toda a lógica de validação do aplicativo,
/// garantindo consistência e facilitando manutenção
class Validators {
  // Regex patterns
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _phoneRegex = RegExp(
    r'^\(?[1-9]{2}\)?\s?9?[0-9]{4}-?[0-9]{4}$',
  );
  
  static final RegExp _nameRegex = RegExp(
    r'^[a-zA-ZÀ-ÿ\s]{2,}$',
  );
  
  /// Valida campo de email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    
    final trimmedValue = value.trim();
    
    if (!_emailRegex.hasMatch(trimmedValue)) {
      return 'Email inválido';
    }
    
    return null;
  }
  
  /// Valida campo de senha
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }
  
  /// Valida campo de senha com requisitos mais rigorosos
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    
    // Verifica se tem pelo menos uma letra maiúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    
    // Verifica se tem pelo menos uma letra minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }
    
    // Verifica se tem pelo menos um número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter pelo menos um número';
    }
    
    // Verifica se tem pelo menos um caractere especial
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Senha deve conter pelo menos um caractere especial';
    }
    
    return null;
  }
  
  /// Valida confirmação de senha
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    
    if (value != password) {
      return 'As senhas não coincidem';
    }
    
    return null;
  }
  
  /// Valida campo de nome
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    if (!_nameRegex.hasMatch(trimmedValue)) {
      return 'Nome contém caracteres inválidos';
    }
    
    return null;
  }
  
  /// Valida campo de telefone brasileiro
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    // Remove caracteres não numéricos para validação
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanValue.length < 10 || cleanValue.length > 11) {
      return 'Telefone inválido';
    }
    
    if (!_phoneRegex.hasMatch(value)) {
      return 'Formato de telefone inválido';
    }
    
    return null;
  }
  
  /// Valida campo obrigatório genérico
  static String? required(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    
    return null;
  }
  
  /// Valida número de série de equipamento
  static String? serialNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Número de série é obrigatório';
    }
    
    final trimmedValue = value.trim();
    
    // Formato esperado: TRM6-MAX-YYYYNNN
    if (!RegExp(r'^TRM6-MAX-\d{7}$').hasMatch(trimmedValue)) {
      return 'Formato inválido. Use: TRM6-MAX-YYYYNNN';
    }
    
    return null;
  }
  
  /// Valida placa de veículo brasileiro
  static String? vehiclePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Placa é opcional
    }
    
    final trimmedValue = value.trim().toUpperCase();
    
    // Formato antigo: ABC-1234
    final oldFormat = RegExp(r'^[A-Z]{3}-\d{4}$');
    // Formato Mercosul: ABC1D23
    final mercosulFormat = RegExp(r'^[A-Z]{3}\d[A-Z]\d{2}$');
    
    if (!oldFormat.hasMatch(trimmedValue) && !mercosulFormat.hasMatch(trimmedValue)) {
      return 'Placa inválida (ABC-1234 ou ABC1D23)';
    }
    
    return null;
  }
  
  /// Valida CNPJ
  static String? cnpj(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CNPJ é obrigatório';
    }
    
    // Remove caracteres não numéricos
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanValue.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }
    
    // Validação básica do CNPJ (não implementa o algoritmo completo por simplicidade)
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cleanValue)) {
      return 'CNPJ inválido';
    }
    
    return null;
  }
  
  /// Valida valor numérico mínimo
  static String? minValue(String? value, double min, {String fieldName = 'Valor'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Permite vazio
    }
    
    final numValue = double.tryParse(value.replaceAll(',', '.'));
    
    if (numValue == null) {
      return '$fieldName deve ser um número válido';
    }
    
    if (numValue < min) {
      return '$fieldName deve ser maior ou igual a $min';
    }
    
    return null;
  }
  
  /// Valida valor numérico máximo
  static String? maxValue(String? value, double max, {String fieldName = 'Valor'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Permite vazio
    }
    
    final numValue = double.tryParse(value.replaceAll(',', '.'));
    
    if (numValue == null) {
      return '$fieldName deve ser um número válido';
    }
    
    if (numValue > max) {
      return '$fieldName deve ser menor ou igual a $max';
    }
    
    return null;
  }
  
  /// Valida range de valores numéricos
  static String? range(String? value, double min, double max, {String fieldName = 'Valor'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Permite vazio
    }
    
    final numValue = double.tryParse(value.replaceAll(',', '.'));
    
    if (numValue == null) {
      return '$fieldName deve ser um número válido';
    }
    
    if (numValue < min || numValue > max) {
      return '$fieldName deve estar entre $min e $max';
    }
    
    return null;
  }
  
  /// Valida lista de seleção (dropdown, checkbox, etc)
  static String? selection<T>(T? value, {String fieldName = 'Seleção'}) {
    if (value == null) {
      return '$fieldName é obrigatória';
    }
    
    if (value is List && value.isEmpty) {
      return 'Selecione pelo menos uma opção';
    }
    
    return null;
  }
}