import 'package:image_picker/image_picker.dart';

class CameraDatasource {
  final ImagePicker _imagePicker;

  CameraDatasource(this._imagePicker);

  /// Captures a photo using the device camera and returns its local file path.
  /// Returns null if the capture is cancelled or fails.
  Future<String?> captureTaskProof() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Compressed for mobile database storage efficiency
      );
      return photo?.path;
    } catch (_) {
      return null;
    }
  }

  /// Selects a photo from the gallery and returns its local file path.
  /// Returns null if the selection is cancelled or fails.
  Future<String?> selectTaskProofFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      return photo?.path;
    } catch (_) {
      return null;
    }
  }
}
