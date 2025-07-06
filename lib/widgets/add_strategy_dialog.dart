import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trading_strategy.dart';
import '../providers/trading_provider.dart';

class AddStrategyDialog extends StatefulWidget {
  final TradingStrategy? strategy;

  const AddStrategyDialog({super.key, this.strategy});

  @override
  State<AddStrategyDialog> createState() => _AddStrategyDialogState();
}

class _AddStrategyDialogState extends State<AddStrategyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  TradingStrategyType _selectedType = TradingStrategyType.macd;
  String _selectedSymbol = 'BTCUSDT';
  bool _autoExecute = false;
  
  // MACD parameters
  int _macdFastPeriod = 12;
  int _macdSlowPeriod = 26;
  int _macdSignalPeriod = 9;
  
  // RSI parameters
  int _rsiPeriod = 14;
  double _rsiOversoldLevel = 30.0;
  double _rsiOverboughtLevel = 70.0;
  
  // Bollinger Bands parameters
  int _bollingerPeriod = 20;
  double _bollingerStdDev = 2.0;
  
  // EMA/SMA parameters
  int _shortPeriod = 12;
  int _longPeriod = 26;

  final List<String> _availableSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'DOTUSDT',
    'LINKUSDT',
    'LTCUSDT',
    'BCHUSDT',
    // EUR pairs for future use
    'BTCEUR',
    'ETHEUR',
    'BNBEUR',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.strategy != null) {
      _loadExistingStrategy();
    } else {
      _nameController.text = 'MACD - Fast Buy and Sell';
    }
  }

  void _loadExistingStrategy() {
    final strategy = widget.strategy!;
    _nameController.text = strategy.name;
    _selectedType = strategy.type;
    _selectedSymbol = strategy.symbol;
    _autoExecute = strategy.parameters['auto_execute'] ?? false;
    
    switch (strategy.type) {
      case TradingStrategyType.macd:
        _macdFastPeriod = strategy.parameters['fast_period'] ?? 12;
        _macdSlowPeriod = strategy.parameters['slow_period'] ?? 26;
        _macdSignalPeriod = strategy.parameters['signal_period'] ?? 9;
        break;
      case TradingStrategyType.rsi:
        _rsiPeriod = strategy.parameters['period'] ?? 14;
        _rsiOversoldLevel = strategy.parameters['oversold_level'] ?? 30.0;
        _rsiOverboughtLevel = strategy.parameters['overbought_level'] ?? 70.0;
        break;
      case TradingStrategyType.bollinger:
        _bollingerPeriod = strategy.parameters['period'] ?? 20;
        _bollingerStdDev = strategy.parameters['std_dev'] ?? 2.0;
        break;
      case TradingStrategyType.ema:
      case TradingStrategyType.sma:
        _shortPeriod = strategy.parameters['short_period'] ?? 12;
        _longPeriod = strategy.parameters['long_period'] ?? 26;
        break;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.strategy == null ? 'Add Strategy' : 'Edit Strategy'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Strategy name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Strategy Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Strategy name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Strategy type
                DropdownButtonFormField<TradingStrategyType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Strategy Type',
                    border: OutlineInputBorder(),
                  ),
                  items: TradingStrategyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getStrategyDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                        _updateStrategyName();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Trading symbol
                DropdownButtonFormField<String>(
                  value: _selectedSymbol,
                  decoration: const InputDecoration(
                    labelText: 'Trading Pair',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableSymbols.map((symbol) {
                    return DropdownMenuItem(
                      value: symbol,
                      child: Text(symbol),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSymbol = value;
                        _updateStrategyName();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Auto-execute toggle
                SwitchListTile(
                  title: const Text('Auto Execute'),
                  subtitle: const Text('Automatically execute trades when signals are generated'),
                  value: _autoExecute,
                  onChanged: (value) {
                    setState(() {
                      _autoExecute = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Strategy-specific parameters
                _buildParametersSection(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveStrategy,
          child: Text(widget.strategy == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  Widget _buildParametersSection() {
    switch (_selectedType) {
      case TradingStrategyType.macd:
        return _buildMACDParameters();
      case TradingStrategyType.rsi:
        return _buildRSIParameters();
      case TradingStrategyType.bollinger:
        return _buildBollingerParameters();
      case TradingStrategyType.ema:
      case TradingStrategyType.sma:
        return _buildMovingAverageParameters();
    }
  }

  Widget _buildMACDParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MACD Parameters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _macdFastPeriod.toString(),
                decoration: const InputDecoration(
                  labelText: 'Fast Period',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _macdFastPeriod = int.tryParse(value) ?? 12;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: _macdSlowPeriod.toString(),
                decoration: const InputDecoration(
                  labelText: 'Slow Period',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _macdSlowPeriod = int.tryParse(value) ?? 26;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _macdSignalPeriod.toString(),
          decoration: const InputDecoration(
            labelText: 'Signal Period',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _macdSignalPeriod = int.tryParse(value) ?? 9;
          },
        ),
      ],
    );
  }

  Widget _buildRSIParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RSI Parameters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _rsiPeriod.toString(),
          decoration: const InputDecoration(
            labelText: 'Period',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _rsiPeriod = int.tryParse(value) ?? 14;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _rsiOversoldLevel.toString(),
                decoration: const InputDecoration(
                  labelText: 'Oversold Level',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _rsiOversoldLevel = double.tryParse(value) ?? 30.0;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: _rsiOverboughtLevel.toString(),
                decoration: const InputDecoration(
                  labelText: 'Overbought Level',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _rsiOverboughtLevel = double.tryParse(value) ?? 70.0;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBollingerParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bollinger Bands Parameters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _bollingerPeriod.toString(),
                decoration: const InputDecoration(
                  labelText: 'Period',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _bollingerPeriod = int.tryParse(value) ?? 20;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: _bollingerStdDev.toString(),
                decoration: const InputDecoration(
                  labelText: 'Standard Deviations',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _bollingerStdDev = double.tryParse(value) ?? 2.0;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMovingAverageParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_selectedType.name.toUpperCase()} Parameters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _shortPeriod.toString(),
                decoration: const InputDecoration(
                  labelText: 'Short Period',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _shortPeriod = int.tryParse(value) ?? 12;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: _longPeriod.toString(),
                decoration: const InputDecoration(
                  labelText: 'Long Period',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _longPeriod = int.tryParse(value) ?? 26;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getStrategyDisplayName(TradingStrategyType type) {
    switch (type) {
      case TradingStrategyType.macd:
        return 'MACD (Moving Average Convergence Divergence)';
      case TradingStrategyType.rsi:
        return 'RSI (Relative Strength Index)';
      case TradingStrategyType.bollinger:
        return 'Bollinger Bands';
      case TradingStrategyType.ema:
        return 'EMA (Exponential Moving Average)';
      case TradingStrategyType.sma:
        return 'SMA (Simple Moving Average)';
    }
  }

  void _updateStrategyName() {
    if (_nameController.text.isEmpty || 
        _nameController.text.contains('MACD') ||
        _nameController.text.contains('RSI') ||
        _nameController.text.contains('Bollinger') ||
        _nameController.text.contains('EMA') ||
        _nameController.text.contains('SMA')) {
      
      String baseName;
      switch (_selectedType) {
        case TradingStrategyType.macd:
          baseName = 'MACD - Fast Buy and Sell';
          break;
        case TradingStrategyType.rsi:
          baseName = 'RSI - Oversold/Overbought';
          break;
        case TradingStrategyType.bollinger:
          baseName = 'Bollinger - Band Bounce';
          break;
        case TradingStrategyType.ema:
          baseName = 'EMA - Crossover Strategy';
          break;
        case TradingStrategyType.sma:
          baseName = 'SMA - Crossover Strategy';
          break;
      }
      
      _nameController.text = '$baseName ($_selectedSymbol)';
    }
  }

  void _saveStrategy() {
    if (!_formKey.currentState!.validate()) return;

    final parameters = <String, dynamic>{
      'auto_execute': _autoExecute,
    };

    switch (_selectedType) {
      case TradingStrategyType.macd:
        parameters.addAll({
          'fast_period': _macdFastPeriod,
          'slow_period': _macdSlowPeriod,
          'signal_period': _macdSignalPeriod,
        });
        break;
      case TradingStrategyType.rsi:
        parameters.addAll({
          'period': _rsiPeriod,
          'oversold_level': _rsiOversoldLevel,
          'overbought_level': _rsiOverboughtLevel,
        });
        break;
      case TradingStrategyType.bollinger:
        parameters.addAll({
          'period': _bollingerPeriod,
          'std_dev': _bollingerStdDev,
        });
        break;
      case TradingStrategyType.ema:
      case TradingStrategyType.sma:
        parameters.addAll({
          'short_period': _shortPeriod,
          'long_period': _longPeriod,
        });
        break;
    }

    final strategy = TradingStrategy(
      id: widget.strategy?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      type: _selectedType,
      symbol: _selectedSymbol,
      isActive: widget.strategy?.isActive ?? false,
      parameters: parameters,
      createdAt: widget.strategy?.createdAt ?? DateTime.now(),
      lastTriggered: widget.strategy?.lastTriggered,
    );

    final tradingProvider = context.read<TradingProvider>();
    if (widget.strategy == null) {
      tradingProvider.addStrategy(strategy);
    } else {
      tradingProvider.updateStrategy(strategy);
    }

    Navigator.of(context).pop();
  }
}