class PartModel {
  final int? id;
  final String model;
  final String partName;
  final double? price;
  final double? customerPrice;
  final double? tudoPrice;
  final String? category;
  final String? createdAt;
  final String? updatedAt;

  PartModel({
    this.id,
    required this.model,
    required this.partName,
    this.price,
    this.customerPrice,
    this.tudoPrice,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory PartModel.fromMap(Map<String, dynamic> map) {
    return PartModel(
      id: map['id'] as int?,
      model: map['model'] as String? ?? '',
      partName: map['part_name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble(),
      customerPrice: (map['customer_price'] as num?)?.toDouble(),
      tudoPrice: (map['tudo_price'] as num?)?.toDouble(),
      category: map['category'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'model': model,
      'part_name': partName,
      'price': price,
      'customer_price': customerPrice,
      'tudo_price': tudoPrice,
      'category': category,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  PartModel copyWith({
    int? id,
    String? model,
    String? partName,
    double? price,
    double? customerPrice,
    double? tudoPrice,
    String? category,
    String? createdAt,
    String? updatedAt,
  }) {
    return PartModel(
      id: id ?? this.id,
      model: model ?? this.model,
      partName: partName ?? this.partName,
      price: price ?? this.price,
      customerPrice: customerPrice ?? this.customerPrice,
      tudoPrice: tudoPrice ?? this.tudoPrice,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
