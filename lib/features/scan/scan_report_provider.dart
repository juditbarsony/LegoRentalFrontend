import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/models/scan_models.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/features/scan/data/scan_repository.dart';
import 'package:lego_rental_frontend/features/scan/scan_providers.dart';

final myReportsProvider = FutureProvider<List<ScanSessionModel>>((ref) async {
  final token = ref.watch(authProvider).accessToken;
  if (token == null) return [];
  final repo = ref.read(scanRepositoryProvider);
  return repo.getMyReports(token: token);
});