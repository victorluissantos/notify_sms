import 'package:permission_handler/permission_handler.dart';
import 'package:another_telephony/telephony.dart';
import 'dart:io';

class RealSMSService {
  // Verifica e solicita permissões necessárias
  static Future<bool> requestPermissions() async {
    try {
      print('DEBUG: === SOLICITANDO PERMISSÕES ===');
      
      // Verifica status atual
      final currentStatus = await Permission.sms.status;
      print('DEBUG: Status atual das permissões SMS: $currentStatus');
      
      // Se já tem permissão, retorna true
      if (currentStatus.isGranted) {
        print('DEBUG: ✅ Permissões já concedidas');
        return true;
      }
      
      // Se está negado, solicita novamente
      if (currentStatus.isDenied) {
        print('DEBUG: 🔄 Permissões negadas, solicitando novamente...');
        final smsStatus = await Permission.sms.request();
        print('DEBUG: Resultado da solicitação: $smsStatus');
        return smsStatus.isGranted;
      }
      
      // Se está permanentemente negado, tenta abrir configurações
      if (currentStatus.isPermanentlyDenied) {
        print('DEBUG: ⚠️ Permissões permanentemente negadas, abrindo configurações...');
        final opened = await openAppSettings();
        print('DEBUG: Configurações abertas: $opened');
        return false; // Usuário precisa configurar manualmente
      }
      
      // Se está restrito, retorna false
      if (currentStatus.isRestricted) {
        print('DEBUG: ❌ Permissões restritas pelo sistema');
        return false;
      }
      
      print('DEBUG: ❌ Status de permissão desconhecido: $currentStatus');
      return false;
      
    } catch (e) {
      print('DEBUG: ❌ Erro ao solicitar permissões: $e');
      print('DEBUG: Tipo do erro: ${e.runtimeType}');
      return false;
    }
  }
  
  // Verifica se tem permissões
  static Future<bool> hasPermissions() async {
    try {
      final smsStatus = await Permission.sms.status;
      return smsStatus.isGranted;
    } catch (e) {
      print('DEBUG: Erro ao verificar permissões: $e');
      return false;
    }
  }
  
  // Envia SMS real usando another_telephony para envio DIRETO e AUTOMÁTICO
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      print('DEBUG: === INICIANDO ENVIO DE SMS ===');
      print('DEBUG: Número: $phoneNumber');
      print('DEBUG: Mensagem: $message');
      
      // Verifica permissões primeiro
      print('DEBUG: Verificando permissões...');
      if (!await hasPermissions()) {
        print('DEBUG: ❌ SEM PERMISSÕES para enviar SMS');
        return false;
      }
      print('DEBUG: ✅ PERMISSÕES OK para enviar SMS');
      
      print('DEBUG: Preparando envio AUTOMÁTICO de SMS para: $phoneNumber');
      print('DEBUG: Mensagem: $message');
      
      // Para Android, vamos usar another_telephony para envio DIRETO
      if (Platform.isAndroid) {
        print('DEBUG: 🟢 Plataforma Android detectada');
        print('DEBUG: Usando another_telephony para envio DIRETO e AUTOMÁTICO');
        
        try {
          // Cria instância do telephony
          print('DEBUG: Criando instância do Telephony...');
          final telephony = Telephony.instance;
          print('DEBUG: ✅ Instância do Telephony criada');
          
          // Verifica se tem permissões de telephony
          print('DEBUG: Verificando capacidade de SMS do dispositivo...');
          final hasTelephonyPermission = await telephony.isSmsCapable ?? false;
          print('DEBUG: Capacidade de SMS: $hasTelephonyPermission');
          
          if (!hasTelephonyPermission) {
            print('DEBUG: ❌ Dispositivo não tem capacidade de SMS');
            return false;
          }
          
          print('DEBUG: ✅ Dispositivo tem capacidade de SMS - enviando...');
          
          // Envia SMS DIRETAMENTE usando another_telephony
          print('DEBUG: 🚀 Chamando telephony.sendSms...');
          await telephony.sendSms(
            to: phoneNumber,
            message: message,
          );
          
          print('DEBUG: ✅ SMS enviado AUTOMATICAMENTE com sucesso!');
          
          return true;
          
        } catch (e) {
          print('DEBUG: ❌ Erro no envio direto via another_telephony: $e');
          print('DEBUG: Tipo do erro: ${e.runtimeType}');
          
          // Fallback: tenta envio via app padrão
          print('DEBUG: 🔄 Tentando fallback via app padrão...');
          
          try {
            print('DEBUG: Criando nova instância para fallback...');
            final telephonyFallback = Telephony.instance;
            print('DEBUG: 🚀 Chamando sendSmsByDefaultApp...');
            await telephonyFallback.sendSmsByDefaultApp(
              to: phoneNumber,
              message: message,
            );
            
            print('DEBUG: ✅ SMS enviado via app padrão com sucesso!');
            return true;
            
          } catch (e2) {
            print('DEBUG: ❌ Erro no fallback: $e2');
            print('DEBUG: Tipo do erro fallback: ${e2.runtimeType}');
            return false;
          }
        }
      } else {
        print('DEBUG: ❌ Plataforma não é Android');
      }
      
      return false;
      
    } catch (e) {
      print('DEBUG: ❌ Erro geral ao enviar SMS automaticamente: $e');
      print('DEBUG: Tipo do erro geral: ${e.runtimeType}');
      return false;
    }
  }
  
  // Obtém informações básicas do dispositivo
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final deviceInfo = <String, dynamic>{
        'platform': 'Android',
        'smsCapability': await hasPermissions() ? 'Disponível' : 'Não disponível',
      };
      
      return deviceInfo;
    } catch (e) {
      print('DEBUG: Erro ao obter informações do dispositivo: $e');
      return {};
    }
  }
}
