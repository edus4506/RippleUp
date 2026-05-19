import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/models/favorite_userEvent.dart';
import 'package:t5/data/repositories/favorite_repository.dart';
import 'package:t5/viewModels/favorite_view_model.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late MockFavoriteRepository mockRepo;
  late FavoriteViewModel viewModel;

  setUp(() {
    mockRepo = MockFavoriteRepository();
    viewModel = FavoriteViewModel(mockRepo);
  });

  group('FavoriteViewModel.addFavorite', () {
    test('returns true when repository succeeds', () async {
      when(
        () => mockRepo.addFavorite(userId: 'u1', eventId: 'e1'),
      ).thenAnswer((_) async {});

      final result = await viewModel.addFavorite(userId: 'u1', eventId: 'e1');

      expect(result, true);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, false);
    });

    test(
      'returns false and sets errorMessage when repository throws',
      () async {
        when(
          () => mockRepo.addFavorite(userId: 'u1', eventId: 'e1'),
        ).thenThrow(Exception('Already favorited'));

        final result = await viewModel.addFavorite(userId: 'u1', eventId: 'e1');

        expect(result, false);
        expect(viewModel.errorMessage, 'Already favorited');
        expect(viewModel.isLoading, false);
      },
    );
  });

  group('FavoriteViewModel.removeFavorite', () {
    test('returns true when repository succeeds', () async {
      when(
        () => mockRepo.removeFavorite(userId: 'u1', eventId: 'e1'),
      ).thenAnswer((_) async {});

      final result = await viewModel.removeFavorite(
        userId: 'u1',
        eventId: 'e1',
      );

      expect(result, true);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, false);
    });

    test(
      'returns false and sets errorMessage when repository throws',
      () async {
        when(
          () => mockRepo.removeFavorite(userId: 'u1', eventId: 'e1'),
        ).thenThrow(Exception('Not found'));

        final result = await viewModel.removeFavorite(
          userId: 'u1',
          eventId: 'e1',
        );

        expect(result, false);
        expect(viewModel.errorMessage, 'Not found');
        expect(viewModel.isLoading, false);
      },
    );
  });

  group('FavoriteViewModel.isEventFavorited', () {
    test('emits true when event is favorited', () async {
      when(
        () => mockRepo.isEventFavorited(userId: 'u1', eventId: 'e1'),
      ).thenAnswer((_) => Stream.value(true));

      final result = await viewModel
          .isEventFavorited(userId: 'u1', eventId: 'e1')
          .first;

      expect(result, true);
    });

    test('emits false when event is not favorited', () async {
      when(
        () => mockRepo.isEventFavorited(userId: 'u1', eventId: 'e1'),
      ).thenAnswer((_) => Stream.value(false));

      final result = await viewModel
          .isEventFavorited(userId: 'u1', eventId: 'e1')
          .first;

      expect(result, false);
    });
  });

  group('FavoriteViewModel.userFavoritesStream', () {
    test('returns favorites list from repository', () async {
      final favorites = [
        Favorite(id: 'f1', idUser: 'u1', idEvent: 'e1'),
      ];
      when(
        () => mockRepo.listenToUserFavorites('u1'),
      ).thenAnswer((_) => Stream.value(favorites));

      final result = await viewModel.userFavoritesStream('u1').first;

      expect(result.length, 1);
      expect(result.first.idEvent, 'e1');
    });

    test('returns empty stream when user has no favorites', () async {
      when(
        () => mockRepo.listenToUserFavorites('u1'),
      ).thenAnswer((_) => Stream.value([]));

      final result = await viewModel.userFavoritesStream('u1').first;

      expect(result, isEmpty);
    });
  });
}
