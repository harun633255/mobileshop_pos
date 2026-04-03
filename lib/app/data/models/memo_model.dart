class MemoModel {
  final int? id;
  final String? memoNumber;
  final int? customerId;
  final String? customerName;
  final double? subtotal;
  final double? discount;
  final double? total;
  final String? note;
  final String? createdAt;

  MemoModel({
    this.id,
    this.memoNumber,
    this.customerId,
    this.customerName,
    this.subtotal,
    this.discount,
    this.total,
    this.note,
    this.createdAt,
  });

  factory MemoModel.fromMap(Map<String, dynamic> map) {
    return MemoModel(
      id: map['id'] as int?,
      memoNumber: map['memo_number'] as String?,
      customerId: map['customer_id'] as int?,
      customerName: map['customer_name'] as String?,
      subtotal: (map['subtotal'] as num?)?.toDouble(),
      discount: (map['discount'] as num?)?.toDouble(),
      total: (map['total'] as num?)?.toDouble(),
      note: map['note'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'memo_number': memoNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'note': note,
      'created_at': createdAt,
    };
  }

  MemoModel copyWith({
    int? id,
    String? memoNumber,
    int? customerId,
    String? customerName,
    double? subtotal,
    double? discount,
    double? total,
    String? note,
    String? createdAt,
  }) {
    return MemoModel(
      id: id ?? this.id,
      memoNumber: memoNumber ?? this.memoNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
