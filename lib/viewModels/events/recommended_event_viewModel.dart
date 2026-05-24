import 'package:flutter/foundation.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/repositories/events/recommended_event_repository.dart';

class RecommendedEventViewModel extends ChangeNotifier {
  final RecommendedEventRepository _repository;
  final String currentUserId;

  RecommendedEventViewModel({
    required this.currentUserId,
    required RecommendedEventRepository repository,
  }) : _repository = repository;

  List<Event> _recommendedEvents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get recommendedEvents => _recommendedEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasNoData => !_isLoading && _recommendedEvents.isEmpty;

  /// Carrega eventos recomendados
  Future<void> loadRecommendedEvents({
    int limit = 10,  // ← Muda de 10 para 15 ou 20
    int maxAttempts = 3,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendedEvents = await _repository.getRecommendedEvents(
        currentUserId: currentUserId,
        limit: limit,
        maxAttempts: maxAttempts,
      );

      if (_recommendedEvents.isEmpty) {
        _errorMessage = 'No recommended events found';
      }
    } catch (e) {
      _errorMessage = 'Error loading recommended events: $e';
      _recommendedEvents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recarrega eventos recomendados (novo random user)
  Future<void> refreshRecommendations({
    int limit = 10,
    int maxAttempts = 3,
  }) async {
    _recommendedEvents = [];
    _errorMessage = null;
    await loadRecommendedEvents(limit: limit, maxAttempts: maxAttempts);
  }

  /// Limpa o estado
  void clear() {
    _recommendedEvents = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}