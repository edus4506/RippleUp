import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
//import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/messages/message.dart';
//import 'package:t5/data/models/participation.dart';
import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/data/repositories/messages/message_repository.dart';
import 'package:t5/data/repositories/messages/event_chat_repository.dart';
import 'package:t5/data/repositories/social/participation_repository.dart';
import 'package:t5/viewModels/messages/message_viewModel.dart';

class MockMessageRepository extends Mock implements MessageRepository {}

class MockParticipationRepository extends Mock
    implements ParticipationRepository {}

class MockEventRepository extends Mock implements EventRepository {}

class MockEventChatRepository extends Mock implements EventChatRepository {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'sender-uid';
}

/*Event _event() {
  final now = DateTime.now();
  return Event(
    id: 'e1',
    title: 'Test Event',
    description: '',
    createdAt: now,
    startDate: now.add(const Duration(hours: 1)),
    endDate: now.add(const Duration(hours: 2)),
    maxUsers: 10,
    currentUsers: 1,
    idCreator: 'creator',
    objectives: const [],
    country: 'Portugal',
    district: 'Porto',
    city: 'Porto',
    imageUrls: const [],
  );
}*/

void main() {
  late MockMessageRepository mockMessageRepo;
  late MockParticipationRepository mockParticipationRepo;
  late MockEventRepository mockEventRepo;
  late MockEventChatRepository mockEventChatRepo;
  late MessageViewModel vm;
  //late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(
      Message(id: '', senderId: '', text: '', createdAt: DateTime.now()),
    );
  });

  setUp(() {
    mockMessageRepo = MockMessageRepository();
    mockParticipationRepo = MockParticipationRepository();
    mockEventRepo = MockEventRepository();
    mockEventChatRepo = MockEventChatRepository();
    //mockUser = MockUser();

    vm = MessageViewModel(
      mockMessageRepo,
      mockParticipationRepo,
      mockEventRepo,
      mockEventChatRepo,
    );
  });

  group('MessageViewModel.getMessages', () {
    test('delegates to repository stream', () {
      final messages = [
        Message(
          id: 'm1',
          senderId: 'u1',
          text: 'hello',
          createdAt: DateTime.now(),
        ),
      ];
      when(
        () => mockMessageRepo.getEventMessages('e1'),
      ).thenAnswer((_) => Stream.value(messages));

      final stream = vm.getMessages('e1');

      expect(stream, emits(messages));
    });

    test('returns empty list when no messages exist', () {
      when(
        () => mockMessageRepo.getEventMessages('e1'),
      ).thenAnswer((_) => Stream.value([]));

      final stream = vm.getMessages('e1');

      expect(stream, emits(isEmpty));
    });
  });

  /*group('MessageViewModel.sendMessage', () {
   test('creates message when participants include only the sender', () async {
      when(
        () => mockMessageRepo.createMessage('e1', any()),
      ).thenAnswer((_) async {});
      when(
        () => mockParticipationRepo.getParticipationsByEvent('e1'),
      ).thenAnswer(
        (_) async => [
          // only the sender — NotificationService is skipped entirely
          Participation(id: 'p1', idUser: 'sender-uid', idEvent: 'e1'),
        ],
      );
      when(
        () => mockEventRepo.getEventById('e1'),
      ).thenAnswer((_) async => _event());

      await vm.sendMessage('e1', 'hello', currentUser: mockUser);

      verify(() => mockMessageRepo.createMessage('e1', any())).called(1);
    });
  });*/
}
