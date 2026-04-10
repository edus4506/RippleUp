import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRepository {
  final _client = Supabase.instance.client;

  Future<String> uploadProfileImage({
    required String userId,
    required File file,
  }) async {
    final path = 'profile-images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg'; //stay like this because with the same url, the cache will be used

    await _client.storage
        .from('profile-images')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = _client.storage
        .from('profile-images')
        .getPublicUrl(path);

    return publicUrl;
  }

  //suports from web too
  Future<String> uploadProfileImageWeb({
    required String userId,
    required Uint8List bytes,
  }) async {
    final path = 'profile-images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _client.storage
        .from('profile-images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('profile-images').getPublicUrl(path);
  }
}