class LegoSetModel {
  final int id;
  final int ownerId;
  final String setNum;
  final String title;
  final String location;
  final double rentalPrice;
  final double deposit;
  final bool scanRequired;
  final String? state;
  final String? notes;
  final bool public;
  final int? numberOfItems;
  final List<String>? missingItems;
  final String createdAt;
  final String? imgUrl;
  final String? visibility; // 'public' | 'friends_only'
  final String? ownerName;
  final double? averageRating;
  final int? reviewCount;
  final bool? scanBeforeReturn;

  const LegoSetModel({
    required this.id,
    required this.ownerId,
    required this.setNum,
    required this.title,
    required this.location,
    required this.rentalPrice,
    required this.deposit,
    required this.scanRequired,
    this.state,
    this.notes,
    required this.public,
    this.numberOfItems,
    this.missingItems,
    required this.createdAt,
    this.imgUrl,
    this.visibility,
    this.ownerName,
    this.averageRating,
    this.reviewCount,
    this.scanBeforeReturn,
  });

  factory LegoSetModel.fromJson(Map<String, dynamic> json) {
    return LegoSetModel(
      id: json['id'] as int,
      ownerId: json['owner_id'] as int,
      setNum: json['set_num'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      rentalPrice: (json['rental_price'] as num?)?.toDouble() ?? 0.0,
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0.0,
      scanRequired: json['scan_required'] as bool? ?? false,
      state: json['state'] as String?,
      notes: json['notes'] as String?,
      public: json['public'] as bool? ?? true,
      numberOfItems: json['number_of_items'] as int?,
      missingItems: (json['missing_items'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] as String? ?? '',
      imgUrl: json['img_url'] as String?,
      visibility: json['visibility'] as String?,
      ownerName: json['owner_name'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
      scanBeforeReturn: json['scan_before_return'] as bool?,
    );
  }
}
