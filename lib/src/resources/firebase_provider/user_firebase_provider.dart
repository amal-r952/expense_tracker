import 'dart:io';

import 'package:expense_tracker/src/models/user_response_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/state.dart';
import '../../utils/object_factory.dart';

class UserFirebaseProvider {
  Future<State?> signInWithGoogle() async {
    final UserCredential? userCredential =
        await ObjectFactory().firebaseClient.signInWithGoogle();
    if (userCredential != null) {
      return State.success(userCredential);
    } else {
      return null;
    }
  }
  Future<State?> addUserDataToFirebase({required String userId}) async {
    final UserResponseModel? userResponseModel =
        await ObjectFactory().firebaseClient.addUserDataToFirebase(userId: userId);
    if (userResponseModel != null) {
      return State.success(userResponseModel);
    } else {
      return null;
    }
  }

    Future<State?> uploadImage(
      {required String folderName, required File imageFile}) async {
    final String response = await ObjectFactory()
        .firebaseClient
        .uploadImage(imageFile: imageFile, folderName: folderName);

    if (response != "") {
      return State.success(response);
    } else {
      return null;
    }
  }
}
