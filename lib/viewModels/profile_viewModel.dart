import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t5/data/repositories/storage_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;

  ProfileViewModel(this._userRepository, this._storageRepository);

  Users? user;
  bool isLoading = false;

  Future<void> loadUser() async {
    try {
      isLoading = true;
      notifyListeners();

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) return;

      user = await _userRepository.getUser(firebaseUser.uid);

    } catch (e) {
      print("Erro ProfileVM: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  /*Future<void> uploadProfileImage(XFile pickedFile) async {
    try {
      isLoading = true;
      notifyListeners();

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      String imageUrl = await _storageRepository.uploadProfileImage(userId: firebaseUser.uid, file: pickedFile);

      await _userRepository.updateProfilePicture(
        uid: firebaseUser.uid,
        imageUrl: imageUrl,
      );

      user = await _userRepository.getUser(firebaseUser.uid);

    } catch (e) {
      print("Erro upload: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }*/


  Future<void> softDeleteAcc() async{ 
    //this will set the name and the email to a default value on the firestore
    //it will to eliminate the user account on the firebase auth
    //its profile image will be set to a default image
    
    final firebaseUser = FirebaseAuth.instance.currentUser;

    await _storageRepository.deleteProfilePicture(uuid: firebaseUser!.uid);
    await _userRepository.softDeleteUser(uid: firebaseUser.uid);

  }


  Future<void> updateUserProfile({
    Users? updatedUser,
    XFile? profilePicture,
    String? defaultProfilePictureUrl,
  }) async{

    try {
      isLoading = true;
      notifyListeners();

    final firebaseUser = FirebaseAuth.instance.currentUser;
    Users? currentUser = await _userRepository.getUser(firebaseUser!.uid);

    if(currentUser == null) return;

    if(profilePicture != null){
        currentUser.profilePictureUrl = await _storageRepository.uploadProfileImage(userId: firebaseUser.uid, file: profilePicture);
    }

    if(updatedUser != null){
        //email doesnt change for now, the functuon firebaseUser.verifyBeforeUpdateEmail requests that the user confirms the change on the new email

        /*if(updatedUser.email != currentUser.email){
          firebaseUser.verifyBeforeUpdateEmail(updatedUser.email);
          currentUser.email = updatedUser.email;
        }*/

        if(updatedUser.name != currentUser.name){
          currentUser.name = updatedUser.name;
        }
    }

    user = currentUser;
    await _userRepository.updateUser(uid: firebaseUser.uid, updatedUser: currentUser);
    } catch (e) {
      print("Erro ProfileVM: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }

  }
  
}