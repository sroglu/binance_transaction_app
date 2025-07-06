// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trade _$TradeFromJson(Map<String, dynamic> json) => Trade(
      symbol: json['symbol'] as String,
      orderId: json['orderId'] as int,
      orderListId: json['orderListId'] as int,
      clientOrderId: json['clientOrderId'] as String,
      transactTime: json['transactTime'] as int,
      price: json['price'] as String,
      origQty: json['origQty'] as String,
      executedQty: json['executedQty'] as String,
      cummulativeQuoteQty: json['cummulativeQuoteQty'] as String,
      status: json['status'] as String,
      timeInForce: json['timeInForce'] as String,
      type: json['type'] as String,
      side: json['side'] as String,
      fills: (json['fills'] as List<dynamic>)
          .map((e) => Fill.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TradeToJson(Trade instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'orderId': instance.orderId,
      'orderListId': instance.orderListId,
      'clientOrderId': instance.clientOrderId,
      'transactTime': instance.transactTime,
      'price': instance.price,
      'origQty': instance.origQty,
      'executedQty': instance.executedQty,
      'cummulativeQuoteQty': instance.cummulativeQuoteQty,
      'status': instance.status,
      'timeInForce': instance.timeInForce,
      'type': instance.type,
      'side': instance.side,
      'fills': instance.fills,
    };

Fill _$FillFromJson(Map<String, dynamic> json) => Fill(
      price: json['price'] as String,
      qty: json['qty'] as String,
      commission: json['commission'] as String,
      commissionAsset: json['commissionAsset'] as String,
    );

Map<String, dynamic> _$FillToJson(Fill instance) => <String, dynamic>{
      'price': instance.price,
      'qty': instance.qty,
      'commission': instance.commission,
      'commissionAsset': instance.commissionAsset,
    };

TradeHistory _$TradeHistoryFromJson(Map<String, dynamic> json) => TradeHistory(
      symbol: json['symbol'] as String,
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      orderListId: json['orderListId'] as int,
      price: json['price'] as String,
      qty: json['qty'] as String,
      quoteQty: json['quoteQty'] as String,
      commission: json['commission'] as String,
      commissionAsset: json['commissionAsset'] as String,
      time: json['time'] as int,
      isBuyer: json['isBuyer'] as bool,
      isMaker: json['isMaker'] as bool,
      isBestMatch: json['isBestMatch'] as bool,
    );

Map<String, dynamic> _$TradeHistoryToJson(TradeHistory instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'id': instance.id,
      'orderId': instance.orderId,
      'orderListId': instance.orderListId,
      'price': instance.price,
      'qty': instance.qty,
      'quoteQty': instance.quoteQty,
      'commission': instance.commission,
      'commissionAsset': instance.commissionAsset,
      'time': instance.time,
      'isBuyer': instance.isBuyer,
      'isMaker': instance.isMaker,
      'isBestMatch': instance.isBestMatch,
    };