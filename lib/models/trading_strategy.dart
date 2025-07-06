enum TradingStrategyType {
  macd,
  rsi,
  bollinger,
  ema,
  sma,
}

enum TradingAction {
  buy,
  sell,
  hold,
}

class TradingStrategy {
  final String id;
  final String name;
  final TradingStrategyType type;
  final String symbol;
  final bool isActive;
  final Map<String, dynamic> parameters;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  TradingStrategy({
    required this.id,
    required this.name,
    required this.type,
    required this.symbol,
    required this.isActive,
    required this.parameters,
    required this.createdAt,
    this.lastTriggered,
  });

  TradingStrategy copyWith({
    String? id,
    String? name,
    TradingStrategyType? type,
    String? symbol,
    bool? isActive,
    Map<String, dynamic>? parameters,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return TradingStrategy(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      symbol: symbol ?? this.symbol,
      isActive: isActive ?? this.isActive,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'symbol': symbol,
      'isActive': isActive,
      'parameters': parameters,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
    };
  }

  factory TradingStrategy.fromJson(Map<String, dynamic> json) {
    return TradingStrategy(
      id: json['id'],
      name: json['name'],
      type: TradingStrategyType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      symbol: json['symbol'],
      isActive: json['isActive'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      createdAt: DateTime.parse(json['createdAt']),
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'])
          : null,
    );
  }
}

class TradingSignal {
  final String strategyId;
  final String symbol;
  final TradingAction action;
  final double price;
  final double quantity;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  TradingSignal({
    required this.strategyId,
    required this.symbol,
    required this.action,
    required this.price,
    required this.quantity,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'strategyId': strategyId,
      'symbol': symbol,
      'action': action.name,
      'price': price,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory TradingSignal.fromJson(Map<String, dynamic> json) {
    return TradingSignal(
      strategyId: json['strategyId'],
      symbol: json['symbol'],
      action: TradingAction.values.firstWhere(
        (e) => e.name == json['action'],
      ),
      price: json['price'].toDouble(),
      quantity: json['quantity'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }
}