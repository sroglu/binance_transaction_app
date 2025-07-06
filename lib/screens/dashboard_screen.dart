import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/trading_provider.dart';
import '../providers/balance_provider.dart';
import '../models/trading_strategy.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  final NumberFormat _percentFormat = NumberFormat.percentPattern();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Consumer<TradingProvider>(
            builder: (context, trading, _) {
              return IconButton(
                icon: Icon(
                  trading.isMonitoring ? Icons.pause : Icons.play_arrow,
                  color: trading.isMonitoring ? Colors.red : Colors.green,
                ),
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  if (authProvider.apiService == null) return;

                  if (trading.isMonitoring) {
                    trading.stopMonitoring();
                  } else {
                    await trading.startMonitoring(authProvider.apiService!);
                  }
                },
                tooltip: trading.isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountSummary(),
              const SizedBox(height: 24),
              _buildTradingStatus(),
              const SizedBox(height: 24),
              _buildActiveStrategies(),
              const SizedBox(height: 24),
              _buildRecentSignals(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSummary() {
    return Consumer<BalanceProvider>(
      builder: (context, balance, _) {
        final totalBalance = balance.getTotalBalanceInUSDT();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Account Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          _currencyFormat.format(totalBalance),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Assets',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          '${balance.nonZeroBalances.length}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (balance.lastUpdate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: ${DateFormat('MMM dd, HH:mm').format(balance.lastUpdate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTradingStatus() {
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
                      'Trading Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: trading.isMonitoring ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trading.isMonitoring ? 'ACTIVE' : 'INACTIVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusItem(
                        'Active Strategies',
                        '${trading.activeStrategies.length}',
                        Icons.add_chart,
                      ),
                    ),
                    Expanded(
                      child: _buildStatusItem(
                        'Total Signals',
                        '${trading.signals.length}',
                        Icons.signal_cellular_alt,
                      ),
                    ),
                    Expanded(
                      child: _buildStatusItem(
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
        );
      },
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
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

  Widget _buildActiveStrategies() {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        final activeStrategies = trading.activeStrategies;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.add_chart,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Active Strategies',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (activeStrategies.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No active strategies',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Go to Trading tab to create strategies',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                else
                  ...activeStrategies.take(3).map((strategy) => _buildStrategyItem(strategy)),
                if (activeStrategies.length > 3) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '+${activeStrategies.length - 3} more strategies',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStrategyItem(TradingStrategy strategy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '${strategy.symbol} • ${strategy.type.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (strategy.lastTriggered != null)
            Text(
              DateFormat('HH:mm').format(strategy.lastTriggered!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSignals() {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        final recentSignals = trading.signals.take(5).toList();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.signal_cellular_alt,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Signals',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    if (trading.signals.isNotEmpty)
                      TextButton(
                        onPressed: trading.clearSignals,
                        child: const Text('Clear All'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recentSignals.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.signal_cellular_off,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No signals yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                else
                  ...recentSignals.map((signal) => _buildSignalItem(signal)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignalItem(TradingSignal signal) {
    final actionColor = signal.action == TradingAction.buy
        ? Colors.green
        : signal.action == TradingAction.sell
            ? Colors.red
            : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: actionColor.withOpacity(0.3)),
            ),
            child: Text(
              signal.action.name.toUpperCase(),
              style: TextStyle(
                color: actionColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.symbol,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  'Price: ${_currencyFormat.format(signal.price)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('HH:mm').format(signal.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    final authProvider = context.read<AuthProvider>();
    final balanceProvider = context.read<BalanceProvider>();
    
    if (authProvider.apiService != null) {
      await balanceProvider.refreshAll(authProvider.apiService!);
    }
  }
}