class ScanItemModel {
  final int id;
  final int sessionId;
  final String partNum;
  final String? name;
  final String? color;
  final String status; // ← "ai_identified" | "manually_confirmed" | "missing"
  final int? confirmedBy; // ← ÚJ
  final DateTime? confirmedAt;
  final double? confidence;

  ScanItemModel({
    required this.id,
    required this.sessionId,
    required this.partNum,
    this.name,
    this.color, // ÚJ
    required this.status,
    this.confirmedBy,
    this.confirmedAt,
    this.confidence,
  });

  factory ScanItemModel.fromJson(Map<String, dynamic> json) {
    return ScanItemModel(
      id: json['id'] as int,
      sessionId: json['session_id'] as int,
      partNum: json['part_num'] as String,
      name: json['name'] as String?,
      color: json['color'] as String?,
      status: json['status'] as String,
      confirmedBy: json['confirmed_by'] as int?,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
  // Helper getterek
  bool get isIdentified => status == 'ai_identified';
  bool get isManuallyConfirmed => status == 'manually_confirmed';
  bool get isMissing => status == 'missing';
  bool get isFound => status != 'missing'; // ← AI vagy manuális, mindegy
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
  int get identifiedCount => items.where((i) => i.isFound).length;
  int get totalCount => items.length;
  int get missingCount => items.where((i) => i.isMissing).length;
  int get aiCount => items.where((i) => i.isIdentified).length;
  int get manualCount => items.where((i) => i.isManuallyConfirmed).length;

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
  final String? colorName;
  final double confidence;
  final double detectionConfidence;
  final Map<String, dynamic> boundingBox;

  ScanIdentifyResult({
    required this.partNum,
    this.colorName,
    required this.confidence,
    required this.detectionConfidence,
    required this.boundingBox,
  });

  factory ScanIdentifyResult.fromJson(Map<String, dynamic> json) {
    return ScanIdentifyResult(
      partNum: json['part_num'] as String,
      colorName: json['color_name'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      detectionConfidence: (json['detection_confidence'] as num).toDouble(),
      boundingBox: json['bounding_box'] as Map<String, dynamic>,
    );
  }
}

class ScanIdentifyResponse {
  final int count;
  final List<ScanIdentifyResult> elements;

  ScanIdentifyResponse({required this.count, required this.elements});

  factory ScanIdentifyResponse.fromJson(Map<String, dynamic> json) {
    return ScanIdentifyResponse(
      count: json['count'] as int,
      elements: (json['elements'] as List<dynamic>)
          .map((e) => ScanIdentifyResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
