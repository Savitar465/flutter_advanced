import 'package:isar/isar.dart';
import '../../domain/entities/cart_item.dart';
import '../../../products/data/models/product_model.dart';

part 'cart_item_model.g.dart';

@collection
class CartItemModel {
  Id? id = Isar.autoIncrement;

  late int productId;
  late int quantity;
  late DateTime addedAt;

  final product = IsarLink<ProductModel>();

  CartItemModel();

  factory CartItemModel.fromEntity(CartItem cartItem) {
    return CartItemModel()
      ..id = cartItem.id
      ..productId = cartItem.product.id!
      ..quantity = cartItem.quantity
      ..addedAt = cartItem.addedAt;
  }

  CartItem toEntity() {
    return CartItem(
      id: id,
      product: product.value!.toEntity(),
      quantity: quantity,
      addedAt: addedAt,
    );
  }
}