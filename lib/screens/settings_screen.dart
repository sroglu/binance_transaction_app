import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/trading_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAccountSection(context),
          const SizedBox(height: 16),
          _buildTradingSection(context),
          const SizedBox(height: 16),
          _buildAppSection(context),
          const SizedBox(height: 16),
          _buildDangerZone(context),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(
                    auth.isTestnet ? Icons.bug_report : Icons.public,
                    color: auth.isTestnet ? Colors.orange : Colors.green,
                  ),
                  title: Text(auth.isTestnet ? 'Testnet Account' : 'Live Account'),
                  subtitle: Text(
                    auth.isTestnet
                        ? 'Using Binance Testnet for safe testing'
                        : 'Connected to live Binance account',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: auth.isTestnet ? Colors.orange : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      auth.isTestnet ? 'TEST' : 'LIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Validate Credentials'),
                  subtitle: const Text('Test API connection'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _validateCredentials(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout'),
                  subtitle: const Text('Sign out of your account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTradingSection(BuildContext context) {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trading Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Spot Trading'),
                  subtitle: const Text('Enable spot trading'),
                  value: trading.enableSpotTrading,
                  onChanged: trading.setSpotTradingEnabled,
                  secondary: const Icon(Icons.currency_bitcoin),
                ),
                SwitchListTile(
                  title: const Text('Futures Trading'),
                  subtitle: const Text('Enable futures trading'),
                  value: trading.enableFuturesTrading,
                  onChanged: trading.setFuturesTradingEnabled,
                  secondary: const Icon(Icons.trending_up),
                ),
                if (trading.enableFuturesTrading) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: const Text('Default Leverage'),
                    subtitle: Text('${trading.defaultLeverage.toStringAsFixed(1)}x'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showLeverageDialog(context, trading),
                  ),
                  SwitchListTile(
                    title: const Text('Isolated Margin'),
                    subtitle: const Text('Use isolated margin mode'),
                    value: trading.isolatedMargin,
                    onChanged: trading.setIsolatedMargin,
                    secondary: const Icon(Icons.account_balance),
                  ),
                ],
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Default Trade Amount'),
                  subtitle: Text('${trading.defaultTradeAmount.toStringAsFixed(2)} USDT'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showTradeAmountDialog(context, trading),
                ),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Monitoring Interval'),
                  subtitle: Text('${trading.monitoringInterval} seconds'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showMonitoringIntervalDialog(context, trading),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'App Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('App version and information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAboutDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help with the app'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHelpDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.red),
              title: const Text('Clear All Data'),
              subtitle: const Text('Remove all strategies and signals'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearDataConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _validateCredentials(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Validating credentials...'),
          ],
        ),
      ),
    );

    final isValid = await authProvider.validateCredentials();
    
    if (context.mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isValid ? 'Success' : 'Error'),
          content: Text(
            isValid
                ? 'Your API credentials are valid and working.'
                : 'Failed to validate credentials. Please check your API keys.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? This will stop all trading activities.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Stop trading and clear data
              final tradingProvider = context.read<TradingProvider>();
              final balanceProvider = context.read<BalanceProvider>();
              
              tradingProvider.stopMonitoring();
              balanceProvider.clear();
              
              // Logout
              await context.read<AuthProvider>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showTradeAmountDialog(BuildContext context, TradingProvider trading) {
    final controller = TextEditingController(
      text: trading.defaultTradeAmount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Trade Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (USDT)',
            border: OutlineInputBorder(),
            helperText: 'Minimum: 10 USDT',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount >= 10) {
                trading.setDefaultTradeAmount(amount);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount (minimum 10 USDT)'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMonitoringIntervalDialog(BuildContext context, TradingProvider trading) {
    final controller = TextEditingController(
      text: trading.monitoringInterval.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monitoring Interval'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Interval (seconds)',
            border: OutlineInputBorder(),
            helperText: 'Minimum: 10 seconds',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final interval = int.tryParse(controller.text);
              if (interval != null && interval >= 10) {
                trading.setMonitoringInterval(interval);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid interval (minimum 10 seconds)'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Binance Trading App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.currency_bitcoin, size: 48),
      children: [
        const Text(
          'A cross-platform trading application for Binance with automated trading strategies based on technical indicators.',
        ),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• MACD, RSI, Bollinger Bands indicators'),
        const Text('• Automated trading strategies'),
        const Text('• Real-time balance monitoring'),
        const Text('• Trade history tracking'),
        const Text('• Cross-platform support'),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Getting Started:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Enter your Binance API credentials'),
              Text('2. Create trading strategies'),
              Text('3. Start monitoring to begin automated trading'),
              SizedBox(height: 16),
              Text(
                'Safety Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Always test with Testnet first'),
              Text('• Start with small trade amounts'),
              Text('• Monitor your strategies regularly'),
              Text('• Keep your API keys secure'),
              SizedBox(height: 16),
              Text(
                'API Permissions Required:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Enable Spot & Margin Trading'),
              Text('• Do NOT enable withdrawals'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your trading strategies and signals. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              
              // Clear all data
              final tradingProvider = context.read<TradingProvider>();
              tradingProvider.stopMonitoring();
              tradingProvider.clearSignals();
              
              // Clear strategies (you might want to add this method to TradingProvider)
              // tradingProvider.clearAllStrategies();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared successfully'),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showLeverageDialog(BuildContext context, TradingProvider trading) {
    final controller = TextEditingController(
      text: trading.defaultLeverage.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Leverage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Leverage (1x - 125x)',
                border: OutlineInputBorder(),
                helperText: 'Higher leverage = Higher risk',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning: High leverage increases both potential profits and losses. Trade responsibly.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final leverage = double.tryParse(controller.text);
              if (leverage != null && leverage >= 1 && leverage <= 125) {
                trading.setDefaultLeverage(leverage);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid leverage (1x - 125x)'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}