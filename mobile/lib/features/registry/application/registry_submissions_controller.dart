import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/marketplace_api.dart';
import '../../auth/application/account_controller.dart';
import '../data/registry_submission.dart';

class RegistrySubmissionsController
    extends AsyncNotifier<List<RegistrySubmission>> {
  @override
  Future<List<RegistrySubmission>> build() async {
    if (ref.watch(accountControllerProvider) == null) {
      return const [];
    }
    return _fetch();
  }

  Future<List<RegistrySubmission>> _fetch() async {
    try {
      final rows = await MarketplaceApi().registrySubmissions();
      return [for (final row in rows) RegistrySubmission.fromJson(row)];
    } on ApiException catch (error) {
      if (error.status == 401) {
        return const [];
      }
      rethrow;
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<RegistrySubmission> submit({
    required String companyType,
    required String companyName,
    String? cin,
    required String directorContact,
    required String directorEmail,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    final created = await MarketplaceApi().createRegistrySubmission(
      companyType: companyType,
      companyName: companyName,
      cin: cin,
      directorContact: directorContact,
      directorEmail: directorEmail,
      location: location,
      latitude: latitude,
      longitude: longitude,
    );
    await reload();
    return RegistrySubmission.fromJson(created);
  }
}

final registrySubmissionsProvider =
    AsyncNotifierProvider<
      RegistrySubmissionsController,
      List<RegistrySubmission>
    >(RegistrySubmissionsController.new);
