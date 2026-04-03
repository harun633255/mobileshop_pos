import 'package:get/get.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/memo_model.dart';

class HomeController extends GetxController {
  final _db = DatabaseHelper();

  final currentTabIndex = 0.obs;
  final totalParts = 0.obs;
  final todayMemos = 0.obs;
  final monthMemos = 0.obs;
  final recentMemos = <MemoModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _db.getPartsCount(),
        _db.getTodayMemosCount(),
        _db.getMonthMemosCount(),
        _db.getRecentMemos(limit: 5),
      ]);
      totalParts.value = results[0] as int;
      todayMemos.value = results[1] as int;
      monthMemos.value = results[2] as int;
      recentMemos.value = results[3] as List<MemoModel>;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
    if (index == 0) loadDashboard();
  }
}
