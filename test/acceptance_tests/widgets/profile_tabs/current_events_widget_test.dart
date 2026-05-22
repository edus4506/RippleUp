/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/events/favorite_event.dart';
import 'package:t5/data/models/social/participation.dart';
import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/data/repositories/events/favorite_event_repository.dart';
import 'package:t5/data/repositories/social/participation_repository.dart';
import 'package:t5/services/storage/storage_service.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/viewModels/authenthication/auth_viewModel.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/viewModels/events/favorite_event_viewModel.dart';
import 'package:t5/viewModels/social/user_view_model.dart';
import 'package:t5/views/widgets/profile_tabs/current_events_widget.dart';

import 'dart:io';
import 'dart:typed_data';

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

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockFirebaseUser extends Mock implements User {}

class MockUserRepository extends Mock implements UserRepository {}

class FakeParticipationRepository implements ParticipationRepository {
  final List<Participation> participations;
  FakeParticipationRepository(this.participations);

  @override
  Future<List<Participation>> getParticipationsByUser(String userId) async {
    return [
      Participation(id: 'mockId', idUser: 'mockIdUser', idEvent: 'mockIdEvent'),
    ];
  }

  @override
  Future<List<Participation>> getParticipationsByEvent(String idEvent) async {
    return [
      Participation(id: 'mockId', idUser: 'mockIdUser', idEvent: 'mockIdEvent'),
    ];
  }

  @override
  Stream<List<Participation>> listenToUserParticipations(String userId) =>
      Stream.value(participations);

  @override
  Stream<List<Participation>> listenToEventParticipations(String eventId) =>
      Stream.value(participations);

  @override
  Future<bool> hasUserParticipated(String userId, String eventId) async =>
      participations.any((p) => p.idUser == userId && p.idEvent == eventId);
}

class FakeEventRepository implements EventRepository {
  final List<Event> events;
  FakeEventRepository(this.events);

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
  Stream<List<Event>> listenToEvents() => Stream.value(events);
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
  }) => Stream.value(false);

  @override
  Future<void> updateEvent(Event event) async {}
}

class FakeFavoriteRepository implements FavoriteRepository {
  @override
  Stream<bool> isEventFavorited({
    required String userId,
    required String eventId,
  }) => Stream.value(false);
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
  Stream<List<Favorite>> listenToUserFavorites(String userId) =>
      Stream.value([]);
}

Event buildEvent({
  required String id,
  required String title,
  required DateTime startDate,
}) {
  return Event(
    id: id,
    imageUrls: [],
    title: title,
    description: 'desc',
    createdAt: DateTime.now(),
    startDate: startDate,
    endDate: startDate.add(const Duration(hours: 2)),
    maxUsers: 10,
    currentUsers: 1,
    idCreator: 'creator-1',
    country: 'Portugal',
    district: 'Porto',
    city: 'Porto',
    objectives: [1],
  );
}

Widget buildTestable({
  required AuthViewModel auth,
  required ParticipationRepository participationRepo,
  required EventRepository eventRepo,
}) {
  final userRepo = MockUserRepository();
  when(
    () => userRepo.listenToUser(any()),
  ).thenAnswer((_) => const Stream.empty());

  final stRepo = FakeStorageRepository();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: auth),
      Provider<ParticipationRepository>.value(value: participationRepo),
      ChangeNotifierProvider(create: (_) => EventViewModel(eventRepo, stRepo)),
      ChangeNotifierProvider(
        create: (_) => FavoriteViewModel(FakeFavoriteRepository()),
      ),
      ChangeNotifierProvider(create: (_) => UserViewModel(userRepo)),
    ],
    child: const MaterialApp(home: Scaffold(body: CurrentEventsWidget())),
  );
}
*/
void main() {
  /*
  late MockAuthViewModel authVm;
  late MockFirebaseUser firebaseUser;

  setUp(() {
    authVm = MockAuthViewModel();
    firebaseUser = MockFirebaseUser();

    when(() => authVm.addListener(any())).thenAnswer((_) {});
    when(() => authVm.removeListener(any())).thenAnswer((_) {});
    when(() => authVm.currentUser).thenReturn(firebaseUser);
    when(() => firebaseUser.uid).thenReturn('user-1');
  });

  testWidgets('shows empty message when user has no joined events', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestable(
        auth: authVm,
        participationRepo: FakeParticipationRepository([]),
        eventRepo: FakeEventRepository([]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('You have not joined any events yet.'), findsOneWidget);
  });

  testWidgets('shows joined events sorted by startDate', (tester) async {
    final now = DateTime.now();

    final event1 = buildEvent(
      id: 'e1',
      title: 'Later Event',
      startDate: now.add(const Duration(days: 5)),
    );
    final event2 = buildEvent(
      id: 'e2',
      title: 'Earlier Event',
      startDate: now.add(const Duration(days: 1)),
    );

    final participations = [
      Participation(id: 'e1_user-1', idUser: 'user-1', idEvent: 'e1'),
      Participation(id: 'e2_user-1', idUser: 'user-1', idEvent: 'e2'),
    ];

    await tester.pumpWidget(
      buildTestable(
        auth: authVm,
        participationRepo: FakeParticipationRepository(participations),
        eventRepo: FakeEventRepository([event1, event2]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Earlier Event'), findsOneWidget);
    expect(find.text('Later Event'), findsOneWidget);

    final earlier = tester.getTopLeft(find.text('Earlier Event'));
    final later = tester.getTopLeft(find.text('Later Event'));
    expect(earlier.dy, lessThan(later.dy));
  });

  testWidgets('does not show events the user has not joined', (tester) async {
    final now = DateTime.now();

    final joinedEvent = buildEvent(
      id: 'e1',
      title: 'My Event',
      startDate: now.add(const Duration(days: 1)),
    );
    final otherEvent = buildEvent(
      id: 'e2',
      title: 'Other Event',
      startDate: now.add(const Duration(days: 2)),
    );

    final participations = [
      Participation(id: 'e1_user-1', idUser: 'user-1', idEvent: 'e1'),
    ];

    await tester.pumpWidget(
      buildTestable(
        auth: authVm,
        participationRepo: FakeParticipationRepository(participations),
        eventRepo: FakeEventRepository([joinedEvent, otherEvent]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My Event'), findsOneWidget);
    expect(find.text('Other Event'), findsNothing);
  });*/
}
