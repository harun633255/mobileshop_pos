class MemoItemModel {
  final int? id;
  final int? memoId;
  final int? partId;
  final String? model;
  final String? partName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  MemoItemModel({
    this.id,
    this.memoId,
    this.partId,
    this.model,
    this.partName,
    this.quantity = 1,
    this.unitPrice = 0.0,
    this.totalPrice = 0.0,
  });

  factory MemoItemModel.fromMap(Map<String, dynamic> map) {
    return MemoItemModel(
      id: map['id'] as int?,
      memoId: map['memo_id'] as int?,
      partId: map['part_id'] as int?,
      model: map['model'] as String?,
      partName: map['part_name'] as String?,
      quantity: map['quantity'] as int? ?? 1,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'memo_id': memoId,
      'part_id': partId,
      'model': model,
      'part_name': partName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  MemoItemModel copyWith({
    int? id,
    int? memoId,
    int? partId,
    String? model,
    String? partName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return MemoItemModel(
      id: id ?? this.id,
      memoId: memoId ?? this.memoId,
      partId: partId ?? this.partId,
      model: model ?? this.model,
      partName: partName ?? this.partName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
