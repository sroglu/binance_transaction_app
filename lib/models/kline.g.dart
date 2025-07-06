// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Kline _$KlineFromJson(Map<String, dynamic> json) => Kline(
      openTime: json['openTime'] as int,
      open: json['open'] as String,
      high: json['high'] as String,
      low: json['low'] as String,
      close: json['close'] as String,
      volume: json['volume'] as String,
      closeTime: json['closeTime'] as int,
      quoteAssetVolume: json['quoteAssetVolume'] as String,
      numberOfTrades: json['numberOfTrades'] as int,
      takerBuyBaseAssetVolume: json['takerBuyBaseAssetVolume'] as String,
      takerBuyQuoteAssetVolume: json['takerBuyQuoteAssetVolume'] as String,
    );

Map<String, dynamic> _$KlineToJson(Kline instance) => <String, dynamic>{
      'openTime': instance.openTime,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': instance.volume,
      'closeTime': instance.closeTime,
      'quoteAssetVolume': instance.quoteAssetVolume,
      'numberOfTrades': instance.numberOfTrades,
      'takerBuyBaseAssetVolume': instance.takerBuyBaseAssetVolume,
      'takerBuyQuoteAssetVolume': instance.takerBuyQuoteAssetVolume,
    };

TickerPrice _$TickerPriceFromJson(Map<String, dynamic> json) => TickerPrice(
      symbol: json['symbol'] as String,
      price: json['price'] as String,
    );

Map<String, dynamic> _$TickerPriceToJson(TickerPrice instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'price': instance.price,
    };