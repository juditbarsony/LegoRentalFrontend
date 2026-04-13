class ScanItemModel {
  final int id;
  final int sessionId;
  final String partNum;
  final String? name;
  final String? color;
  final String? imgUrl;
  final String status;
  final double? confidence;

  ScanItemModel({
    required this.id,
    required this.sessionId,
    required this.partNum,
    this.name,
    this.color,
    this.imgUrl,
    required this.status,
    this.confidence,
  });

  // Bool getter, nem tárolt mező
  bool get identified =>
      status == 'ai_identified' || status == 'manually_confirmed';

  bool get isFound => identified;

  bool get isMissing => status == 'missing';

  bool get isIdentified => status == 'ai_identified';

  bool get isManuallyConfirmed => status == 'manually_confirmed';

  factory ScanItemModel.fromJson(Map<String, dynamic> json) {
    return ScanItemModel(
      id: json['id'] as int,
      sessionId: json['session_id'] as int,
      partNum: json['part_num'] as String,
      name: json['name'] as String?,
      color: json['color'] as String?,
      imgUrl: json['img_url'] as String?,
      status: json['status'] as String? ?? 'missing',
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

class ScanSessionModel {
  final int id;
  final int rentalId;
  final int legoSetId;
  final int? scannedBy; // ÚJ
  final DateTime scannedAt;
  final DateTime? finishedAt; // ÚJ
  final String status;
  final List<ScanItemModel> items;
  // Kalkulált mezők a backend válaszából (fallback: getter számol)
  final int? _expectedCount;
  final int? _identifiedCountOverride;
  final int? _manuallyConfirmedCountOverride;
  final int? _missingCountOverride;

  ScanSessionModel({
    required this.id,
    required this.rentalId,
    required this.legoSetId,
    this.scannedBy,
    required this.scannedAt,
    this.finishedAt,
    required this.status,
    required this.items,
    int? expectedCount,
    int? identifiedCountOverride,
    int? manuallyConfirmedCountOverride,
    int? missingCountOverride,
  })  : _expectedCount = expectedCount,
        _identifiedCountOverride = identifiedCountOverride,
        _manuallyConfirmedCountOverride = manuallyConfirmedCountOverride,
        _missingCountOverride = missingCountOverride;

  factory ScanSessionModel.fromJson(Map<String, dynamic> json) {
    print('DEBUG fromJson items: ${(json['items'] as List?)?.length}');
    print('DEBUG fromJson expected_count: ${json['expected_count']}');
    return ScanSessionModel(
      id: json['id'] as int,
      rentalId: json['rental_id'] as int,
      legoSetId: json['lego_set_id'] as int,
      scannedBy: json['scanned_by'] as int?,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'] as String)
          : null,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ScanItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expectedCount: json['expected_count'] as int?,
      identifiedCountOverride: json['identified_count'] as int?,
      manuallyConfirmedCountOverride: json['manually_confirmed_count'] as int?,
      missingCountOverride: json['missing_count'] as int?,
    );
  }

  // ── Getterek – backend értéket használ, ha van, egyébként lokálisan számol ──
  int get identifiedCount =>
      _identifiedCountOverride ?? items.where((i) => i.isFound).length;
  int get totalCount => _expectedCount ?? items.length;
  int get missingCount =>
      _missingCountOverride ?? items.where((i) => i.isMissing).length;
  int get aiCount => items.where((i) => i.isIdentified).length;
  int get manualCount =>
      _manuallyConfirmedCountOverride ??
      items.where((i) => i.isManuallyConfirmed).length;

  bool get isComplete => status == 'COMPLETE';

  // part_num + color szerint csoportosítva – változatlan
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
  final double detectionConfidence;
  final String? colorName;

  ScanIdentifyResult({
    required this.partNum,
    required this.confidence,
    required this.detectionConfidence,
    this.colorName,
  });

  factory ScanIdentifyResult.fromJson(Map<String, dynamic> json) {
    return ScanIdentifyResult(
      partNum: json['part_num'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      detectionConfidence: (json['detection_confidence'] as num).toDouble(),
      colorName: json['color_name'] as String?,
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
