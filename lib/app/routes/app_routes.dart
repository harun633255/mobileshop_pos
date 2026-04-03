import 'package:get/get.dart';
import '../modules/home/home_controller.dart';
import '../modules/home/home_view.dart';
import '../modules/parts/parts_controller.dart';
import '../modules/parts/add_edit_part_view.dart';
import '../modules/memo/memo_controller.dart';
import '../modules/memo/create_memo_view.dart';
import '../modules/memo/memo_preview_view.dart';
import '../modules/customers/customer_controller.dart';
import '../modules/customers/customer_view.dart';
import '../modules/settings/settings_controller.dart';

abstract class AppRoutes {
  static const main = '/';
  static const addPart = '/add-part';
  static const editPart = '/edit-part';
  static const createMemo = '/create-memo';
  static const memoPreview = '/memo-preview';
  static const customers = '/customers';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.main,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
        Get.put(PartsController());
        Get.put(MemoController());
        Get.put(CustomerController());
        Get.put(SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.addPart,
      page: () => const AddEditPartView(),
    ),
    GetPage(
      name: AppRoutes.editPart,
      page: () => const AddEditPartView(),
    ),
    GetPage(
      name: AppRoutes.createMemo,
      page: () => const CreateMemoView(),
    ),
    GetPage(
      name: AppRoutes.memoPreview,
      page: () => const MemoPreviewView(),
    ),
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomerView(),
    ),
  ];
}
