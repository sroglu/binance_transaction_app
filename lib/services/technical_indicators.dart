import 'dart:math';
import '../models/kline.dart';
import '../models/trading_strategy.dart';

class TechnicalIndicators {
  // MACD (Moving Average Convergence Divergence)
  static MACDResult calculateMACD(
    List<double> prices, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (prices.length < slowPeriod) {
      throw Exception('Not enough data points for MACD calculation');
    }

    final fastEMA = _calculateEMA(prices, fastPeriod);
    final slowEMA = _calculateEMA(prices, slowPeriod);
    
    final macdLine = <double>[];
    for (int i = 0; i < fastEMA.length && i < slowEMA.length; i++) {
      macdLine.add(fastEMA[i] - slowEMA[i]);
    }

    final signalLine = _calculateEMA(macdLine, signalPeriod);
    final histogram = <double>[];
    
    for (int i = 0; i < macdLine.length && i < signalLine.length; i++) {
      histogram.add(macdLine[i] - signalLine[i]);
    }

    return MACDResult(
      macdLine: macdLine,
      signalLine: signalLine,
      histogram: histogram,
    );
  }

  // RSI (Relative Strength Index)
  static List<double> calculateRSI(List<double> prices, {int period = 14}) {
    if (prices.length < period + 1) {
      throw Exception('Not enough data points for RSI calculation');
    }

    final gains = <double>[];
    final losses = <double>[];

    for (int i = 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }

    final rsi = <double>[];
    double avgGain = gains.take(period).reduce((a, b) => a + b) / period;
    double avgLoss = losses.take(period).reduce((a, b) => a + b) / period;

    for (int i = period; i < gains.length; i++) {
      if (avgLoss == 0) {
        rsi.add(100);
      } else {
        final rs = avgGain / avgLoss;
        rsi.add(100 - (100 / (1 + rs)));
      }

      avgGain = (avgGain * (period - 1) + gains[i]) / period;
      avgLoss = (avgLoss * (period - 1) + losses[i]) / period;
    }

    return rsi;
  }

  // Bollinger Bands
  static BollingerBandsResult calculateBollingerBands(
    List<double> prices, {
    int period = 20,
    double standardDeviations = 2.0,
  }) {
    if (prices.length < period) {
      throw Exception('Not enough data points for Bollinger Bands calculation');
    }

    final sma = calculateSMA(prices, period);
    final upperBand = <double>[];
    final lowerBand = <double>[];

    for (int i = 0; i < sma.length; i++) {
      final startIndex = i;
      final endIndex = i + period;
      final subset = prices.sublist(startIndex, endIndex);
      
      final variance = subset
          .map((price) => pow(price - sma[i], 2))
          .reduce((a, b) => a + b) / period;
      final stdDev = sqrt(variance);

      upperBand.add(sma[i] + (standardDeviations * stdDev));
      lowerBand.add(sma[i] - (standardDeviations * stdDev));
    }

    return BollingerBandsResult(
      upperBand: upperBand,
      middleBand: sma,
      lowerBand: lowerBand,
    );
  }

  // Simple Moving Average
  static List<double> calculateSMA(List<double> prices, int period) {
    if (prices.length < period) {
      throw Exception('Not enough data points for SMA calculation');
    }

    final sma = <double>[];
    for (int i = 0; i <= prices.length - period; i++) {
      final sum = prices.sublist(i, i + period).reduce((a, b) => a + b);
      sma.add(sum / period);
    }
    return sma;
  }

  // Exponential Moving Average
  static List<double> _calculateEMA(List<double> prices, int period) {
    if (prices.length < period) {
      throw Exception('Not enough data points for EMA calculation');
    }

    final ema = <double>[];
    final multiplier = 2.0 / (period + 1);
    
    // Start with SMA for the first value
    final firstSMA = prices.take(period).reduce((a, b) => a + b) / period;
    ema.add(firstSMA);

    for (int i = period; i < prices.length; i++) {
      final currentEMA = (prices[i] * multiplier) + (ema.last * (1 - multiplier));
      ema.add(currentEMA);
    }

    return ema;
  }

  // Calculate EMA (public method)
  static List<double> calculateEMA(List<double> prices, int period) {
    return _calculateEMA(prices, period);
  }

  // MACD Trading Signal Analysis
  static TradingAction analyzeMACDSignal(
    MACDResult macd, {
    double threshold = 0.0001,
  }) {
    if (macd.macdLine.length < 2 || macd.signalLine.length < 2) {
      return TradingAction.hold;
    }

    final currentMACD = macd.macdLine.last;
    final previousMACD = macd.macdLine[macd.macdLine.length - 2];
    final currentSignal = macd.signalLine.last;
    final previousSignal = macd.signalLine[macd.signalLine.length - 2];

    // Bullish crossover: MACD crosses above signal line
    if (previousMACD <= previousSignal && currentMACD > currentSignal + threshold) {
      return TradingAction.buy;
    }
    
    // Bearish crossover: MACD crosses below signal line
    if (previousMACD >= previousSignal && currentMACD < currentSignal - threshold) {
      return TradingAction.sell;
    }

    return TradingAction.hold;
  }

  // RSI Trading Signal Analysis
  static TradingAction analyzeRSISignal(
    List<double> rsi, {
    double oversoldLevel = 30,
    double overboughtLevel = 70,
  }) {
    if (rsi.length < 2) {
      return TradingAction.hold;
    }

    final currentRSI = rsi.last;
    final previousRSI = rsi[rsi.length - 2];

    // Oversold condition turning up
    if (previousRSI <= oversoldLevel && currentRSI > oversoldLevel) {
      return TradingAction.buy;
    }
    
    // Overbought condition turning down
    if (previousRSI >= overboughtLevel && currentRSI < overboughtLevel) {
      return TradingAction.sell;
    }

    return TradingAction.hold;
  }

  // Bollinger Bands Trading Signal Analysis
  static TradingAction analyzeBollingerBandsSignal(
    BollingerBandsResult bands,
    List<double> prices,
  ) {
    if (bands.lowerBand.isEmpty || bands.upperBand.isEmpty || prices.isEmpty) {
      return TradingAction.hold;
    }

    final currentPrice = prices.last;
    final currentLower = bands.lowerBand.last;
    final currentUpper = bands.upperBand.last;

    // Price touches lower band (oversold)
    if (currentPrice <= currentLower) {
      return TradingAction.buy;
    }
    
    // Price touches upper band (overbought)
    if (currentPrice >= currentUpper) {
      return TradingAction.sell;
    }

    return TradingAction.hold;
  }

  // Convert Klines to closing prices
  static List<double> klinesToClosePrices(List<Kline> klines) {
    return klines.map((k) => k.closePrice).toList();
  }

  // Convert Klines to high prices
  static List<double> klinesToHighPrices(List<Kline> klines) {
    return klines.map((k) => k.highPrice).toList();
  }

  // Convert Klines to low prices
  static List<double> klinesToLowPrices(List<Kline> klines) {
    return klines.map((k) => k.lowPrice).toList();
  }

  // Convert Klines to open prices
  static List<double> klinesToOpenPrices(List<Kline> klines) {
    return klines.map((k) => k.openPrice).toList();
  }
}

class MACDResult {
  final List<double> macdLine;
  final List<double> signalLine;
  final List<double> histogram;

  MACDResult({
    required this.macdLine,
    required this.signalLine,
    required this.histogram,
  });
}

class BollingerBandsResult {
  final List<double> upperBand;
  final List<double> middleBand;
  final List<double> lowerBand;

  BollingerBandsResult({
    required this.upperBand,
    required this.middleBand,
    required this.lowerBand,
  });
}