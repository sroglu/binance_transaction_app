import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/trading_provider.dart';
import '../models/trading_strategy.dart';
import '../widgets/strategy_card.dart';
import '../widgets/add_strategy_dialog.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Strategies', icon: Icon(Icons.add_chart)),
            Tab(text: 'Settings', icon: Icon(Icons.tune)),
          ],
        ),
        actions: [
          Consumer<TradingProvider>(
            builder: (context, trading, _) {
              return Switch(
                value: trading.isMonitoring,
                onChanged: (value) async {
                  final authProvider = context.read<AuthProvider>();
                  if (authProvider.apiService == null) return;

                  if (value) {
                    await trading.startMonitoring(authProvider.apiService!);
                  } else {
                    trading.stopMonitoring();
                  }
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStrategiesTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStrategyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStrategiesTab() {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        if (trading.strategies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_chart,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Trading Strategies',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first strategy to start automated trading',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _showAddStrategyDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Strategy'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: trading.strategies.length,
          itemBuilder: (context, index) {
            final strategy = trading.strategies[index];
            return StrategyCard(
              strategy: strategy,
              onToggle: () => trading.toggleStrategy(strategy.id),
              onEdit: () => _showEditStrategyDialog(strategy),
              onDelete: () => _showDeleteConfirmation(strategy),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Trading Types
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trading Types',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Spot Trading'),
                      subtitle: const Text('Trade actual cryptocurrencies'),
                      value: trading.enableSpotTrading,
                      onChanged: trading.setSpotTradingEnabled,
                      secondary: const Icon(Icons.currency_bitcoin),
                    ),
                    SwitchListTile(
                      title: const Text('Futures Trading'),
                      subtitle: const Text('Trade with leverage'),
                      value: trading.enableFuturesTrading,
                      onChanged: trading.setFuturesTradingEnabled,
                      secondary: const Icon(Icons.trending_up),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Futures Settings (only show when futures trading is enabled)
            if (trading.enableFuturesTrading) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Futures Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Default Leverage'),
                        subtitle: Text('${trading.defaultLeverage.toStringAsFixed(1)}x'),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _showLeverageDialog(trading),
                      ),
                      SwitchListTile(
                        title: const Text('Isolated Margin'),
                        subtitle: const Text('Use isolated margin mode'),
                        value: trading.isolatedMargin,
                        onChanged: trading.setIsolatedMargin,
                        secondary: const Icon(Icons.account_balance),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Trading Parameters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trading Parameters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Default Trade Amount'),
                      subtitle: Text('${trading.defaultTradeAmount.toStringAsFixed(2)} USDT'),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _showTradeAmountDialog(trading),
                    ),
                    ListTile(
                      title: const Text('Monitoring Interval'),
                      subtitle: Text('${trading.monitoringInterval} seconds'),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _showMonitoringIntervalDialog(trading),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Total Strategies',
                            '${trading.strategies.length}',
                            Icons.add_chart,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Active Strategies',
                            '${trading.activeStrategies.length}',
                            Icons.play_arrow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Total Signals',
                            '${trading.signals.length}',
                            Icons.signal_cellular_alt,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Executed Trades',
                            '${trading.executedTrades.length}',
                            Icons.swap_horiz,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showAddStrategyDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddStrategyDialog(),
    );
  }

  void _showEditStrategyDialog(TradingStrategy strategy) {
    showDialog(
      context: context,
      builder: (context) => AddStrategyDialog(strategy: strategy),
    );
  }

  void _showDeleteConfirmation(TradingStrategy strategy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Strategy'),
        content: Text('Are you sure you want to delete "${strategy.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TradingProvider>().removeStrategy(strategy.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTradeAmountDialog(TradingProvider trading) {
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
              if (amount != null && amount > 0) {
                trading.setDefaultTradeAmount(amount);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMonitoringIntervalDialog(TradingProvider trading) {
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
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLeverageDialog(TradingProvider trading) {
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