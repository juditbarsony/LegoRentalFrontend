class AvailabilityModel {
  final int id;
  final int legoSetId;
  final DateTime startDate;
  final DateTime endDate;

  AvailabilityModel({
    required this.id,
    required this.legoSetId,
    required this.startDate,
    required this.endDate,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] as int,
      legoSetId: json['lego_set_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }
}
