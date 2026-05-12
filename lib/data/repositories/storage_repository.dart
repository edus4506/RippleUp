import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRepository {
  final _client = Supabase.instance.client;

  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
  }) async {
    await _client.storage
        .from('profile-images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('profile-images').getPublicUrl(path);
  }

  Future<String> uploadFile({
    required String path,
    required File file,
  }) async {
    await _client.storage
        .from('profile-images')
        .upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('profile-images').getPublicUrl(path);
  }

  Future<void> deleteProfilePicture({
    required String uuid,
  }) async {
    final bucket = _client.storage.from('profile-images');

    final folderPath = 'profile-images/$uuid';

    final files = await bucket.list(path: folderPath);

    if (files.isEmpty) return;

    final paths = files
        .map((file) => '$folderPath/${file.name}')
        .toList();

    await bucket.remove(paths);
  }

  Future<String> uploadEventImage({
    required File file,
    required String eventId,
    required String fileName,
  }) async {
    final path = '$eventId/$fileName';

    await _client.storage
        .from('event-images')
        .upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage
        .from('event-images')
        .getPublicUrl(path);
  }

  Future<String> uploadEventBytes({
    required String path,
    required Uint8List bytes,
  }) async {
    await _client.storage
        .from('event-images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage
        .from('event-images')
        .getPublicUrl(path);
  }

  Future<void> deleteEventImages({
    required String eventId,
  }) async {
    final bucket = _client.storage.from('event-images');

    final files = await bucket.list(path: eventId);

    if (files.isEmpty) return;

    final paths = files
        .map((file) => '$eventId/${file.name}')
        .toList();

    await bucket.remove(paths);
  }
}
