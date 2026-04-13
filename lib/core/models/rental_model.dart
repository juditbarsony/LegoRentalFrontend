class RentalModel {
  final int id;
  final int legoSetId;
  final int renterId;
  final String? setTitle;
  final int? ownerId;
  final String? ownerName;
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
    this.setTitle,
    this.ownerId,
    this.ownerName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'],
      legoSetId: json['lego_set_id'],
      renterId: json['renter_id'],
      setTitle: json['set_title'],
      ownerId: json['owner_id'],
      ownerName: json['owner_name'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}