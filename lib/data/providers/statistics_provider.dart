import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pet_statistics.dart';
import '../repositories/care_log_repository.dart';

/// Provider that computes statistics from care logs for a given pet
final petStatisticsProvider = Provider.family<AsyncValue<PetStatistics>, String>((ref, petId) {
  final logsAsync = ref.watch(petLogsProvider(petId));
  
  return logsAsync.when(
    data: (logs) => AsyncValue.data(PetStatistics.fromLogs(logs)),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
