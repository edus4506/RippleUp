import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/viewModels/message_viewModel.dart';
import 'package:t5/data/repositories/message_repository.dart';
import 'package:t5/data/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockMessageRepository extends Mock implements MessageRepository {}
class MockUser extends Mock implements User {}

// 1. Criamos um "Fake" ou usamos uma instância real para o Fallback
class MessageFake extends Fake implements Message {}

void main() {
  late MessageViewModel viewModel;
  late MockMessageRepository mockRepo;

  // 2. Registamos o fallback antes de qualquer teste correr
  setUpAll(() {
    registerFallbackValue(MessageFake());
  });

  setUp(() {
    mockRepo = MockMessageRepository();
    viewModel = MessageViewModel(mockRepo);
  });

  test('Deve chamar createMessage com os dados corretos', () async {
    final mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('user123');
    
    // Agora o any() já sabe como se comportar para o tipo Message
    when(() => mockRepo.createMessage(any(), any()))
        .thenAnswer((_) async => {});

    await viewModel.sendMessage('eventA', 'Olá!', currentUser: mockUser);

    verify(() => mockRepo.createMessage('eventA', any())).called(1);
  });
}