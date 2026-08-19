import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadRequestImage({
    required String requestId,
    required XFile image,
    int index = 1,
  }) async {
    final ref = _storage.ref().child(
          'request_images/$requestId/image_$index.jpg',
        );
    final bytes = await image.readAsBytes();
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}
