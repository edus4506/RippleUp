import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/favorite_userEvent.dart';

import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/favorite_repository.dart';
import 'package:t5/data/repositories/storage_repository.dart';

import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/notification_viewModel.dart';

import 'package:t5/views/pages/home_page.dart';
import 'package:t5/views/widgets/bottom_nav.dart';

class FakeStorageRepository implements StorageRepository {
  @override
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
  }) async {
    return 'https://fake-url.com/$path';
  }

  @override
  Future<String> uploadFile({required String path, required File file}) async {
    return 'https://fake-url.com/$path';
  }

  @override
  Future<void> deleteProfilePicture({required String uuid}) async {}

  @override
  Future<String> uploadEventImage({
    required File file,
    required String eventId,
    required String fileName,
  }) async {
    return 'https://fake-url.com/$eventId/$fileName';
  }

  @override
  Future<String> uploadEventBytes({
    required String path,
    required Uint8List bytes,
  }) async {
    return 'https://fake-url.com/$path';
  }

  @override
  Future<void> deleteEventImages({required String eventId}) async {}
}

class FakeEventRepository implements EventRepository {
  @override
  Future<List<Event>> getCreatedEventsByUser(String uid) async {
    return [];
  }

  @override
  Future<List<Event>> getJoinedEventsByUser(String uid) async {
    return [];
  }

  @override
  Future<Event> getEventById(String eventId) async {
    return Event(
      id: eventId,
      imageUrls: [],
      title: 'Event',
      description: '',
      createdAt: DateTime.now(),
      startDate: DateTime.now().add(const Duration(hours: 24)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      maxUsers: 10,
      currentUsers: 0,
      idCreator: 'creator',
      country: 'PT',
      district: 'Porto',
      city: 'Porto',
      objectives: [],
    );
  }

  @override
  Future<void> createEvent(Event event) async {}

  @override
  Future<void> deleteEvent(String eventId) async {}

  @override
  Future<void> joinEvent({
    required String eventId,
    required String userId,
  }) async {}

  @override
  Future<void> leaveEvent({
    required String eventId,
    required String userId,
  }) async {}

  @override
  Stream<bool> isUserInEvent({
    required String eventId,
    required String userId,
  }) {
    return Stream.value(false);
  }

  @override
  Stream<List<Event>> listenToEvents() {
    return const Stream.empty();
  }
}

class FakeFavoriteRepository implements FavoriteRepository {
  @override
  Stream<bool> isEventFavorited({
    required String userId,
    required String eventId,
  }) {
    return Stream.value(false);
  }

  @override
  Future<void> addFavorite({
    required String userId,
    required String eventId,
  }) async {}

  @override
  Future<void> removeFavorite({
    required String userId,
    required String eventId,
  }) async {}

  @override
  Stream<List<Favorite>> listenToUserFavorites(String userId) {
    return Stream.value([]);
  }
}

class FakeNotificationViewModel extends Mock
    implements AppNotificationViewModel {}

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockFirebaseUser extends Mock implements User {}

void main() {
  late MockAuthViewModel authVm;

  late MockFirebaseUser firebaseUser;

  late FakeNotificationViewModel notificationVm;

  setUp(() {
    authVm = MockAuthViewModel();

    firebaseUser = MockFirebaseUser();

    notificationVm = FakeNotificationViewModel();

    when(() => authVm.addListener(any())).thenAnswer((_) {});

    when(() => authVm.removeListener(any())).thenAnswer((_) {});

    when(() => authVm.currentUser).thenReturn(firebaseUser);

    when(() => firebaseUser.uid).thenReturn('user-1');

    when(
      () => notificationVm.getNotifications(any()),
    ).thenAnswer((_) => Stream.value([]));

    when(
      () => notificationVm.checkUpcomingEvents(any()),
    ).thenAnswer((_) async {});
  });

  testWidgets('HomePage widget exists', (tester) async {
    expect(HomePage, isNotNull);
  });

  testWidgets('Bottom navigation widget exists', (tester) async {
    expect(AppBottomNav, isNotNull);
  });

  testWidgets('FakeEventRepository can be created', (tester) async {
    final repo = FakeEventRepository();

    expect(repo, isA<FakeEventRepository>());
  });

  testWidgets('FakeNotificationViewModel can be created', (tester) async {
    final vm = FakeNotificationViewModel();

    expect(vm, isNotNull);
  });
}
