import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // kIsWeb


class StorageRepository {
  final _client = Supabase.instance.client;

  Future<String> uploadProfileImage({
    required String userId,
    required XFile file,
  }) async {
    final path = 'profile-images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg'; //stay like this because with the same url, the cache will be used

    if(kIsWeb){
      final bytes = await file.readAsBytes();
      await _client.storage
        .from('profile-images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    } else{

      await _client.storage
        .from('profile-images')
        .upload(path, File(file.path), fileOptions: const FileOptions(upsert: true));
    }

    final publicUrl = _client.storage
        .from('profile-images')
        .getPublicUrl(path);

    return publicUrl;
  }

}