import 'package:isar/isar.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@collection
class ProductModel {
  Id? id = Isar.autoIncrement;

  late String name;
  late String description;
  late double price;
  late int stock;

  @enumerated
  late ProductCategory category;

  String? imageUrl;
  late bool isAvailable;
  late DateTime createdAt;
  late DateTime updatedAt;

  ProductModel();

  factory ProductModel.fromEntity(Product product) {
    return ProductModel()
      ..id = product.id
      ..name = product.name
      ..description = product.description
      ..price = product.price
      ..stock = product.stock
      ..category = product.category
      ..imageUrl = product.imageUrl
      ..isAvailable = product.isAvailable
      ..createdAt = product.createdAt
      ..updatedAt = product.updatedAt;
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: stock,
      category: category,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}