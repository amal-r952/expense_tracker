import 'dart:async';

import 'package:expense_tracker/src/resources/repository/repository.dart';

import 'api_client.dart';
import 'hive.dart';

class ObjectFactory {
  static final _objectFactory = ObjectFactory._internal();

  ObjectFactory._internal();

  factory ObjectFactory() => _objectFactory;

  ///Initialisation of Objects
  AppHive _appHive = AppHive();
  ApiClient _apiClient = ApiClient();
  Repository _repository = Repository();

  ///
  /// Getters of Objects
  ///
  ApiClient get apiClient => _apiClient;

  AppHive get appHive => _appHive;

  Repository get repository => _repository;
}
