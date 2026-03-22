class LegoSet {
  final int id;
  final String title;
  final String? setNum;
  final String? location;
  final String? imageUrl;

  LegoSet({
    required this.id,
    required this.title,
    this.setNum,
    this.location,
    this.imageUrl,
  });

  factory LegoSet.fromJson(Map<String, dynamic> json) {
    return LegoSet(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      setNum: json['set_num']?.toString(),
      location: json['location']?.toString(),
      imageUrl: json['image_url']?.toString(), // ha van ilyen mező
    );
  }
}
