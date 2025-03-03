
import 'dart:async';

import 'package:expense_tracker/src/bloc/base_bloc.dart';
import 'package:expense_tracker/src/models/currency_rate_model.dart';
import 'package:expense_tracker/src/models/state.dart';
import 'package:expense_tracker/src/utils/constants.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/utils/validators.dart';

class CurrencyBloc extends Object with Validators implements BaseBloc {
  final StreamController<bool> _loading = StreamController<bool>.broadcast();

  final StreamController<CurrencyRateModel> _fetchCurrencyRates =
      StreamController<CurrencyRateModel>.broadcast();

  /// stream for progress bar
  Stream<bool> get loadingListener => _loading.stream;
  Stream<CurrencyRateModel> get fetchCurrencyRatesResponse => _fetchCurrencyRates.stream;

  /// stream sink

  StreamSink<bool> get loadingSink => _loading.sink;
  StreamSink<CurrencyRateModel> get fetchCurrencyRatesSink => _fetchCurrencyRates.sink;

  /// fetching currency rates

  fetchCurrencyRates({required String currencyCode}) async {
    State? state = await ObjectFactory().repository.getCurrencyRates(currencyCode: currencyCode);
    if (state is SuccessState) {
      fetchCurrencyRatesSink.add(state.value);
    } else if (state is ErrorState) {
      fetchCurrencyRatesSink.addError(Constants.SOME_ERROR_OCCURRED);
    }
  }

  ///disposing the stream if it is not using
  @override
  void dispose() {
    _loading.close();
    _fetchCurrencyRates.close();
  }
}
