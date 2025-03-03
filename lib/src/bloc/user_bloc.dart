import 'dart:async';
import 'dart:io';

import 'package:expense_tracker/src/bloc/base_bloc.dart';
import 'package:expense_tracker/src/models/state.dart';
import 'package:expense_tracker/src/models/user_response_model.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserBloc extends Object with Validators implements BaseBloc {
  final StreamController<bool> _loading = StreamController<bool>.broadcast();

  final StreamController<UserResponseModel> _addUserDataToFirebase =
      StreamController<UserResponseModel>.broadcast();

  final StreamController<String> _uploadImage =
      StreamController<String>.broadcast();

  /// stream for progress bar
  Stream<bool> get loadingListener => _loading.stream;
  Stream<UserResponseModel> get addUserDataToFirebaseResponse =>
      _addUserDataToFirebase.stream;

  Stream<String> get uploadImageResponse => _uploadImage.stream;

  /// stream sink

  StreamSink<bool> get loadingSink => _loading.sink;
  StreamSink<UserResponseModel> get addUserDataToFirebaseSink =>
      _addUserDataToFirebase.sink;

  StreamSink<String> get uploadImageSink => _uploadImage.sink;

  ///function to add user data to firebase

  addUserDataToFirebase({required String userId}) async {
    loadingSink.add(true);
    State? state =
        await ObjectFactory().repository.addUserDataToFirebase(userId: userId);
    if (state is SuccessState) {
      addUserDataToFirebaseSink.add(state.value);
    } else if (state is ErrorState) {
      addUserDataToFirebaseSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  uploadImage({
    required String folderName,
    required File imageFile,
  }) async {
    loadingSink.add(true);
    State? state = await ObjectFactory().repository.uploadImage(folderName: folderName, imageFile: imageFile);
    if (state is SuccessState) {
      uploadImageSink.add(state.value);
    } else if (state is ErrorState) {
      uploadImageSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  ///disposing the stream if it is not using
  @override
  void dispose() {
    _loading.close();
    _addUserDataToFirebase.close();
    _uploadImage.close();
  }
}
