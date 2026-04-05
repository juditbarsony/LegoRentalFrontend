class ReviewModel {
  final int id;
  final int rentalId;
  final int reviewerId;
  final int revieweeId;
  final int legoSetId;
  final int rating;
  final String? comment;
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.rentalId,
    required this.reviewerId,
    required this.revieweeId,
    required this.legoSetId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      rentalId: json['rental_id'] as int,
      reviewerId: json['reviewer_id'] as int,
      revieweeId: json['reviewee_id'] as int,
      legoSetId: json['lego_set_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}