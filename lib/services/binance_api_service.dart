import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../models/account_info.dart';
import '../models/trade.dart';
import '../models/kline.dart';

class BinanceApiService {
  static const String _baseUrl = 'https://api.binance.com';
  static const String _testnetUrl = 'https://testnet.binance.vision';
  
  final String _apiKey;
  final String _secretKey;
  final bool _isTestnet;

  BinanceApiService({
    required String apiKey,
    required String secretKey,
    bool isTestnet = false,
  })  : _apiKey = apiKey,
        _secretKey = secretKey,
        _isTestnet = isTestnet;

  String get _baseApiUrl => _isTestnet ? _testnetUrl : _baseUrl;

  Map<String, String> get _headers => {
        'X-MBX-APIKEY': _apiKey,
        'Content-Type': 'application/json',
      };

  String _generateSignature(String queryString) {
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(queryString);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  String _buildQueryString(Map<String, dynamic> params) {
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    
    return sortedParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }

  String _formatApiError(http.Response response) {
    String errorMessage;
    try {
      final error = json.decode(response.body);
      errorMessage = 'Binance API Error: ${error['msg']} (Code: ${error['code']})';
      
      // Add specific handling for common issues
      if (_isTestnet && (error['code'] == -2014 || error['code'] == -2015)) {
        errorMessage += '\n\n🔧 Testnet Issue: Make sure you are using testnet API keys from https://testnet.binance.vision/';
        errorMessage += '\n   • Testnet keys are different from live keys';
        errorMessage += '\n   • Create testnet account at testnet.binance.vision';
      } else if (error['code'] == -1022) {
        errorMessage += '\n\n🔧 Signature Issue: Check your API secret key for typos.';
      } else if (error['code'] == -2015) {
        errorMessage += '\n\n🔧 API Key Issue: Invalid API key format or permissions.';
        errorMessage += '\n   • Check API key permissions in Binance account';
        errorMessage += '\n   • Enable "Spot & Margin Trading"';
      } else if (error['code'] == -1021) {
        errorMessage += '\n\n🔧 Timestamp Issue: Your system clock might be incorrect.';
      } else if (error['code'] == -1000) {
        errorMessage += '\n\n🔧 Unknown Error: This might be a temporary server issue.';
      }
    } catch (e) {
      errorMessage = 'HTTP Error ${response.statusCode}: ${response.reasonPhrase}\nResponse: ${response.body}';
    }
    return errorMessage;
  }

  Future<Map<String, dynamic>> _makeSignedRequest(
    String endpoint,
    Map<String, dynamic> params, {
    String method = 'GET',
  }) async {
    try {
      params['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      final queryString = _buildQueryString(params);
      final signature = _generateSignature(queryString);
      final signedQueryString = '$queryString&signature=$signature';

      final url = Uri.parse('$_baseApiUrl$endpoint?$signedQueryString');
      
      late http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: _headers).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout - please check your internet connection'),
          );
          break;
        case 'POST':
          response = await http.post(url, headers: _headers).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout - please check your internet connection'),
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: _headers).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout - please check your internet connection'),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(_formatApiError(response));
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('HandshakeException')) {
        throw Exception('Cannot connect to Binance API - please check your internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout - please check your internet connection');
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> _makePublicRequest(String endpoint, [Map<String, dynamic>? params]) async {
    try {
      String url = '$_baseApiUrl$endpoint';
      if (params != null && params.isNotEmpty) {
        final queryString = _buildQueryString(params);
        url += '?$queryString';
      }

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout - please check your internet connection'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(_formatApiError(response));
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('HandshakeException')) {
        throw Exception('Cannot connect to Binance API - please check your internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout - please check your internet connection');
      } else {
        rethrow;
      }
    }
  }

