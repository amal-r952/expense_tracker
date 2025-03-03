import 'dart:async';

import 'package:expense_tracker/src/models/state.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'base_bloc.dart';

/// stream data is handled by StreamControllers

class UserAuthBloc extends Object with Validators implements BaseBloc {
  final StreamController<bool> _loading = StreamController<bool>.broadcast();

  final StreamController<UserCredential> _signInWithGoogle =
      StreamController<UserCredential>.broadcast();

  /// stream for progress bar
  Stream<bool> get loadingListener => _loading.stream;
  Stream<UserCredential> get signInWithGoogleResponse => _signInWithGoogle.stream;

  /// stream sink

  StreamSink<bool> get loadingSink => _loading.sink;
  StreamSink<UserCredential> get signInWithGoogleSink => _signInWithGoogle.sink;

  /// login function to get the login response

  signInWithGoogle() async {
    State? state = await ObjectFactory().repository.signInWithGoogle();
    if (state is SuccessState) {
      signInWithGoogleSink.add(state.value);
    } else if (state is ErrorState) {
      signInWithGoogleSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  ///disposing the stream if it is not using
  @override
  void dispose() {
    _loading.close();
    _signInWithGoogle.close();
  }
}
