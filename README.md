# Binance Trading App

A cross-platform Flutter application for automated cryptocurrency trading on Binance using technical indicators.

## Features

### Core Features
- **Secure Authentication**: Login with Binance API credentials
- **Real-time Balance Monitoring**: Track your portfolio value and individual asset balances
- **Automated Trading Strategies**: Create and manage trading strategies based on technical indicators
- **Trade History**: View detailed trade history with P&L calculations
- **Cross-platform**: Works on iOS, Android, Windows, macOS, and Linux

### Trading Features
- **Spot Trading**: Trade actual cryptocurrencies
- **Futures Trading**: Trade with leverage (configurable)
- **Technical Indicators**:
  - MACD (Moving Average Convergence Divergence)
  - RSI (Relative Strength Index)
  - Bollinger Bands
  - EMA (Exponential Moving Average)
  - SMA (Simple Moving Average)

### Supported Trading Pairs
- **USD Pairs**: BTC/USDT, ETH/USDT, BNB/USDT, ADA/USDT, DOT/USDT, LINK/USDT, LTC/USDT, BCH/USDT
- **EUR Pairs**: BTC/EUR, ETH/EUR, BNB/EUR (for future use)

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Binance account with API access
- API keys with "Enable Spot & Margin Trading" permission

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd binance_transaction_app
```

2. Install dependencies:
```bash
fvm flutter pub get
```

3. Generate JSON serialization code:
```bash
fvm flutter packages pub run build_runner build
```

4. Run the app:
```bash
fvm flutter run
```

### Setting up Binance API

1. Go to [Binance.com](https://binance.com) → Account → API Management
2. Create a new API key
3. Enable "Enable Spot & Margin Trading"
4. **Important**: Do NOT enable withdrawals for security
5. Copy both API Key and Secret Key
6. For testing, use Binance Testnet first

## Usage

### Initial Setup
1. Launch the app
2. Enter your Binance API credentials
3. Toggle "Use Testnet" for safe testing
4. Click "Login"

### Creating Trading Strategies
1. Go to the "Trading" tab
2. Click the "+" button to add a new strategy
3. Choose your strategy type (MACD, RSI, etc.)
4. Select trading pair
5. Configure parameters
6. Enable "Auto Execute" if you want automatic trading
7. Save the strategy

### Monitoring
1. Toggle the monitoring switch in the Trading tab
2. The app will check your strategies at regular intervals
3. View signals and executed trades in the Dashboard

### Safety Features
- **Testnet Support**: Test strategies with fake money
- **Manual Control**: Enable/disable strategies individually
- **Configurable Parameters**: Adjust technical indicator settings
- **Trade Amount Limits**: Set default trade amounts

## Technical Indicators

### MACD (Moving Average Convergence Divergence)
- **Fast Period**: Default 12
- **Slow Period**: Default 26
- **Signal Period**: Default 9
- **Signal**: Buy when MACD crosses above signal line, sell when below

### RSI (Relative Strength Index)
- **Period**: Default 14
- **Oversold Level**: Default 30
- **Overbought Level**: Default 70
- **Signal**: Buy when RSI crosses above oversold, sell when crosses below overbought

### Bollinger Bands
- **Period**: Default 20
- **Standard Deviations**: Default 2.0
- **Signal**: Buy when price touches lower band, sell when touches upper band

### EMA/SMA Crossover
- **Short Period**: Default 12
- **Long Period**: Default 26
- **Signal**: Buy when short MA crosses above long MA, sell when crosses below

## Configuration

### Trading Settings
- **Spot Trading**: Enable/disable spot trading
- **Futures Trading**: Enable/disable futures trading with leverage
- **Default Trade Amount**: Amount in USDT for each trade
- **Monitoring Interval**: How often to check strategies (seconds)

### Futures Settings (when enabled)
- **Default Leverage**: 1x to 125x leverage
- **Isolated Margin**: Use isolated margin mode

## Security

- API keys are stored securely using Flutter Secure Storage
- No withdrawal permissions required
- Testnet support for safe testing
- Local strategy storage

## Disclaimer

**⚠️ Important Risk Warning:**

- Cryptocurrency trading involves substantial risk of loss
- Past performance does not guarantee future results
- Never trade with money you cannot afford to lose
- Always test strategies on testnet first
- High leverage increases both profits and losses
- The developers are not responsible for any trading losses

## Support

For issues and questions:
1. Check the in-app help section
2. Test with Binance Testnet first
3. Verify API key permissions
4. Ensure stable internet connection

## License

This project is licensed under the MIT License - see the LICENSE file for details.
