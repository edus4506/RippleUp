import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/messages/message.dart';
import 'package:t5/data/models/social/participation.dart';
import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/data/repositories/messages/event_chat_repository.dart';
import 'package:t5/data/repositories/messages/message_repository.dart';
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

Event _buildEvent() {
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
}

void main() {
  late MockMessageRepository mockMessageRepo;
  late MockParticipationRepository mockParticipationRepo;
  late MockEventRepository mockEventRepo;
  late MockEventChatRepository mockEventChatRepo;
  late MessageViewModel vm;
  late MockUser mockUser;

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
    mockUser = MockUser();

    vm = MessageViewModel(
      mockMessageRepo,
      mockParticipationRepo,
      mockEventRepo,
      mockEventChatRepo,
    );
  });

  group('MessageViewModel.getMessages', () {
    test('returns stream from repository', () {
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

      expect(vm.getMessages('e1'), emits(isEmpty));
    });

    test('delegates to repository with correct eventId', () {
      when(
        () => mockMessageRepo.getEventMessages('e1'),
      ).thenAnswer((_) => Stream.value([]));

      vm.getMessages('e1');

      verify(() => mockMessageRepo.getEventMessages('e1')).called(1);
    });
  });

  group('MessageViewModel.sendMessage', () {
    void _setupSendMessage({
      bool isParticipant = true,
      List<Participation> participations = const [],
    }) {
      when(
        () => mockParticipationRepo.hasUserParticipated(any(), any()),
      ).thenAnswer((_) async => isParticipant);

      when(
        () => mockEventRepo.getEventById('e1'),
      ).thenAnswer((_) async => _buildEvent());

      when(
        () => mockParticipationRepo.getParticipationsByEvent('e1'),
      ).thenAnswer((_) async => participations);

      when(
        () => mockMessageRepo.createMessage('e1', any()),
      ).thenAnswer((_) async {});

      when(
        () => mockEventChatRepo.updateEventChatPreview(
          eventId: any(named: 'eventId'),
          eventTitle: any(named: 'eventTitle'),
          message: any(named: 'message'),
          participantIds: any(named: 'participantIds'),
        ),
      ).thenAnswer((_) async {});
    }

    test('creates message when user is a participant', () async {
      _setupSendMessage(
        participations: [
          Participation(id: 'p1', idUser: 'sender-uid', idEvent: 'e1'),
        ],
      );

      await vm.sendMessage('e1', 'hello', currentUser: mockUser);

      verify(() => mockMessageRepo.createMessage('e1', any())).called(1);
    });

    test('does not create message when user is not a participant', () async {
      _setupSendMessage(isParticipant: false);

      await vm.sendMessage('e1', 'hello', currentUser: mockUser);

      verifyNever(() => mockMessageRepo.createMessage(any(), any()));
    });

    test('updates event chat preview after sending', () async {
      _setupSendMessage(
        participations: [
          Participation(id: 'p1', idUser: 'sender-uid', idEvent: 'e1'),
        ],
      );

      await vm.sendMessage('e1', 'hello', currentUser: mockUser);

      verify(
        () => mockEventChatRepo.updateEventChatPreview(
          eventId: 'e1',
          eventTitle: any(named: 'eventTitle'),
          message: any(named: 'message'),
          participantIds: any(named: 'participantIds'),
        ),
      ).called(1);
    });
  });
}
