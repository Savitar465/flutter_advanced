class Validators {
  static String? productName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del producto es requerido';
    }
    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es requerido';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Ingrese un precio válido mayor a 0';
    }
    return null;
  }

  static String? stock(String? value) {
    if (value == null || value.isEmpty) {
      return 'El stock es requerido';
    }
    final stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return 'Ingrese un stock válido';
    }
    return null;
  }
}