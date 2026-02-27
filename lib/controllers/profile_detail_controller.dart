import 'package:get/get.dart';
import 'package:superapp/modal/time_line_modal.dart';

enum JobStage { completed, planning }

class PhotoDetailsController extends GetxController {
  // Job Info
  final jobTitle = 'Unit 4B  -  Leak Repair'.obs;
  final community = 'Maple Heights'.obs;
  final assignedTech = 'Mike R.'.obs;

  // Stage pills
  final stage = JobStage.completed.obs;

  // Photos
  final beforePhotoUrl = ''.obs; // empty => placeholder
  final afterPhotoUrl = ''.obs;

  // Timeline
  final timeline = <TimeLineModal>[].obs;

  // Loading flags
  final isApproving = false.obs;
  final isRejecting = false.obs;

  @override
  void onInit() {
    super.onInit();

    timeline.assignAll([
      TimeLineModal(
        title: 'Photos uploaded',
        timeAgo: '1h ago',
        isActive: true,
      ),
      TimeLineModal(title: 'Job in progress', timeAgo: '2h ago'),
    ]);
  }

  Future<void> approve() async {
    if (isApproving.value) return;
    isApproving.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 700));
      Get.snackbar('Approve', 'Photos approved successfully');
    } finally {
      isApproving.value = false;
    }
  }

  Future<void> reject() async {
    if (isRejecting.value) return;
    isRejecting.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 700));
      Get.snackbar('Reject', 'Photos rejected');
    } finally {
      isRejecting.value = false;
    }
  }
}
