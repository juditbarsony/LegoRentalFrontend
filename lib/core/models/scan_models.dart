class ScanItemModel {
  final int id;
  final int sessionId;
  final String partNum;
  final String? name; 
  final String? color;      // ÚJ
  final bool identified;
  final double? confidence;

  ScanItemModel({
    required this.id,
    required this.sessionId,
    required this.partNum,
    this.name,
    this.color,             // ÚJ
    required this.identified,
    this.confidence,
  });

  factory ScanItemModel.fromJson(Map<String, dynamic> json) {
    return ScanItemModel(
      id: json['id'] as int,
      sessionId: json['session_id'] as int,
      partNum: json['part_num'] as String,
      name: json['name'] as String?,
      color: json['color'] as String?,    
      identified: json['identified'] as bool,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}


class ScanSessionModel {
  final int id;
  final int rentalId;
  final int legoSetId;
  final DateTime scannedAt;
  final String status;
  final List<ScanItemModel> items;

  ScanSessionModel({
    required this.id,
    required this.rentalId,
    required this.legoSetId,
    required this.scannedAt,
    required this.status,
    required this.items,
  });

  factory ScanSessionModel.fromJson(Map<String, dynamic> json) {
    return ScanSessionModel(
      id: json['id'] as int,
      rentalId: json['rental_id'] as int,
      legoSetId: json['lego_set_id'] as int,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ScanItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── Getterek ──────────────────────────────────────────────
  int get identifiedCount => items.where((i) => i.identified).length;
  int get totalCount => items.length;
  int get missingCount => items.where((i) => !i.identified).length;

  // part_num + color szerint csoportosítva
  Map<String, List<ScanItemModel>> get itemsByPartNum {
    final map = <String, List<ScanItemModel>>{};
    for (final item in items) {
      final key = '${item.partNum} (${item.color ?? "?"})';
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
}


class ScanIdentifyResult {
  final String partNum;
  final double confidence;

  ScanIdentifyResult({required this.partNum, required this.confidence});

  factory ScanIdentifyResult.fromJson(Map<String, dynamic> json) {
    return ScanIdentifyResult(
      partNum: json['part_num'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
