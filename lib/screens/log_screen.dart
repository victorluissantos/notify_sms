import 'dart:async';
import 'package:flutter/material.dart';
import 'config_screen.dart';
import '../services/sms_service.dart';
import '../services/config_service.dart';
import '../services/sms_background_service.dart';
import '../models/sms_config.dart';
import '../models/sms_queue_item.dart';
import '../constants/index.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _addLog('Aplicativo iniciado');
    
    // Inicializa o serviço de SMS em background
    SMSBackgroundService.initialize();
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logs.add('[$timestamp] $message');
    });
    
    // Auto-scroll para o final
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startSMS() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _addLog('Iniciando serviço de SMS em background...');

    try {
      final config = await ConfigService.loadConfig();
      if (config == null) {
        _addLog('ERRO: Configurações não encontradas. Configure primeiro.');
        setState(() {
          _isRunning = false;
        });
        return;
      }

      _addLog('Configurações carregadas: ${config.url}');
      
      // Configura o serviço em background
      SMSBackgroundService.configure(
        url: config.url,
        bearerToken: config.bearerToken,
        username: config.user,
        password: config.password,
        interval: config.intervalSeconds,
      );
      
      // Inicia o serviço em background
      final success = await SMSBackgroundService.start();
      
      if (success) {
        _addLog('Serviço em background iniciado com sucesso!');
        _addLog('SMS será enviado a cada ${config.intervalSeconds} segundos');
        _addLog('App pode ser minimizado - serviço continua rodando');
      } else {
        _addLog('ERRO: Falha ao iniciar serviço em background');
        setState(() {
          _isRunning = false;
        });
      }
      
    } catch (e) {
      _addLog('ERRO ao iniciar: $e');
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _sendSMS(SMSConfig config) async {
    try {
      _addLog('Consumindo fila de SMS...');
      
      // Consome um item da fila
      final queueItem = await SMSService.consumeQueue(config);
      
      if (queueItem != null) {
        _addLog('Item encontrado na fila: ${queueItem.number}');
        _addLog('Status: ${queueItem.status}');
        _addLog('Mensagem: ${queueItem.message}');
        
        // Valida o número antes de enviar
        if (queueItem.number.trim().isEmpty || queueItem.number.length < 10) {
          _addLog('ERRO: Número inválido - ${queueItem.number}');
          return;
        }
        
        // Envia o SMS
        _addLog('Enviando SMS...');
        final result = await SMSService.sendSMS(config, queueItem);
        
        if (result.success) {
          _addLog('SMS enviado com sucesso para ${queueItem.number}');
        } else {
          _addLog('ERRO ao enviar SMS: ${result.message}');
        }
      } else {
        _addLog('Fila vazia ou número inválido - nenhum SMS para enviar');
      }
    } catch (e) {
      _addLog('ERRO ao processar fila: $e');
    }
  }

  Future<void> _pauseSMS() async {
    if (!_isRunning) return;

    _addLog('Parando serviço de SMS em background...');
    
    // Para o serviço em background
    final success = await SMSBackgroundService.stop();
    
    if (success) {
      setState(() {
        _isRunning = false;
      });
      _addLog('Serviço de SMS em background parado com sucesso');
    } else {
      _addLog('ERRO: Falha ao parar serviço em background');
    }
  }

  void _navigateToConfig() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfigScreen()),
    ).then((_) {
      // Recarrega as configurações quando retorna
      _addLog('Configurações atualizadas');
    });
  }
  
  void _clearLog() {
    setState(() {
      _logs.clear();
    });
    _addLog('Log limpo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notify SMS'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Área de logs
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list_alt, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Log de Atividades',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _logs.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum log disponível',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                final isError = log.contains('ERRO');
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    log,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isError ? Colors.red : Colors.black87,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botão Limpar Log (centralizado acima do quadro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: TextButton.icon(
                  onPressed: _clearLog,
                  style: AppButtons.textButtonDanger,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'Limpar Log',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            
            // Botão Configurar (link)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: TextButton.icon(
                  onPressed: _navigateToConfig,
                  style: AppButtons.textButton,
                  icon: const Icon(Icons.settings, size: 20),
                  label: const Text(
                    'Configurar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            
            // Botões de controle (Iniciar e Pausar)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), // Padding extra na parte inferior
              child: Row(
                children: [
                  // Botão Iniciar
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRunning ? null : _startSMS,
                      style: AppButtons.success,
                      icon: const Icon(Icons.play_arrow, size: AppButtons.iconSize),
                      label: const Text(
                        'Iniciar',
                        style: TextStyle(fontSize: AppButtons.fontSize, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: AppButtons.buttonSpacing),
                  
                  // Botão Pausar
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseSMS : null,
                      style: AppButtons.danger,
                      icon: const Icon(Icons.stop, size: AppButtons.iconSize),
                      label: const Text(
                        'Pausar',
                        style: TextStyle(fontSize: AppButtons.fontSize, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}
