class Validators {
  // Validação de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    
    return null;
  }
  
  // Validação de senha
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    
    // Verificar se contém pelo menos uma letra e um número
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(value)) {
      return 'A senha deve conter letras e números';
    }
    
    return null;
  }
  
  // Validação de campo obrigatório
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo é obrigatório';
    }
    return null;
  }
  
  // Validação de CPF
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    // Remove caracteres não numéricos
    final cpf = value.replaceAll(RegExp(r'\D'), '');
    
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }
    
    // Validação do CPF
    if (!_isValidCPF(cpf)) {
      return 'CPF inválido';
    }
    
    return null;
  }
  
  // Validação de telefone
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    // Remove caracteres não numéricos
    final phone = value.replaceAll(RegExp(r'\D'), '');
    
    if (phone.length < 10 || phone.length > 11) {
      return 'Telefone inválido';
    }
    
    return null;
  }
  
  // Validação de número de série
  static String? serialNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Número de série é obrigatório';
    }
    
    if (value.length < 5) {
      return 'Número de série muito curto';
    }
    
    return null;
  }
  
  // Validação de data
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data é obrigatória';
    }
    
    try {
      final parts = value.split('/');
      if (parts.length != 3) {
        return 'Formato de data inválido (DD/MM/AAAA)';
      }
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final date = DateTime(year, month, day);
      
      if (date.isAfter(DateTime.now())) {
        return 'Data não pode ser futura';
      }
      
      if (year < 1900) {
        return 'Ano inválido';
      }
      
    } catch (e) {
      return 'Data inválida';
    }
    
    return null;
  }
  
  // Validação de número
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo é obrigatório';
    }
    
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Valor numérico inválido';
    }
    
    return null;
  }
  
  // Validação de URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL é opcional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL inválida';
    }
    
    return null;
  }
  
  // Função auxiliar para validar CPF
  static bool _isValidCPF(String cpf) {
    List<int> numbers = cpf.split('').map((e) => int.parse(e)).toList();
    
    // Calcular primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += numbers[i] * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;
    
    if (firstDigit != numbers[9]) {
      return false;
    }
    
    // Calcular segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += numbers[i] * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;
    
    return secondDigit == numbers[10];
  }
}