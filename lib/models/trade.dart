import 'package:json_annotation/json_annotation.dart';

part 'trade.g.dart';

@JsonSerializable()
class Trade {
  final String symbol;
  final int orderId;
  final int orderListId;
  final String clientOrderId;
  final int transactTime;
  final String price;
  final String origQty;
  final String executedQty;
  final String cummulativeQuoteQty;
  final String status;
  final String timeInForce;
  final String type;
  final String side;
  final List<Fill> fills;

  Trade({
    required this.symbol,
    required this.orderId,
    required this.orderListId,
    required this.clientOrderId,
    required this.transactTime,
    required this.price,
    required this.origQty,
    required this.executedQty,
    required this.cummulativeQuoteQty,
    required this.status,
    required this.timeInForce,
    required this.type,
    required this.side,
    required this.fills,
  });

  double get priceValue => double.tryParse(price) ?? 0.0;
  double get quantityValue => double.tryParse(executedQty) ?? 0.0;
  double get totalValue => double.tryParse(cummulativeQuoteQty) ?? 0.0;
  
  DateTime get tradeTime => DateTime.fromMillisecondsSinceEpoch(transactTime);

  factory Trade.fromJson(Map<String, dynamic> json) => _$TradeFromJson(json);
  Map<String, dynamic> toJson() => _$TradeToJson(this);
}

@JsonSerializable()
class Fill {
  final String price;
  final String qty;
  final String commission;
  final String commissionAsset;

  Fill({
    required this.price,
    required this.qty,
    required this.commission,
    required this.commissionAsset,
  });

  factory Fill.fromJson(Map<String, dynamic> json) => _$FillFromJson(json);
  Map<String, dynamic> toJson() => _$FillToJson(this);
}

@JsonSerializable()
class TradeHistory {
  final String symbol;
  final int id;
  final int orderId;
  final int orderListId;
  final String price;
  final String qty;
  final String quoteQty;
  final String commission;
  final String commissionAsset;
  final int time;
  final bool isBuyer;
  final bool isMaker;
  final bool isBestMatch;

  TradeHistory({
    required this.symbol,
    required this.id,
    required this.orderId,
    required this.orderListId,
    required this.price,
    required this.qty,
    required this.quoteQty,
    required this.commission,
    required this.commissionAsset,
    required this.time,
    required this.isBuyer,
    required this.isMaker,
    required this.isBestMatch,
  });

  double get priceValue => double.tryParse(price) ?? 0.0;
  double get quantityValue => double.tryParse(qty) ?? 0.0;
  double get totalValue => double.tryParse(quoteQty) ?? 0.0;
  DateTime get tradeTime => DateTime.fromMillisecondsSinceEpoch(time);

  factory TradeHistory.fromJson(Map<String, dynamic> json) =>
      _$TradeHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$TradeHistoryToJson(this);
}