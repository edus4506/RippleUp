import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/models/social/participation.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/data/repositories/social/participation_repository.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/viewModels/events/participants_view_model.dart';

class MockParticipationRepository extends Mock
    implements ParticipationRepository {}

class MockUserRepository extends Mock implements UserRepository {}

Users _user(String id, String name) =>
    Users(uid: id, name: name, email: '$name@test.com', profilePictureUrl: '');

void main() {
  late MockParticipationRepository mockParticipationRepo;
  late MockUserRepository mockUserRepo;
  late ParticipantsViewModel vm;

  setUp(() {
    mockParticipationRepo = MockParticipationRepository();
    mockUserRepo = MockUserRepository();
    vm = ParticipantsViewModel(mockParticipationRepo, mockUserRepo);
  });

  group('ParticipantsViewModel initial state', () {
    test('isLoading starts false', () {
      expect(vm.isLoading, false);
    });

    test('errorMessage starts null', () {
      expect(vm.errorMessage, isNull);
    });
  });

  group('ParticipantsViewModel.getEventParticipants', () {
    test('returns list of users for event participations', () async {
      when(
        () => mockParticipationRepo.getParticipationsByEvent('e1'),
      ).thenAnswer(
        (_) async => [
          Participation(id: 'p1', idUser: 'u1', idEvent: 'e1'),
          Participation(id: 'p2', idUser: 'u2', idEvent: 'e1'),
        ],
      );
      when(
        () => mockUserRepo.getUser('u1'),
      ).thenAnswer((_) async => _user('u1', 'Alice'));
      when(
        () => mockUserRepo.getUser('u2'),
      ).thenAnswer((_) async => _user('u2', 'Bob'));

      final result = await vm.getEventParticipants('e1');

      expect(result.length, 2);
      expect(result.map((u) => u.name), containsAll(['Alice', 'Bob']));
    });

    test('returns empty list when event has no participations', () async {
      when(
        () => mockParticipationRepo.getParticipationsByEvent('e1'),
      ).thenAnswer((_) async => []);

      final result = await vm.getEventParticipants('e1');

      expect(result, isEmpty);
    });

    test('skips users that return null from repository', () async {
      when(
        () => mockParticipationRepo.getParticipationsByEvent('e1'),
      ).thenAnswer(
        (_) async => [
          Participation(id: 'p1', idUser: 'u1', idEvent: 'e1'),
          Participation(id: 'p2', idUser: 'missing', idEvent: 'e1'),
        ],
      );
      when(
        () => mockUserRepo.getUser('u1'),
      ).thenAnswer((_) async => _user('u1', 'Alice'));
      when(() => mockUserRepo.getUser('missing')).thenAnswer((_) async => null);

      final result = await vm.getEventParticipants('e1');

      expect(result.length, 1);
      expect(result.first.name, 'Alice');
    });

    test(
      'sets errorMessage and returns empty list when repository throws',
      () async {
        when(
          () => mockParticipationRepo.getParticipationsByEvent(any()),
        ).thenThrow(Exception('network error'));

        final result = await vm.getEventParticipants('e1');

        expect(result, isEmpty);
        expect(vm.errorMessage, isNotNull);
      },
    );

    test('isLoading is false after successful load', () async {
      when(
        () => mockParticipationRepo.getParticipationsByEvent('e1'),
      ).thenAnswer((_) async => []);

      await vm.getEventParticipants('e1');

      expect(vm.isLoading, false);
    });

    test('isLoading is false even after error', () async {
      when(
        () => mockParticipationRepo.getParticipationsByEvent(any()),
      ).thenThrow(Exception('fail'));

      await vm.getEventParticipants('e1');

      expect(vm.isLoading, false);
    });

    test('notifies listeners during and after load', () async {
      when(
        () => mockParticipationRepo.getParticipationsByEvent('e1'),
      ).thenAnswer((_) async => []);

      int notifyCount = 0;
      vm.addListener(() => notifyCount++);

      await vm.getEventParticipants('e1');

      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });

  group('ParticipantsViewModel.streamEventParticipants', () {
    test('emits list of users from stream', () async {
      when(
        () => mockParticipationRepo.listenToEventParticipations('e1'),
      ).thenAnswer(
        (_) => Stream.value([
          Participation(id: 'p1', idUser: 'u1', idEvent: 'e1'),
        ]),
      );
      when(
        () => mockUserRepo.getUser('u1'),
      ).thenAnswer((_) async => _user('u1', 'Alice'));

      final result = await vm.streamEventParticipants('e1').first;

      expect(result.length, 1);
      expect(result.first.name, 'Alice');
    });

    test('emits empty list when no participations exist', () async {
      when(
        () => mockParticipationRepo.listenToEventParticipations('e1'),
      ).thenAnswer((_) => Stream.value([]));

      final result = await vm.streamEventParticipants('e1').first;

      expect(result, isEmpty);
    });
  });
}
