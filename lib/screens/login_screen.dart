import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/debug_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _isTestnet = false;
  bool _obscureSecret = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _apiKeyController.text.trim(),
      _secretKeyController.text.trim(),
      isTestnet: _isTestnet,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _runDiagnostics() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing connection...'),
          ],
        ),
      ),
    );

    try {
      final results = await DebugHelper.diagnoseConnection(isTestnet: _isTestnet);
      final report = DebugHelper.formatDiagnosisResults(results);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Test Results'),
            content: SingleChildScrollView(
              child: Text(
                report,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: report));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test results copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Test Failed'),
            content: Text('Error: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40), // Add top spacing
                // Logo and title
                Icon(
                  Icons.currency_bitcoin,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Binance Trading App',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your Binance API credentials to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // API Key field
                TextFormField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    hintText: 'Enter your Binance API key',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'API Key is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Secret Key field
                TextFormField(
                  controller: _secretKeyController,
                  obscureText: _obscureSecret,
                  decoration: InputDecoration(
                    labelText: 'Secret Key',
                    hintText: 'Enter your Binance secret key',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureSecret ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureSecret = !_obscureSecret;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Secret Key is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Testnet toggle
                Card(
                  child: SwitchListTile(
                    title: const Text('Use Testnet'),
                    subtitle: const Text('Enable for testing with fake money'),
                    value: _isTestnet,
                    onChanged: (value) {
                      setState(() {
                        _isTestnet = value;
                      });
                    },
                    secondary: Icon(
                      _isTestnet ? Icons.bug_report : Icons.public,
                      color: _isTestnet ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Login button
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return FilledButton(
                      onPressed: auth.isLoading ? null : _login,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Debug button
                OutlinedButton.icon(
                  onPressed: _runDiagnostics,
                  icon: const Icon(Icons.network_check),
                  label: const Text('Test Connection'),
                ),
                const SizedBox(height: 24),

                // Help text
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How to get API keys:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Go to Binance.com → Account → API Management\n'
                          '2. Create a new API key\n'
                          '3. Enable "Enable Spot & Margin Trading"\n'
                          '4. Copy both API Key and Secret Key\n'
                          '5. Use Testnet for safe testing',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Add bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}