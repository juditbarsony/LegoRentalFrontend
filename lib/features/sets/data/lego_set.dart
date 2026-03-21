class LegoSet {
  final int id;
  final String name;
  final String? setNum;
  final String? location;
  final String? imageUrl;

  LegoSet({
    required this.id,
    required this.name,
    this.setNum,
    this.location,
    this.imageUrl,
  });

  factory LegoSet.fromJson(Map<String, dynamic> json) {
    return LegoSet(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      setNum: json['set_num']?.toString(),
      location: json['location']?.toString(),
      imageUrl: json['image_url']?.toString(), // ha van ilyen mező
    );
  }
}
