import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trading_strategy.dart';

class StrategyCard extends StatelessWidget {
  final TradingStrategy strategy;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StrategyCard({
    super.key,
    required this.strategy,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and toggle
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strategy.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStrategyTypeColor(strategy.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStrategyTypeColor(strategy.type).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              strategy.type.name.toUpperCase(),
                              style: TextStyle(
                                color: _getStrategyTypeColor(strategy.type),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            strategy.symbol,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: strategy.isActive,
                  onChanged: (_) => onToggle(),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Strategy parameters
            _buildParametersSection(context),
            
            const SizedBox(height: 12),
            
            // Status and last triggered
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: strategy.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    strategy.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (strategy.lastTriggered != null)
                  Text(
                    'Last: ${DateFormat('MMM dd, HH:mm').format(strategy.lastTriggered!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametersSection(BuildContext context) {
    final parameters = strategy.parameters;
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parameters',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: _buildParameterWidgets(context, parameters),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParameterWidgets(BuildContext context, Map<String, dynamic> parameters) {
    final widgets = <Widget>[];
    
    switch (strategy.type) {
      case TradingStrategyType.macd:
        widgets.addAll([
          _buildParameterItem(context, 'Fast', '${parameters['fast_period'] ?? 12}'),
          _buildParameterItem(context, 'Slow', '${parameters['slow_period'] ?? 26}'),
          _buildParameterItem(context, 'Signal', '${parameters['signal_period'] ?? 9}'),
        ]);
        break;
        
      case TradingStrategyType.rsi:
        widgets.addAll([
          _buildParameterItem(context, 'Period', '${parameters['period'] ?? 14}'),
          _buildParameterItem(context, 'Oversold', '${parameters['oversold_level'] ?? 30}'),
          _buildParameterItem(context, 'Overbought', '${parameters['overbought_level'] ?? 70}'),
        ]);
        break;
        
      case TradingStrategyType.bollinger:
        widgets.addAll([
          _buildParameterItem(context, 'Period', '${parameters['period'] ?? 20}'),
          _buildParameterItem(context, 'Std Dev', '${parameters['std_dev'] ?? 2.0}'),
        ]);
        break;
        
      case TradingStrategyType.ema:
      case TradingStrategyType.sma:
        widgets.addAll([
          _buildParameterItem(context, 'Short', '${parameters['short_period'] ?? 12}'),
          _buildParameterItem(context, 'Long', '${parameters['long_period'] ?? 26}'),
        ]);
        break;
    }
    
    // Add auto-execute status
    if (parameters['auto_execute'] == true) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: const Text(
            'AUTO',
            style: TextStyle(
              color: Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }

  Widget _buildParameterItem(BuildContext context, String label, String value) {
    return Text(
      '$label: $value',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Color _getStrategyTypeColor(TradingStrategyType type) {
    switch (type) {
      case TradingStrategyType.macd:
        return Colors.blue;
      case TradingStrategyType.rsi:
        return Colors.orange;
      case TradingStrategyType.bollinger:
        return Colors.purple;
      case TradingStrategyType.ema:
        return Colors.green;
      case TradingStrategyType.sma:
        return Colors.teal;
    }
  }
}