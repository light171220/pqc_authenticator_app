import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/qr_service.dart';
import '../services/storage_service.dart';
import '../widgets/custom_button.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _secretController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    try {
      final qrData = await QrService.scanQrCode(context);
      if (qrData != null) {
        final account = QrService.parseQrCode(qrData);
        if (account != null) {
          setState(() {
            _nameController.text = account.name;
            _issuerController.text = account.issuer;
            _secretController.text = account.secret;
          });
        } else {
          _showError('Invalid QR code format');
        }
      }
    } catch (e) {
      _showError('Failed to scan QR code');
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final account = Account(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        issuer: _issuerController.text.trim(),
        secret: _secretController.text.trim().toUpperCase(),
      );

      await StorageService.saveAccount(account);
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError('Failed to save account');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  String? _validateSecret(String? value) {
    if (value == null || value.isEmpty) {
      return 'Secret is required';
    }
    
    final cleanSecret = value.replaceAll(RegExp(r'[^A-Z2-7]'), '');
    if (cleanSecret.length < 16) {
      return 'Secret must be at least 16 characters';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scan QR Code',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan the QR code from your service provider',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        onPressed: _scanQrCode,
                        child: const Text('Scan QR Code'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Or enter manually',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(
                  labelText: 'Issuer',
                  hintText: 'e.g., Google, GitHub',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Issuer is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  hintText: 'e.g., john@example.com',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Account name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _secretController,
                decoration: const InputDecoration(
                  labelText: 'Secret Key',
                  hintText: 'Base32 encoded secret',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: _validateSecret,
                onChanged: (value) {
                  _secretController.text = value.toUpperCase();
                  _secretController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _secretController.text.length),
                  );
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _isLoading ? null : _saveAccount,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}