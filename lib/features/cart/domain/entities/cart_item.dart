import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product.dart';

class CartItem extends Equatable {
  final int? id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  const CartItem({
    this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  double get total => product.price * quantity;

  CartItem copyWith({
    int? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity, addedAt];
}