import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'sms_service.dart';
import '../models/sms_config.dart';
import '../models/sms_queue_item.dart';

class SMSBackgroundService {
  static const MethodChannel _channel = MethodChannel('sms_background_service');
  static Timer? _timer;
  static bool _isRunning = false;
  
  // Configuração atual
  static String _url = '';
  static String _bearerToken = '';
  static String _username = '';
  static String _password = '';
  static int _interval = 10;
  
  // Status do serviço
  static bool get isRunning => _isRunning;
  
  // Inicializa o serviço
  static Future<void> initialize() async {
    try {
      // Configura o canal de comunicação
      _channel.setMethodCallHandler(_handleMethodCall);
      print('DEBUG: SMSBackgroundService inicializado');
    } catch (e) {
      print('DEBUG: Erro ao inicializar SMSBackgroundService: $e');
    }
  }
  
  // Configura os parâmetros do serviço
  static void configure({
    required String url,
    String bearerToken = '',
    String username = '',
    String password = '',
    required int interval,
  }) {
    _url = url;
    _bearerToken = bearerToken;
    _username = username;
    _password = password;
    _interval = interval;
    
    print('DEBUG: SMSBackgroundService configurado:');
    print('DEBUG: URL: $_url');
    print('DEBUG: Intervalo: ${_interval}s');
  }
  
  // Inicia o serviço
  static Future<bool> start() async {
    try {
      if (_isRunning) {
        print('DEBUG: Serviço já está rodando');
        return true;
      }
      
      // Verifica permissões
      if (!await _checkPermissions()) {
        print('DEBUG: Permissões insuficientes');
        return false;
      }
      
      // Inicia o serviço nativo Android
      final result = await _channel.invokeMethod('startForegroundService');
      
      if (result == true) {
        _isRunning = true;
        _startSMSTimer();
        print('DEBUG: SMSBackgroundService iniciado com sucesso');
        return true;
      } else {
        print('DEBUG: Falha ao iniciar serviço nativo');
        return false;
      }
      
    } catch (e) {
      print('DEBUG: Erro ao iniciar SMSBackgroundService: $e');
      return false;
    }
  }
  
  // Para o serviço
  static Future<bool> stop() async {
    try {
      if (!_isRunning) {
        print('DEBUG: Serviço não está rodando');
        return true;
      }
      
      // Para o timer
      _stopSMSTimer();
      
      // Para o serviço nativo Android
      final result = await _channel.invokeMethod('stopForegroundService');
      
      if (result == true) {
        _isRunning = false;
        print('DEBUG: SMSBackgroundService parado com sucesso');
        return true;
      } else {
        print('DEBUG: Falha ao parar serviço nativo');
        return false;
      }
      
    } catch (e) {
      print('DEBUG: Erro ao parar SMSBackgroundService: $e');
      return false;
    }
  }
  
  // Inicia o timer para envio de SMS
  static void _startSMSTimer() {
    _stopSMSTimer(); // Para timer anterior se existir
    
    _timer = Timer.periodic(Duration(seconds: _interval), (timer) {
      _processSMSQueue();
    });
    
    print('DEBUG: Timer de SMS iniciado - intervalo: ${_interval}s');
  }
  
  // Para o timer
  static void _stopSMSTimer() {
    _timer?.cancel();
    _timer = null;
    print('DEBUG: Timer de SMS parado');
  }
  
  // Processa a fila de SMS
  static Future<void> _processSMSQueue() async {
    try {
      print('DEBUG: Processando fila de SMS...');
      
      // Cria configuração com os parâmetros salvos
      final config = SMSConfig(
        url: _url,
        bearerToken: _bearerToken,
        user: _username,
        password: _password,
        intervalSeconds: _interval,
      );
      
      print('DEBUG: Consumindo fila de SMS da API: $_url');
      
      // Consome um item da fila usando o SMSService real
      final queueItem = await SMSService.consumeQueue(config);
      
      if (queueItem != null) {
        print('DEBUG: Item encontrado na fila: ${queueItem.number}');
        print('DEBUG: Status: ${queueItem.status}');
        print('DEBUG: Mensagem: ${queueItem.message}');
        
        // Valida o número antes de enviar
        if (queueItem.number.trim().isEmpty || queueItem.number.length < 10) {
          print('DEBUG: Número inválido - ${queueItem.number}');
          return;
        }
        
        // Envia o SMS usando o SMSService real
        print('DEBUG: Enviando SMS...');
        final result = await SMSService.sendSMS(config, queueItem);
        
        if (result.success) {
          print('DEBUG: SMS enviado com sucesso para ${queueItem.number}');
        } else {
          print('DEBUG: ERRO ao enviar SMS: ${result.message}');
        }
      } else {
        print('DEBUG: Fila vazia ou número inválido - nenhum SMS para enviar');
      }
      
    } catch (e) {
      print('DEBUG: Erro ao processar fila de SMS: $e');
    }
  }
  
  // Verifica permissões
  static Future<bool> _checkPermissions() async {
    try {
      final smsStatus = await Permission.sms.status;
      return smsStatus.isGranted;
    } catch (e) {
      print('DEBUG: Erro ao verificar permissões: $e');
      return false;
    }
  }
  
  // Manipula chamadas do método nativo
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onServiceStarted':
        print('DEBUG: Serviço nativo iniciado');
        return true;
        
      case 'onServiceStopped':
        print('DEBUG: Serviço nativo parado');
        _isRunning = false;
        _stopSMSTimer();
        return true;
        
      default:
        print('DEBUG: Método não implementado: ${call.method}');
        return false;
    }
  }
  
  // Limpa recursos
  static void dispose() {
    _stopSMSTimer();
    _isRunning = false;
    print('DEBUG: SMSBackgroundService disposto');
  }
}
