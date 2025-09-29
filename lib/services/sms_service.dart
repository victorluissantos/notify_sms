import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sms_config.dart';
import '../models/sms_queue_item.dart';
import 'real_sms_service.dart';

class SMSResult {
  final bool success;
  final String message;

  SMSResult({required this.success, required this.message});
}

class SMSService {
  // Consome um item da fila de SMS
  static Future<SMSQueueItem?> consumeQueue(SMSConfig config) async {
    try {
      // Validação da URL (único campo obrigatório)
      if (config.url.isEmpty) {
        throw Exception('URL não configurada');
      }

      final uri = Uri.tryParse(config.url);
      if (uri == null) {
        throw Exception('URL inválida: ${config.url}');
      }

      // Monta headers dinamicamente baseado na configuração
      final headers = <String, String>{};
      
      // Sempre adiciona Content-Type para JSON
      headers['Content-Type'] = 'application/json';
      
      // Adiciona Authorization apenas se houver token
      if (config.bearerToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${config.bearerToken}';
        print('DEBUG: Usando autenticação Bearer Token');
      } else {
        print('DEBUG: Sem autenticação - apenas URL');
      }

      // Log da configuração atual
      print('DEBUG: === CONFIGURAÇÃO ATUAL ===');
      print('DEBUG: URL: ${config.url}');
      print('DEBUG: Bearer Token: ${config.bearerToken.isNotEmpty ? "Configurado" : "Não configurado"}');
      print('DEBUG: User: ${config.user.isNotEmpty ? "Configurado" : "Não configurado"}');
      print('DEBUG: Password: ${config.password.isNotEmpty ? "Configurado" : "Não configurado"}');
      print('DEBUG: Intervalo: ${config.intervalSeconds} segundos');
      print('DEBUG: Headers finais: $headers');

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('DEBUG: Status code: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');
      print('DEBUG: Response body bytes: ${response.bodyBytes}');

      if (response.statusCode == 200) {
        // Decodifica JSON com encoding UTF-8 para caracteres especiais
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Validação rigorosa: só retorna se houver número válido
        if (jsonResponse['number'] != null && 
            jsonResponse['number'].toString().trim().isNotEmpty &&
            jsonResponse['number'].toString().length >= 10) { // Número deve ter pelo menos 10 dígitos
          
          // Verifica se há outros campos obrigatórios (aceita tanto 'status' quanto 'situacao')
          if ((jsonResponse['status'] != null || jsonResponse['situacao'] != null) && 
              jsonResponse['msg'] != null) {
            return SMSQueueItem.fromJson(jsonResponse);
          }
        }
        
        return null; // Fila vazia ou número inválido
      } else {
        throw Exception('Erro HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Erro detalhado: $e');
      if (e.toString().contains('errno = 7')) {
        throw Exception('Erro de conectividade: Verifique sua conexão com a internet e se a URL está acessível');
      }
      throw Exception('Erro ao consumir fila: $e');
    }
  }

  // Envia SMS para um número específico
  static Future<SMSResult> sendSMS(SMSConfig config, SMSQueueItem queueItem) async {
    try {
      // Validação adicional antes de enviar
      print('DEBUG: === VALIDAÇÃO ANTES DO ENVIO ===');
      print('DEBUG: Número original: "${queueItem.number}"');
      print('DEBUG: Número após trim: "${queueItem.number.trim()}"');
      print('DEBUG: Tamanho do número: ${queueItem.number.length}');
      print('DEBUG: Tamanho após trim: ${queueItem.number.trim().length}');
      
      if (queueItem.number.trim().isEmpty || queueItem.number.length < 10) {
        print('DEBUG: ❌ VALIDAÇÃO DO NÚMERO FALHOU');
        print('DEBUG: - Vazio após trim: ${queueItem.number.trim().isEmpty}');
        print('DEBUG: - Tamanho < 10: ${queueItem.number.length < 10}');
        return SMSResult(
          success: false,
          message: 'Número de telefone inválido: ${queueItem.number}',
        );
      }
      print('DEBUG: ✅ VALIDAÇÃO DO NÚMERO OK');

      print('DEBUG: Mensagem original: "${queueItem.message}"');
      print('DEBUG: Mensagem após trim: "${queueItem.message.trim()}"');
      print('DEBUG: Tamanho da mensagem: ${queueItem.message.length}');
      print('DEBUG: Tamanho após trim: ${queueItem.message.trim().length}');
      
      if (queueItem.message.trim().isEmpty) {
        print('DEBUG: ❌ VALIDAÇÃO DA MENSAGEM FALHOU');
        print('DEBUG: - Mensagem vazia após trim: ${queueItem.message.trim().isEmpty}');
        return SMSResult(
          success: false,
          message: 'Mensagem vazia - SMS não enviado',
        );
      }
      print('DEBUG: ✅ VALIDAÇÃO DA MENSAGEM OK');

      print('DEBUG: === ENVIO REAL DE SMS ===');
      print('DEBUG: Número: ${queueItem.number}');
      print('DEBUG: Mensagem: ${queueItem.message}');
      
      // Verifica permissões primeiro
      if (!await RealSMSService.hasPermissions()) {
        print('DEBUG: Solicitando permissões...');
        final permissionsGranted = await RealSMSService.requestPermissions();
        if (!permissionsGranted) {
          return SMSResult(
            success: false,
            message: 'Permissões negadas - SMS não pode ser enviado',
          );
        }
      }
      
      // Obtém informações do dispositivo
      final deviceInfo = await RealSMSService.getDeviceInfo();
      print('DEBUG: Informações do dispositivo: $deviceInfo');
      
      // Envia o SMS real
      final smsSent = await RealSMSService.sendSMS(
        phoneNumber: queueItem.number,
        message: queueItem.message,
      );
      
      if (smsSent) {
        return SMSResult(
          success: true,
          message: 'SMS REAL enviado para ${queueItem.number} via chip do celular',
        );
      } else {
        return SMSResult(
          success: false,
          message: 'Falha ao enviar SMS real',
        );
      }
      
    } catch (e) {
      print('DEBUG: Erro ao enviar SMS real: $e');
      return SMSResult(
        success: false,
        message: 'Erro ao enviar SMS: $e',
      );
    }
  }



  static Future<bool> testConnection(SMSConfig config) async {
    try {
      if (config.url.isEmpty) {
        print('DEBUG: URL vazia');
        return false;
      }

      final uri = Uri.tryParse(config.url);
      if (uri == null) {
        print('DEBUG: URL inválida: ${config.url}');
        return false;
      }

      // Monta headers dinamicamente baseado na configuração
      final headers = <String, String>{};
      
      // Sempre adiciona Content-Type para JSON
      headers['Content-Type'] = 'application/json';
      
      // Adiciona Authorization apenas se houver token
      if (config.bearerToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${config.bearerToken}';
        print('DEBUG: Teste com autenticação Bearer Token');
      } else {
        print('DEBUG: Teste sem autenticação - apenas URL');
      }

      print('DEBUG: === TESTE DE CONEXÃO ===');
      print('DEBUG: URL: ${config.url}');
      print('DEBUG: Headers: $headers');
      print('DEBUG: URI parseado: $uri');

      try {
        final response = await http.get(
          uri,
          headers: headers,
        ).timeout(const Duration(seconds: 10));

        print('DEBUG: Teste de conexão - Status: ${response.statusCode}');
        print('DEBUG: Response headers: ${response.headers}');
        print('DEBUG: Response body: ${response.body}');
        
        return response.statusCode == 200 || response.statusCode == 201;
      } catch (e) {
        print('DEBUG: Erro específico no teste: $e');
        print('DEBUG: Tipo de erro: ${e.runtimeType}');
        rethrow;
      }
    } catch (e) {
      print('DEBUG: Erro no teste de conexão: $e');
      return false;
    }
  }
}
