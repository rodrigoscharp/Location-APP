class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'E-mail obrigatório';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha obrigatória';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Campo'} obrigatório';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirme a senha';
    if (value != original) return 'As senhas não coincidem';
    return null;
  }
}
