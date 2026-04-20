import 'package:flutter/material.dart';
import 'package:t5/data/models/favorite_userEvent.dart';
import 'package:t5/data/repositories/favorite_repository.dart';

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository;

  FavoriteViewModel(this._favoriteRepository);

  bool isLoading = false;
  String? errorMessage;

  Stream<List<Favorite>> userFavoritesStream(String userId) {
    return _favoriteRepository.listenToUserFavorites(userId);
  }

  Stream<bool> isEventFavorited({
    required String userId,
    required String eventId,
  }) {
    return _favoriteRepository.isEventFavorited(
      userId: userId,
      eventId: eventId,
    );
  }

  Future<bool> addFavorite({
    required String userId,
    required String eventId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _favoriteRepository.addFavorite(
        userId: userId,
        eventId: eventId,
      );

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeFavorite({
    required String userId,
    required String eventId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _favoriteRepository.removeFavorite(
        userId: userId,
        eventId: eventId,
      );

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}