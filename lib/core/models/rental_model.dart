class RentalModel {
  final int id;
  final int legoSetId;
  final int renterId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentalModel({
    required this.id,
    required this.legoSetId,
    required this.renterId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] as int,
      legoSetId: json['lego_set_id'] as int,
      renterId: json['renter_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
