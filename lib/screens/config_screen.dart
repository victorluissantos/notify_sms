import 'package:flutter/material.dart';
import '../models/sms_config.dart';
import '../services/config_service.dart';
import '../services/sms_service.dart';
import '../services/real_sms_service.dart';
import '../constants/index.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _bearerTokenController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedSeconds = 10;

  final List<int> _secondsOptions = List.generate(10, (index) => (index + 1) * 10);

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await ConfigService.loadConfig();
    if (config != null) {
      setState(() {
        _urlController.text = config.url;
        _bearerTokenController.text = config.bearerToken;
        _userController.text = config.user;
        _passwordController.text = config.password;
        _selectedSeconds = config.intervalSeconds;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      final config = SMSConfig(
        url: _urlController.text.trim(),
        bearerToken: _bearerTokenController.text.trim(),
        user: _userController.text.trim(),
        password: _passwordController.text.trim(),
        intervalSeconds: _selectedSeconds,
      );

      await ConfigService.saveConfig(config);
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _testConnection() async {
    if (_urlController.text.trim().isEmpty) {
      _showMessage('Por favor, insira uma URL primeiro');
      return;
    }

    try {
      final config = SMSConfig(
        url: _urlController.text.trim(),
        bearerToken: _bearerTokenController.text.trim(),
        user: _userController.text.trim(),
        password: _passwordController.text.trim(),
        intervalSeconds: _selectedSeconds,
      );

      _showMessage('Testando conexão...');
      
      final isConnected = await SMSService.testConnection(config);
      
      if (isConnected) {
        _showMessage('✅ Conexão bem-sucedida!');
      } else {
        _showMessage('❌ Falha na conexão. Verifique a URL e sua internet.');
      }
    } catch (e) {
      _showMessage('❌ Erro: $e');
    }
  }

  Future<void> _checkSMSPermissions() async {
    try {
      _showMessage('🔍 Verificando permissões SMS...');
      
      // Verifica status atual das permissões
      final hasPermissions = await RealSMSService.hasPermissions();
      
      if (hasPermissions) {
        final deviceInfo = await RealSMSService.getDeviceInfo();
        _showMessage('✅ Permissões OK! ${deviceInfo['smsCapability']}');
      } else {
        _showMessage('❌ Sem permissões. Solicitando...');
        
        // Solicita permissões
        final granted = await RealSMSService.requestPermissions();
        
        // Aguarda um pouco para o sistema processar
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Verifica novamente após solicitar
        final finalCheck = await RealSMSService.hasPermissions();
        
        if (finalCheck) {
          final deviceInfo = await RealSMSService.getDeviceInfo();
          _showMessage('✅ Permissões concedidas! ${deviceInfo['smsCapability']}');
        } else {
          _showMessage('❌ Permissões negadas. Verifique nas configurações do app.');
        }
      }
    } catch (e) {
      _showMessage('❌ Erro: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL da API',
                  hintText: 'https://exemplo.com/api/sms',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira a URL';
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.hasScheme) {
                    return 'Por favor, insira uma URL válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bearerTokenController,
                decoration: const InputDecoration(
                  labelText: 'Bearer Token (opcional)',
                  hintText: 'Token de autenticação',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Usuário (opcional)',
                  hintText: 'Nome do usuário',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha (opcional)',
                  hintText: 'Senha do usuário',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _selectedSeconds,
                decoration: const InputDecoration(
                  labelText: 'Intervalo (segundos)',
                  border: OutlineInputBorder(),
                ),
                items: _secondsOptions.map((seconds) {
                  return DropdownMenuItem(
                    value: seconds,
                    child: Text('$seconds segundos'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeconds = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _testConnection,
                      style: AppButtons.primary,
                      icon: const Icon(Icons.wifi, size: AppButtons.iconSize),
                      label: const Text(
                        'Testar Conexão',
                        style: TextStyle(fontSize: AppButtons.fontSize, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(width: AppButtons.buttonSpacing),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _checkSMSPermissions,
                      style: AppButtons.primary,
                      icon: const Icon(Icons.sms, size: AppButtons.iconSize),
                      label: const Text(
                        'Permissões SMS',
                        style: TextStyle(fontSize: AppButtons.fontSize, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveConfig,
                      style: AppButtons.success,
                      icon: const Icon(Icons.save, size: AppButtons.iconSize),
                      label: const Text(
                        'Salvar',
                        style: TextStyle(fontSize: AppButtons.fontSize, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _bearerTokenController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
