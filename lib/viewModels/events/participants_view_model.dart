import 'package:flutter/material.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/data/repositories/social/participation_repository.dart';
import 'package:t5/data/repositories/social/user_repository.dart';

class ParticipantsViewModel extends ChangeNotifier {
  final ParticipationRepository _participationRepository;
  final UserRepository _userRepository;

  ParticipantsViewModel(this._participationRepository, this._userRepository);

  bool isLoading = false;
  String? errorMessage;

  /// Get all participants for an event
  Future<List<Users>> getEventParticipants(String eventId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final participations = await _participationRepository
          .getParticipationsByEvent(eventId);
      final participants = <Users>[];

      for (final participation in participations) {
        try {
          final user = await _userRepository.getUser(participation.idUser);
          if (user != null) {
            participants.add(user);
          }
        } catch (e) {
          // Ignora utilizadores com erro e continua
          continue;
        }
      }

      return participants;
    } catch (e) {
      errorMessage = e.toString();
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Get stream of participants for real-time updates
  Stream<List<Users>> streamEventParticipants(String eventId) {
    return _participationRepository
        .listenToEventParticipations(eventId)
        .asyncMap((participations) async {
          final participants = <Users>[];
          for (final participation in participations) {
            try {
              final user = await _userRepository.getUser(participation.idUser);
              if (user != null) {
                participants.add(user);
              }
            } catch (e) {
              continue;
            }
          }
          return participants;
        });
  }
}
