import '../models/archive_model.dart';
import '../network/api_service.dart';

class ArchiveService {
  final ApiService _apiService;

  ArchiveService(this._apiService);

  Future<List<ArchiveModel>> fetchArchives() async {
    final response = await _apiService.client.get('/archives');
    final List<dynamic> data = response.data['archives'] ?? [];
    return data.map((e) => ArchiveModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markPrinted(int archiveId) async {
    await _apiService.client.patch('/archives/$archiveId/printed');
  }
}