  // Test connectivity
  Future<bool> testConnectivity() async {
    try {
      final response = await http.get(Uri.parse('$_baseApiUrl/api/v3/ping')).timeout(
        const Duration(seconds: 10),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get server time
  Future<int> getServerTime() async {
    final response = await _makePublicRequest('/api/v3/time');
    return response['serverTime'];
  }

  // Get account information
  Future<AccountInfo> getAccountInfo() async {
    final response = await _makeSignedRequest('/api/v3/account', {});
    return AccountInfo.fromJson(response);
  }

  // Get current prices for all symbols
  Future<List<TickerPrice>> getAllPrices() async {
    final response = await _makePublicRequest('/api/v3/ticker/price');
    return (response as List).map((e) => TickerPrice.fromJson(e)).toList();
  }

  // Get price for specific symbol
  Future<TickerPrice> getPrice(String symbol) async {
    final response = await _makePublicRequest('/api/v3/ticker/price', {'symbol': symbol});
    return TickerPrice.fromJson(response);
  }

  // Get klines/candlestick data
  Future<List<Kline>> getKlines(
    String symbol,
    String interval, {
    int? limit,
    int? startTime,
    int? endTime,
  }) async {
    final params = <String, dynamic>{'symbol': symbol, 'interval': interval};
    if (limit != null) params['limit'] = limit;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;

    final response = await _makePublicRequest('/api/v3/klines', params);
    return (response as List).map((e) => Kline.fromArray(e)).toList();
  }

  // Place a new order
  Future<Trade> placeOrder({
    required String symbol,
    required String side, // BUY or SELL
    required String type, // MARKET, LIMIT, etc.
    String? timeInForce,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? newClientOrderId,
    double? stopPrice,
    double? icebergQty,
    String? newOrderRespType,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'type': type,
    };

    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (quantity != null) params['quantity'] = quantity.toString();
    if (quoteOrderQty != null) params['quoteOrderQty'] = quoteOrderQty.toString();
    if (price != null) params['price'] = price.toString();
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice.toString();
    if (icebergQty != null) params['icebergQty'] = icebergQty.toString();
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;

    final response = await _makeSignedRequest('/api/v3/order', params, method: 'POST');
    return Trade.fromJson(response);
  }

  // Get trade history
  Future<List<TradeHistory>> getTradeHistory(String symbol, {int? limit}) async {
    final params = <String, dynamic>{'symbol': symbol};
    if (limit != null) params['limit'] = limit;

    final response = await _makeSignedRequest('/api/v3/myTrades', params);
    return (response as List).map((e) => TradeHistory.fromJson(e)).toList();
  }

  // Cancel an order
  Future<Map<String, dynamic>> cancelOrder(String symbol, int orderId) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'orderId': orderId,
    };

    return await _makeSignedRequest('/api/v3/order', params, method: 'DELETE');
  }

  // Get all open orders
  Future<List<Map<String, dynamic>>> getOpenOrders([String? symbol]) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;

    final response = await _makeSignedRequest('/api/v3/openOrders', params);
    return List<Map<String, dynamic>>.from(response.values);
  }

  // Market buy order
  Future<Trade> marketBuy(String symbol, double quantity) async {
    return await placeOrder(
      symbol: symbol,
      side: 'BUY',
      type: 'MARKET',
      quantity: quantity,
    );
  }

  // Market sell order
  Future<Trade> marketSell(String symbol, double quantity) async {
    return await placeOrder(
      symbol: symbol,
      side: 'SELL',
      type: 'MARKET',
      quantity: quantity,
    );
  }

  // Limit buy order
  Future<Trade> limitBuy(String symbol, double quantity, double price) async {
    return await placeOrder(
      symbol: symbol,
      side: 'BUY',
      type: 'LIMIT',
      timeInForce: 'GTC',
      quantity: quantity,
      price: price,
    );
  }

  // Limit sell order
  Future<Trade> limitSell(String symbol, double quantity, double price) async {
    return await placeOrder(
      symbol: symbol,
      side: 'SELL',
      type: 'LIMIT',
      timeInForce: 'GTC',
      quantity: quantity,
      price: price,
    );
  }
}