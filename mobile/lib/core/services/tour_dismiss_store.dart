abstract class TourDismissStore {
  Future<bool> isDismissed(String tourKey);
  Future<void> markDismissed(String tourKey);
}