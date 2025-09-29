# Notify SMS

Aplicativo Flutter para disparo automático de SMS via API.

## Funcionalidades

- **Tela de Configurações**: Configure URL da API, Bearer Token, usuário, senha e intervalo de disparo
- **Tela de Log**: Visualize logs em tempo real e controle o disparo de SMS
- **Sistema de Fila**: Consome automaticamente a fila de SMS da API
- **Disparo Automático**: Envio automático de SMS conforme intervalo configurado
- **Persistência**: Configurações salvas localmente no dispositivo
- **URL Padrão**: Configuração pré-preenchida para a API de fila

## Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/
│   └── sms_config.dart      # Modelo de configurações
├── screens/
│   ├── log_screen.dart      # Tela principal com logs e controles
│   └── config_screen.dart   # Tela de configurações
└── services/
    ├── config_service.dart  # Serviço de persistência
    └── sms_service.dart     # Serviço de envio de SMS
```

## Como Usar

1. **Primeira Execução**: Clique no botão "Configurar" para definir as configurações da API
2. **Configurações**:
   - URL da API (ex: https://exemplo.com/api/sms)
   - Bearer Token para autenticação
   - Usuário e senha
   - Intervalo de disparo (10 a 100 segundos)
3. **Disparo**: Use o botão "Iniciar" para começar o envio automático
4. **Controle**: Use "Pausar" para interromper e "Configurar" para alterar configurações

## Dependências

- `flutter`: SDK do Flutter
- `shared_preferences`: Persistência local de dados
- `http`: Requisições HTTP para API

## Executando o Projeto

```bash
# Instalar dependências
flutter pub get

# Executar em modo debug
flutter run

# Executar em modo release
flutter run --release
```

## Configuração da API

O aplicativo consome uma fila de SMS da API configurada pelo usuário e envia SMS automaticamente.

### Consumo da Fila (GET)
**URL:** Configurada pelo usuário na tela de configurações

**Resposta da API esperada:**
```json
{
  "status": "Pendente",
  "msg": "<Mensagem do SMS>",
  "number": "(41) 98765-4321"
}
```

### Envio de SMS (POST)
**Headers:**
- `Content-Type: application/json`
- `Authorization: Bearer {token}` (opcional)

**Body:**
```json
{
  "user": "<usuario>",
  "password": "<senha>",
  "number": "(41) 98765-4321",
  "message": "Seu Token de acesso: 42530",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## Suporte

Para dúvidas ou problemas, verifique os logs na tela principal do aplicativo.
