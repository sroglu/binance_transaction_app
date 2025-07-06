import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/balance_provider.dart';
import '../models/account_info.dart';
import '../models/trade.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  final NumberFormat _numberFormat = NumberFormat('#,##0.########');
  String _selectedSymbol = 'BTCUSDT';

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
        title: const Text('Balance & Trades'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Balance', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Trade History', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBalanceTab(),
          _buildTradeHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildBalanceTab() {
    return Consumer<BalanceProvider>(
      builder: (context, balance, _) {
        if (balance.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (balance.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading balance',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  balance.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _refreshData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTotalBalanceCard(balance),
              const SizedBox(height: 16),
              _buildBalanceList(balance),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalBalanceCard(BalanceProvider balance) {
    final totalBalance = balance.getTotalBalanceInUSDT();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Total Portfolio Value',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _currencyFormat.format(totalBalance),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            if (balance.lastUpdate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateFormat('MMM dd, yyyy HH:mm').format(balance.lastUpdate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceList(BalanceProvider balance) {
    final nonZeroBalances = balance.nonZeroBalances;
    
    if (nonZeroBalances.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No Assets Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your portfolio is empty',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Assets (${nonZeroBalances.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...nonZeroBalances.map((assetBalance) => _buildBalanceItem(assetBalance, balance)),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(Balance assetBalance, BalanceProvider balance) {
    final price = balance.getAssetPrice(assetBalance.asset);
    final totalValue = assetBalance.totalAmount * price;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          assetBalance.asset.substring(0, assetBalance.asset.length > 3 ? 3 : assetBalance.asset.length),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(
        assetBalance.asset,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Free: ${_numberFormat.format(assetBalance.freeAmount)}'),
          if (assetBalance.lockedAmount > 0)
            Text('Locked: ${_numberFormat.format(assetBalance.lockedAmount)}'),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _currencyFormat.format(totalValue),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (assetBalance.asset != 'USDT')
            Text(
              _currencyFormat.format(price),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildTradeHistoryTab() {
    return Consumer<BalanceProvider>(
      builder: (context, balance, _) {
        return Column(
          children: [
            // Symbol selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedSymbol,
                decoration: const InputDecoration(
                  labelText: 'Trading Pair',
                  border: OutlineInputBorder(),
                ),
                items: ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'DOTUSDT', 'BTCEUR', 'ETHEUR', 'BNBEUR']
                    .map((symbol) => DropdownMenuItem(
                          value: symbol,
                          child: Text(symbol),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSymbol = value;
                    });
                    _loadTradeHistory();
                  }
                },
              ),
            ),
            
            // Trade history list
            Expanded(
              child: _buildTradeHistoryList(balance),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTradeHistoryList(BalanceProvider balance) {
    final trades = balance.getTradesForSymbol(_selectedSymbol);
    
    if (balance.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (trades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Trade History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No trades found for $_selectedSymbol',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loadTradeHistory,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return _buildTradeItem(trade, balance);
      },
    );
  }

  Widget _buildTradeItem(TradeHistory trade, BalanceProvider balance) {
    final pnl = balance.calculatePnL(trade);
    final pnlColor = pnl > 0 ? Colors.green : pnl < 0 ? Colors.red : Colors.grey;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: trade.isBuyer ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          child: Icon(
            trade.isBuyer ? Icons.arrow_upward : Icons.arrow_downward,
            color: trade.isBuyer ? Colors.green : Colors.red,
          ),
        ),
        title: Row(
          children: [
            Text(
              trade.isBuyer ? 'BUY' : 'SELL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: trade.isBuyer ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Text(trade.symbol),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${_currencyFormat.format(trade.priceValue)}'),
            Text('Quantity: ${_numberFormat.format(trade.quantityValue)}'),
            Text('Total: ${_currencyFormat.format(trade.totalValue)}'),
            Text('Time: ${DateFormat('MMM dd, HH:mm').format(trade.tradeTime)}'),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'P&L',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              '${pnl >= 0 ? '+' : ''}${_currencyFormat.format(pnl)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: pnlColor,
              ),
            ),
          ],
        ),
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

  Future<void> _loadTradeHistory() async {
    final authProvider = context.read<AuthProvider>();
    final balanceProvider = context.read<BalanceProvider>();
    
    if (authProvider.apiService != null) {
      await balanceProvider.refreshTradeHistory(
        authProvider.apiService!,
        _selectedSymbol,
      );
    }
  }
}