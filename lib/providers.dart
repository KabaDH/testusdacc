import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerWalletBallance =
    StateNotifierProvider<WalletBalanceController, String>(
        (ref) => WalletBalanceController());

class WalletBalanceController extends StateNotifier<String> {
  WalletBalanceController() : super('180.970.83');
}

final providerTransactionsList = StateNotifierProvider<
    TransactionsListController,
    AsyncValue<List<List<dynamic>>>>((ref) => TransactionsListController());

class TransactionsListController
    extends StateNotifier<AsyncValue<List<List<dynamic>>>> {
  TransactionsListController() : super(const AsyncValue.loading()) {
    initList();
  }

  final _yesterday = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day - 1, 12, 23);

  initList() async {
    //пока данные не прогрузились
    state = const AsyncValue.loading();
    //когда загрузились
    if (mounted) {
      try {
        //TransactionID, DateTime, ClientName, Sum, Currency
        final list = [
          [212332, _yesterday, 'Pret A Manger', -55.31, 'USD'],
          [212333, _yesterday, 'Darren Hodgkin', 130.31, 'USD'],
          [212334, _yesterday, 'McDonalds', -55.31, 'USD'],
          [212335, _yesterday, 'Starbucks', -55.31, 'USD'],
          [212336, _yesterday, 'Dave Winklevoss', -300.00, 'USD'],
          [
            212337,
            DateTime(DateTime.now().year - 1, 12, 11, 12, 23),
            'Virgin Megastore',
            -500.31,
            'USD'
          ],
          [
            212338,
            DateTime(DateTime.now().year - 1, 12, 11, 12, 23),
            'Nike',
            -500.31,
            'USD'
          ],
          [
            212339,
            DateTime(DateTime.now().year - 1, 12, 09, 12, 23),
            'Louis Vuitton',
            -500.31,
            'USD'
          ],
          [
            212340,
            DateTime(DateTime.now().year - 1, 12, 09, 12, 23),
            'Carrefour',
            -500.31,
            'USD'
          ],
        ];
        Future.delayed(const Duration(seconds: 2), () {
          state = AsyncValue.data(list);
        });
      } on Exception catch (e) {
        throw e.toString();
      }
    }
  }
}
