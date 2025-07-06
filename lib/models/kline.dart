import 'package:json_annotation/json_annotation.dart';

part 'kline.g.dart';

@JsonSerializable()
class Kline {
  final int openTime;
  final String open;
  final String high;
  final String low;
  final String close;
  final String volume;
  final int closeTime;
  final String quoteAssetVolume;
  final int numberOfTrades;
  final String takerBuyBaseAssetVolume;
  final String takerBuyQuoteAssetVolume;

  Kline({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
    required this.quoteAssetVolume,
    required this.numberOfTrades,
    required this.takerBuyBaseAssetVolume,
    required this.takerBuyQuoteAssetVolume,
  });

  double get openPrice => double.tryParse(open) ?? 0.0;
  double get highPrice => double.tryParse(high) ?? 0.0;
  double get lowPrice => double.tryParse(low) ?? 0.0;
  double get closePrice => double.tryParse(close) ?? 0.0;
  double get volumeValue => double.tryParse(volume) ?? 0.0;

  DateTime get openDateTime => DateTime.fromMillisecondsSinceEpoch(openTime);
  DateTime get closeDateTime => DateTime.fromMillisecondsSinceEpoch(closeTime);

  factory Kline.fromJson(Map<String, dynamic> json) => _$KlineFromJson(json);
  Map<String, dynamic> toJson() => _$KlineToJson(this);

  // Factory constructor for creating from array format (as returned by Binance API)
  factory Kline.fromArray(List<dynamic> data) {
    return Kline(
      openTime: data[0],
      open: data[1].toString(),
      high: data[2].toString(),
      low: data[3].toString(),
      close: data[4].toString(),
      volume: data[5].toString(),
      closeTime: data[6],
      quoteAssetVolume: data[7].toString(),
      numberOfTrades: data[8],
      takerBuyBaseAssetVolume: data[9].toString(),
      takerBuyQuoteAssetVolume: data[10].toString(),
    );
  }
}

@JsonSerializable()
class TickerPrice {
  final String symbol;
  final String price;

  TickerPrice({
    required this.symbol,
    required this.price,
  });

  double get priceValue => double.tryParse(price) ?? 0.0;

  factory TickerPrice.fromJson(Map<String, dynamic> json) =>
      _$TickerPriceFromJson(json);
  Map<String, dynamic> toJson() => _$TickerPriceToJson(this);
}