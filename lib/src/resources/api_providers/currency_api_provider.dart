import 'package:expense_tracker/src/models/currency_rate_model.dart';
import 'package:expense_tracker/src/models/state.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';

class CurrencyApiProvider {

    Future<State> getCurrencyRates({required String currencyCode}
      ) async {
    final response = await ObjectFactory()
        .apiClient
        .getCurrencyRates(currencyCode: currencyCode);
  
    if (response.statusCode == 200) {
      return State<CurrencyRateModel>.success(
          CurrencyRateModel.fromJson(response.data));
    } else {
      return State.error("Getting currency conversion data failed!");
    }
  }
}