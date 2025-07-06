// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountInfo _$AccountInfoFromJson(Map<String, dynamic> json) => AccountInfo(
      makerCommission: json['makerCommission'] as int,
      takerCommission: json['takerCommission'] as int,
      buyerCommission: json['buyerCommission'] as int,
      sellerCommission: json['sellerCommission'] as int,
      canTrade: json['canTrade'] as bool,
      canWithdraw: json['canWithdraw'] as bool,
      canDeposit: json['canDeposit'] as bool,
      updateTime: json['updateTime'] as int,
      accountType: json['accountType'] as String,
      balances: (json['balances'] as List<dynamic>)
          .map((e) => Balance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AccountInfoToJson(AccountInfo instance) =>
    <String, dynamic>{
      'makerCommission': instance.makerCommission,
      'takerCommission': instance.takerCommission,
      'buyerCommission': instance.buyerCommission,
      'sellerCommission': instance.sellerCommission,
      'canTrade': instance.canTrade,
      'canWithdraw': instance.canWithdraw,
      'canDeposit': instance.canDeposit,
      'updateTime': instance.updateTime,
      'accountType': instance.accountType,
      'balances': instance.balances,
    };

Balance _$BalanceFromJson(Map<String, dynamic> json) => Balance(
      asset: json['asset'] as String,
      free: json['free'] as String,
      locked: json['locked'] as String,
    );

Map<String, dynamic> _$BalanceToJson(Balance instance) => <String, dynamic>{
      'asset': instance.asset,
      'free': instance.free,
      'locked': instance.locked,
    };