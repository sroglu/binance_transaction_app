import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DebugHelper {
  static Future<Map<String, dynamic>> diagnoseConnection({bool isTestnet = false}) async {
    final results = <String, dynamic>{};
    
    // Add platform information
    results['platform'] = defaultTargetPlatform.name;
    results['testnet_mode'] = isTestnet;
    
    // Test basic internet connectivity
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(
        const Duration(seconds: 10),
      );
      results['internet'] = response.statusCode == 200;
    } catch (e) {
      results['internet'] = false;
      results['internet_error'] = e.toString();
    }
    
    // Test Binance API connectivity
    final baseUrl = isTestnet ? 'https://testnet.binance.vision' : 'https://api.binance.com';
    results['api_url'] = baseUrl;
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v3/ping')).timeout(
        const Duration(seconds: 10),
      );
      results['binance_ping'] = response.statusCode == 200;
      if (response.statusCode != 200) {
        results['binance_ping_status'] = response.statusCode;
        results['binance_ping_body'] = response.body;
      }
    } catch (e) {
      results['binance_ping'] = false;
      results['binance_ping_error'] = e.toString();
    }
    
    // Test Binance server time
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v3/time')).timeout(
        const Duration(seconds: 10),
      );
      results['binance_time'] = response.statusCode == 200;
      if (response.statusCode == 200) {
        results['server_time'] = response.body;
      }
    } catch (e) {
      results['binance_time'] = false;
      results['binance_time_error'] = e.toString();
    }
    
    // Check DNS resolution
    try {
      final addresses = await InternetAddress.lookup(isTestnet ? 'testnet.binance.vision' : 'api.binance.com');
      results['dns_resolution'] = addresses.isNotEmpty;
      results['resolved_addresses'] = addresses.map((addr) => addr.address).toList();
    } catch (e) {
      results['dns_resolution'] = false;
      results['dns_error'] = e.toString();
    }
    
    return results;
  }
  
  static String formatDiagnosisResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('=== Connection Diagnosis ===');
    buffer.writeln('Platform: ${results['platform']}');
    buffer.writeln('Testnet Mode: ${results['testnet_mode']}');
    buffer.writeln('API URL: ${results['api_url']}');
    buffer.writeln('');
    buffer.writeln('Internet: ${results['internet'] ? '✅' : '❌'}');
    if (results['internet_error'] != null) {
      buffer.writeln('  Error: ${results['internet_error']}');
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
    }
    
    buffer.writeln('DNS Resolution: ${results['dns_resolution'] ? '✅' : '❌'}');
    if (results['dns_error'] != null) {
      buffer.writeln('  Error: ${results['dns_error']}');
    } else if (results['resolved_addresses'] != null) {
      buffer.writeln('  Addresses: ${results['resolved_addresses'].join(', ')}');
    }
    
    return buffer.toString();
  }
}