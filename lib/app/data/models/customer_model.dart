class CustomerModel {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? createdAt;

  CustomerModel({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'created_at': createdAt,
    };
  }

  CustomerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
