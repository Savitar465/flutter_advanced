import 'package:equatable/equatable.dart';

enum ProductCategory {
  shirts,
  pants,
  dresses,
  shoes,
  accessories,
}

class Product extends Equatable {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final ProductCategory category;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    ProductCategory? category,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    stock,
    category,
    imageUrl,
    isAvailable,
    createdAt,
    updatedAt,
  ];
}