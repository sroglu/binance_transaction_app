import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DebugHelper {
  static Future<Map<String, dynamic>> diagnoseConnection({bool isTestnet = false}) async {
    final results = <String, dynamic>{};
    
    // Add platform information
    results['platform'] = defaultTargetPlatform.name;
    results['testnet_mode'] = isTestnet;
    results['os_version'] = Platform.operatingSystemVersion;
    
    // Test basic internet connectivity with multiple endpoints
    bool internetWorking = false;
    String? internetError;
    
    // Try multiple endpoints to test internet connectivity
    final testUrls = [
      'https://httpbin.org/status/200',
      'https://www.google.com',
      'https://api.binance.com/api/v3/ping',
    ];
    
    for (final url in testUrls) {
      try {
        final client = http.Client();
        try {
          final response = await client.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'BinanceApp/1.0',
              'Accept': 'application/json,text/html,*/*',
              'Connection': 'close',
            },
          ).timeout(const Duration(seconds: 15));
          
          if (response.statusCode == 200) {
            internetWorking = true;
            break;
          } else {
            internetError = 'HTTP ${response.statusCode} from $url';
          }
        } finally {
          client.close();
        }
      } catch (e) {
        internetError = '$url: ${e.toString()}';
        continue;
      }
    }
    
    results['internet'] = internetWorking;
    if (!internetWorking && internetError != null) {
      results['internet_error'] = internetError;
    }
    
    // Test Binance API connectivity
    final baseUrl = isTestnet ? 'https://testnet.binance.vision' : 'https://api.binance.com';
    results['api_url'] = baseUrl;
    
    try {
      final client = http.Client();
      try {
        final response = await client.get(
          Uri.parse('$baseUrl/api/v3/ping'),
          headers: {
            'User-Agent': 'BinanceApp/1.0',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));
        results['binance_ping'] = response.statusCode == 200;
        if (response.statusCode != 200) {
          results['binance_ping_status'] = response.statusCode;
          results['binance_ping_body'] = response.body;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      results['binance_ping'] = false;
      results['binance_ping_error'] = e.toString();
    }
    
    // Test Binance server time
    try {
      final client = http.Client();
      try {
        final response = await client.get(
          Uri.parse('$baseUrl/api/v3/time'),
          headers: {
            'User-Agent': 'BinanceApp/1.0',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));
        results['binance_time'] = response.statusCode == 200;
        if (response.statusCode == 200) {
          results['server_time'] = response.body;
        } else {
          results['binance_time_status'] = response.statusCode;
          results['binance_time_body'] = response.body;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      results['binance_time'] = false;
      results['binance_time_error'] = e.toString();
    }
    
    // Check DNS resolution (platform-specific)
    if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isWindows) {
      try {
        final addresses = await InternetAddress.lookup(isTestnet ? 'testnet.binance.vision' : 'api.binance.com');
        results['dns_resolution'] = addresses.isNotEmpty;
        results['resolved_addresses'] = addresses.map((addr) => addr.address).toList();
      } catch (e) {
        results['dns_resolution'] = false;
        results['dns_error'] = e.toString();
      }
    } else {
      // DNS resolution not supported on this platform (macOS Flutter)
      results['dns_resolution'] = 'N/A';
      results['dns_note'] = 'DNS resolution not supported on ${Platform.operatingSystem}';
    }
    
    return results;
  }
  
  static String formatDiagnosisResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('=== Connection Diagnosis ===');
    buffer.writeln('Platform: ${results['platform']}');
    buffer.writeln('OS Version: ${results['os_version']}');
    buffer.writeln('Testnet Mode: ${results['testnet_mode']}');
    buffer.writeln('API URL: ${results['api_url']}');
    buffer.writeln('');
    buffer.writeln('Internet: ${results['internet'] ? '✅' : '❌'}');
    if (results['internet_error'] != null) {
      buffer.writeln('  Error: ${results['internet_error']}');
    } else if (results['internet_status'] != null) {
      buffer.writeln('  Status: ${results['internet_status']}');
    }
    
    buffer.writeln('Binance Ping: ${results['binance_ping'] ? '✅' : '❌'}');
    if (results['binance_ping_error'] != null) {
      buffer.writeln('  Error: ${results['binance_ping_error']}');
    } else if (results['binance_ping_status'] != null) {
      buffer.writeln('  Status: ${results['binance_ping_status']}');
      buffer.writeln('  Response: ${results['binance_ping_body']}');
    }
    
    buffer.writeln('Binance Time: ${results['binance_time'] ? '✅' : '❌'}');
    if (results['binance_time_error'] != null) {
      buffer.writeln('  Error: ${results['binance_time_error']}');
    } else if (results['binance_time_status'] != null) {
      buffer.writeln('  Status: ${results['binance_time_status']}');
      buffer.writeln('  Response: ${results['binance_time_body']}');
    }
    
    if (results['dns_resolution'] == 'N/A') {
      buffer.writeln('DNS Resolution: ⚠️ N/A');
      if (results['dns_note'] != null) {
        buffer.writeln('  Note: ${results['dns_note']}');
      }
    } else {
      buffer.writeln('DNS Resolution: ${results['dns_resolution'] ? '✅' : '❌'}');
      if (results['dns_error'] != null) {
        buffer.writeln('  Error: ${results['dns_error']}');
      } else if (results['resolved_addresses'] != null) {
        buffer.writeln('  Addresses: ${results['resolved_addresses'].join(', ')}');
      }
    }
    
    return buffer.toString();
  }
}