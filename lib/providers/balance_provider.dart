import 'package:flutter/foundation.dart';
import '../models/account_info.dart';
import '../models/trade.dart';
import '../models/kline.dart';
import '../services/binance_api_service.dart';

class BalanceProvider extends ChangeNotifier {
  AccountInfo? _accountInfo;
  List<TradeHistory> _tradeHistory = [];
  List<TickerPrice> _prices = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdate;

  AccountInfo? get accountInfo => _accountInfo;
  List<TradeHistory> get tradeHistory => _tradeHistory;
  List<TickerPrice> get prices => _prices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;

  List<Balance> get nonZeroBalances {
    if (_accountInfo == null) return [];
    return _accountInfo!.balances
        .where((balance) => balance.totalAmount > 0)
        .toList();
  }

  double getTotalBalanceInUSDT() {
    if (_accountInfo == null || _prices.isEmpty) return 0.0;
    
    double total = 0.0;
    for (final balance in nonZeroBalances) {
      if (balance.asset == 'USDT') {
        total += balance.totalAmount;
      } else {
        final priceSymbol = '${balance.asset}USDT';
        final price = _prices.firstWhere(
          (p) => p.symbol == priceSymbol,
          orElse: () => TickerPrice(symbol: priceSymbol, price: '0'),
        );
        total += balance.totalAmount * price.priceValue;
      }
    }
    return total;
  }

  Future<void> refreshAccountInfo(BinanceApiService apiService) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accountInfo = await apiService.getAccountInfo();
      _lastUpdate = DateTime.now();
    } catch (e) {
      _error = 'Failed to refresh account info: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshPrices(BinanceApiService apiService) async {
    try {
      _prices = await apiService.getAllPrices();
      _lastUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh prices: $e';
      notifyListeners();
    }
  }

  Future<void> refreshTradeHistory(
    BinanceApiService apiService,
    String symbol, {
    int limit = 100,
  }) async {
    try {
      final trades = await apiService.getTradeHistory(symbol, limit: limit);
      _tradeHistory = trades;
      _lastUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh trade history: $e';
      notifyListeners();
    }
  }

  Future<void> refreshAll(BinanceApiService apiService, {String? symbol}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Refresh account info and prices in parallel
      await Future.wait([
        refreshAccountInfo(apiService),
        refreshPrices(apiService),
      ]);

      // Refresh trade history if symbol is provided
      if (symbol != null) {
        await refreshTradeHistory(apiService, symbol);
      }
    } catch (e) {
      _error = 'Failed to refresh data: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  double getAssetBalance(String asset) {
    if (_accountInfo == null) return 0.0;
    
    final balance = _accountInfo!.balances.firstWhere(
      (b) => b.asset == asset,
      orElse: () => Balance(asset: asset, free: '0', locked: '0'),
    );
    
    return balance.totalAmount;
  }

  double getAssetPrice(String asset, {String quote = 'USDT'}) {
    if (asset == quote) return 1.0;
    
    final symbol = '$asset$quote';
    final price = _prices.firstWhere(
      (p) => p.symbol == symbol,
      orElse: () => TickerPrice(symbol: symbol, price: '0'),
    );
    
    return price.priceValue;
  }

  double calculatePnL(TradeHistory trade) {
    if (_prices.isEmpty) return 0.0;
    
    final currentPrice = getAssetPrice(
      trade.symbol.replaceAll('USDT', ''),
      quote: 'USDT',
    );
    
    if (trade.isBuyer) {
      // For buy orders, PnL = (current_price - buy_price) * quantity
      return (currentPrice - trade.priceValue) * trade.quantityValue;
    } else {
      // For sell orders, PnL = (sell_price - current_price) * quantity
      return (trade.priceValue - currentPrice) * trade.quantityValue;
    }
  }

  List<TradeHistory> getTradesForSymbol(String symbol) {
    return _tradeHistory.where((trade) => trade.symbol == symbol).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    _accountInfo = null;
    _tradeHistory.clear();
    _prices.clear();
    _error = null;
    _lastUpdate = null;
    notifyListeners();
  }
}