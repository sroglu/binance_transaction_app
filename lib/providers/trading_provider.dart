import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trading_strategy.dart';
import '../models/kline.dart';
import '../models/trade.dart';
import '../services/binance_api_service.dart';
import '../services/technical_indicators.dart';

class TradingProvider extends ChangeNotifier {
  final List<TradingStrategy> _strategies = [];
  final List<TradingSignal> _signals = [];
  final List<Trade> _executedTrades = [];
  final Map<String, List<Kline>> _klineData = {};
  
  bool _isMonitoring = false;
  bool _isLoading = false;
  String? _error;
  Timer? _monitoringTimer;
  
  // Trading settings
  bool _enableSpotTrading = true;
  bool _enableFuturesTrading = false;
  double _defaultTradeAmount = 10.0; // USDT
  int _monitoringInterval = 60; // seconds
  
  // Futures trading settings
  double _defaultLeverage = 1.0;
  bool _isolatedMargin = true;

  List<TradingStrategy> get strategies => List.unmodifiable(_strategies);
  List<TradingSignal> get signals => List.unmodifiable(_signals);
  List<Trade> get executedTrades => List.unmodifiable(_executedTrades);
  bool get isMonitoring => _isMonitoring;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get enableSpotTrading => _enableSpotTrading;
  bool get enableFuturesTrading => _enableFuturesTrading;
  double get defaultTradeAmount => _defaultTradeAmount;
  int get monitoringInterval => _monitoringInterval;
  double get defaultLeverage => _defaultLeverage;
  bool get isolatedMargin => _isolatedMargin;

  List<TradingStrategy> get activeStrategies =>
      _strategies.where((s) => s.isActive).toList();

