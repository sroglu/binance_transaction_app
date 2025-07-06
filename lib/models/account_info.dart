import 'package:json_annotation/json_annotation.dart';

part 'account_info.g.dart';

@JsonSerializable()
class AccountInfo {
  final int makerCommission;
  final int takerCommission;
  final int buyerCommission;
  final int sellerCommission;
  final bool canTrade;
  final bool canWithdraw;
  final bool canDeposit;
  final int updateTime;
  final String accountType;
  final List<Balance> balances;

  AccountInfo({
    required this.makerCommission,
    required this.takerCommission,
    required this.buyerCommission,
    required this.sellerCommission,
    required this.canTrade,
    required this.canWithdraw,
    required this.canDeposit,
    required this.updateTime,
    required this.accountType,
    required this.balances,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) =>
      _$AccountInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AccountInfoToJson(this);
}

@JsonSerializable()
class Balance {
  final String asset;
  final String free;
  final String locked;

  Balance({
    required this.asset,
    required this.free,
    required this.locked,
  });

  double get freeAmount => double.tryParse(free) ?? 0.0;
  double get lockedAmount => double.tryParse(locked) ?? 0.0;
  double get totalAmount => freeAmount + lockedAmount;

  factory Balance.fromJson(Map<String, dynamic> json) =>
      _$BalanceFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceToJson(this);
}