  TradingProvider() {
    _loadSettings();
    _loadStrategies();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enableSpotTrading = prefs.getBool('enable_spot_trading') ?? true;
      _enableFuturesTrading = prefs.getBool('enable_futures_trading') ?? false;
      _defaultTradeAmount = prefs.getDouble('default_trade_amount') ?? 10.0;
      _monitoringInterval = prefs.getInt('monitoring_interval') ?? 60;
      _defaultLeverage = prefs.getDouble('default_leverage') ?? 1.0;
      _isolatedMargin = prefs.getBool('isolated_margin') ?? true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load settings: $e';
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('enable_spot_trading', _enableSpotTrading);
      await prefs.setBool('enable_futures_trading', _enableFuturesTrading);
      await prefs.setDouble('default_trade_amount', _defaultTradeAmount);
      await prefs.setInt('monitoring_interval', _monitoringInterval);
      await prefs.setDouble('default_leverage', _defaultLeverage);
      await prefs.setBool('isolated_margin', _isolatedMargin);
    } catch (e) {
      _error = 'Failed to save settings: $e';
      notifyListeners();
    }
  }

  Future<void> _loadStrategies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final strategiesJson = prefs.getStringList('trading_strategies') ?? [];
      
      _strategies.clear();
      for (final jsonStr in strategiesJson) {
        final strategy = TradingStrategy.fromJson(
          Map<String, dynamic>.from(
            Uri.splitQueryString(jsonStr).map(
              (key, value) => MapEntry(key, Uri.decodeComponent(value)),
            ),
          ),
        );
        _strategies.add(strategy);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load strategies: $e';
      notifyListeners();
    }
  }

  Future<void> _saveStrategies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final strategiesJson = _strategies
          .map((s) => Uri(queryParameters: s.toJson().map(
                (key, value) => MapEntry(key, value.toString()),
              )).query)
          .toList();
      
      await prefs.setStringList('trading_strategies', strategiesJson);
    } catch (e) {
      _error = 'Failed to save strategies: $e';
      notifyListeners();
    }
  }

  void addStrategy(TradingStrategy strategy) {
    _strategies.add(strategy);
    _saveStrategies();
    notifyListeners();
  }

  void removeStrategy(String strategyId) {
    _strategies.removeWhere((s) => s.id == strategyId);
    _saveStrategies();
    notifyListeners();
  }

  void updateStrategy(TradingStrategy strategy) {
    final index = _strategies.indexWhere((s) => s.id == strategy.id);
    if (index != -1) {
      _strategies[index] = strategy;
      _saveStrategies();
      notifyListeners();
    }
  }

  void toggleStrategy(String strategyId) {
    final index = _strategies.indexWhere((s) => s.id == strategyId);
    if (index != -1) {
      _strategies[index] = _strategies[index].copyWith(
        isActive: !_strategies[index].isActive,
      );
      _saveStrategies();
      notifyListeners();
    }
  }

  Future<void> startMonitoring(BinanceApiService apiService) async {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _error = null;
    notifyListeners();

    _monitoringTimer = Timer.periodic(
      Duration(seconds: _monitoringInterval),
      (timer) => _checkStrategies(apiService),
    );

    // Initial check
    await _checkStrategies(apiService);
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    notifyListeners();
  }

  Future<void> _checkStrategies(BinanceApiService apiService) async {
    if (!_isMonitoring) return;

    try {
      for (final strategy in activeStrategies) {
        await _checkStrategy(strategy, apiService);
      }
    } catch (e) {
      _error = 'Error checking strategies: $e';
      notifyListeners();
    }
  }

  Future<void> _checkStrategy(
    TradingStrategy strategy,
    BinanceApiService apiService,
  ) async {
    try {
      // Get latest kline data
      final klines = await apiService.getKlines(
        strategy.symbol,
        '1m', // 1 minute intervals
        limit: 100,
      );

      _klineData[strategy.symbol] = klines;
      final prices = TechnicalIndicators.klinesToClosePrices(klines);

      TradingAction? action;

      switch (strategy.type) {
        case TradingStrategyType.macd:
          action = _checkMACDStrategy(strategy, prices);
          break;
        case TradingStrategyType.rsi:
          action = _checkRSIStrategy(strategy, prices);
          break;
        case TradingStrategyType.bollinger:
          action = _checkBollingerStrategy(strategy, prices);
          break;
        case TradingStrategyType.ema:
          action = _checkEMAStrategy(strategy, prices);
          break;
        case TradingStrategyType.sma:
          action = _checkSMAStrategy(strategy, prices);
          break;
      }

      if (action != null && action != TradingAction.hold) {
        final signal = TradingSignal(
          strategyId: strategy.id,
          symbol: strategy.symbol,
          action: action,
          price: prices.last,
          quantity: _calculateTradeQuantity(strategy.symbol, prices.last),
          timestamp: DateTime.now(),
          metadata: {
            'strategy_type': strategy.type.name,
            'strategy_name': strategy.name,
          },
        );

        _signals.add(signal);
        
        // Execute trade if auto-trading is enabled
        if (strategy.parameters['auto_execute'] == true) {
          await _executeSignal(signal, apiService);
        }

        // Update strategy last triggered time
        updateStrategy(strategy.copyWith(lastTriggered: DateTime.now()));
        
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error checking strategy ${strategy.name}: $e';
      notifyListeners();
    }
  }

  TradingAction? _checkMACDStrategy(TradingStrategy strategy, List<double> prices) {
    final fastPeriod = strategy.parameters['fast_period'] ?? 12;
    final slowPeriod = strategy.parameters['slow_period'] ?? 26;
    final signalPeriod = strategy.parameters['signal_period'] ?? 9;

    if (prices.length < slowPeriod) return null;

    final macd = TechnicalIndicators.calculateMACD(
      prices,
      fastPeriod: fastPeriod,
      slowPeriod: slowPeriod,
      signalPeriod: signalPeriod,
    );

    return TechnicalIndicators.analyzeMACDSignal(macd);
  }

  TradingAction? _checkRSIStrategy(TradingStrategy strategy, List<double> prices) {
    final period = strategy.parameters['period'] ?? 14;
    final oversoldLevel = strategy.parameters['oversold_level'] ?? 30.0;
    final overboughtLevel = strategy.parameters['overbought_level'] ?? 70.0;

    if (prices.length < period + 1) return null;

    final rsi = TechnicalIndicators.calculateRSI(prices, period: period);
    return TechnicalIndicators.analyzeRSISignal(
      rsi,
      oversoldLevel: oversoldLevel,
      overboughtLevel: overboughtLevel,
    );
  }

  TradingAction? _checkBollingerStrategy(TradingStrategy strategy, List<double> prices) {
    final period = strategy.parameters['period'] ?? 20;
    final standardDeviations = strategy.parameters['std_dev'] ?? 2.0;

    if (prices.length < period) return null;

    final bands = TechnicalIndicators.calculateBollingerBands(
      prices,
      period: period,
      standardDeviations: standardDeviations,
    );

    return TechnicalIndicators.analyzeBollingerBandsSignal(bands, prices);
  }

  TradingAction? _checkEMAStrategy(TradingStrategy strategy, List<double> prices) {
    final shortPeriod = strategy.parameters['short_period'] ?? 12;
    final longPeriod = strategy.parameters['long_period'] ?? 26;

    if (prices.length < longPeriod) return null;

    final shortEMA = TechnicalIndicators.calculateEMA(prices, shortPeriod);
    final longEMA = TechnicalIndicators.calculateEMA(prices, longPeriod);

    if (shortEMA.length < 2 || longEMA.length < 2) return null;

    final currentShort = shortEMA.last;
    final previousShort = shortEMA[shortEMA.length - 2];
    final currentLong = longEMA.last;
    final previousLong = longEMA[longEMA.length - 2];

    // Bullish crossover
    if (previousShort <= previousLong && currentShort > currentLong) {
      return TradingAction.buy;
    }
    
    // Bearish crossover
    if (previousShort >= previousLong && currentShort < currentLong) {
      return TradingAction.sell;
    }

    return TradingAction.hold;
  }

  TradingAction? _checkSMAStrategy(TradingStrategy strategy, List<double> prices) {
    final shortPeriod = strategy.parameters['short_period'] ?? 10;
    final longPeriod = strategy.parameters['long_period'] ?? 20;

    if (prices.length < longPeriod) return null;

    final shortSMA = TechnicalIndicators.calculateSMA(prices, shortPeriod);
    final longSMA = TechnicalIndicators.calculateSMA(prices, longPeriod);

    if (shortSMA.length < 2 || longSMA.length < 2) return null;

    final currentShort = shortSMA.last;
    final previousShort = shortSMA[shortSMA.length - 2];
    final currentLong = longSMA.last;
    final previousLong = longSMA[longSMA.length - 2];

    // Bullish crossover
    if (previousShort <= previousLong && currentShort > currentLong) {
      return TradingAction.buy;
    }
    
    // Bearish crossover
    if (previousShort >= previousLong && currentShort < currentLong) {
      return TradingAction.sell;
    }

    return TradingAction.hold;
  }

  double _calculateTradeQuantity(String symbol, double price) {
    // Calculate quantity based on default trade amount
    return _defaultTradeAmount / price;
  }

  Future<void> _executeSignal(
    TradingSignal signal,
    BinanceApiService apiService,
  ) async {
    try {
      Trade trade;
      
      switch (signal.action) {
        case TradingAction.buy:
          trade = await apiService.marketBuy(signal.symbol, signal.quantity);
          break;
        case TradingAction.sell:
          trade = await apiService.marketSell(signal.symbol, signal.quantity);
          break;
        case TradingAction.hold:
          return; // No action needed
      }

      _executedTrades.add(trade);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to execute trade: $e';
      notifyListeners();
    }
  }

  // Settings methods
  void setSpotTradingEnabled(bool enabled) {
    _enableSpotTrading = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setFuturesTradingEnabled(bool enabled) {
    _enableFuturesTrading = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setDefaultLeverage(double leverage) {
    _defaultLeverage = leverage;
    _saveSettings();
    notifyListeners();
  }

  void setIsolatedMargin(bool isolated) {
    _isolatedMargin = isolated;
    _saveSettings();
    notifyListeners();
  }

  void setDefaultTradeAmount(double amount) {
    _defaultTradeAmount = amount;
    _saveSettings();
    notifyListeners();
  }

  void setMonitoringInterval(int seconds) {
    _monitoringInterval = seconds;
    _saveSettings();
    
    // Restart monitoring with new interval if currently monitoring
    if (_isMonitoring) {
      _monitoringTimer?.cancel();
      // Will be restarted in next monitoring cycle
    }
    
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSignals() {
    _signals.clear();
    notifyListeners();
  }

  List<Kline>? getKlineData(String symbol) {
    return _klineData[symbol];
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }
}