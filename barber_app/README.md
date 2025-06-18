# Barber Shop App

Um aplicativo de agendamento para barbearias desenvolvido com Flutter.

## Funcionalidades

### Autenticação e Perfil
- **Login e Cadastro** de usuários
- **Perfil de Usuário** com informações pessoais
- **Gerenciamento de Conta** (alterar senha, excluir conta)
- **Persistência de Sessão** para manter o usuário logado

### Agendamentos
- **Catálogo de Serviços** com preços e descrições
- **Promoções Especiais** destacadas na interface
- **Seleção de Barbeiros** com fotos e avaliações
- **Agendamento Simplificado** com seleção de data e hora
- **Histórico de Agendamentos** (próximos, concluídos, cancelados)
- **Reagendamento e Cancelamento** de serviços

### Comunicação
- **Integração com WhatsApp** para confirmação do agendamento
- **Contato direto com o barbeiro** escolhido

### Interface
- **Design Premium** com tema escuro e detalhes dourados
- **Splash Screen** animada com logo da barbearia
- **Interface Responsiva** adaptada para diferentes tamanhos de tela
- **Animações Suaves** para melhor experiência do usuário

## Tecnologias Utilizadas

- **Flutter** para desenvolvimento cross-platform
- **Dart** como linguagem de programação
- **Shared Preferences** para armazenamento local
- **Intl** para formatação de datas
- **URL Launcher** para integração com WhatsApp
- **Provider** para gerenciamento de estado
- **Google Fonts** para tipografia personalizada

## Estrutura do Projeto

```
barber_app/
├── lib/
│   ├── models/         # Modelos de dados
│   │   ├── appointment.dart
│   │   ├── barber.dart
│   │   ├── service.dart
│   │   └── user.dart
│   ├── screens/        # Telas do aplicativo
│   │   ├── appointment_screen.dart
│   │   ├── appointments_screen.dart
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── signup_screen.dart
│   │   └── splash_screen.dart
│   ├── services/       # Serviços e lógica de negócio
│   │   ├── auth_service.dart
│   │   └── appointment_service.dart
│   ├── utils/          # Utilitários e constantes
│   │   ├── constants.dart
│   │   └── whatsapp_launcher.dart
│   ├── widgets/        # Componentes reutilizáveis
│   │   ├── barber_selection.dart
│   │   ├── promotion_card.dart
│   │   └── service_card.dart
│   └── main.dart       # Ponto de entrada do aplicativo
└── pubspec.yaml        # Dependências do projeto
```

## Próximos Passos

- **Backend Real**: Substituir os dados mockados por uma API real
- **Notificações Push**: Lembretes de agendamentos
- **Pagamentos In-App**: Permitir pagamento antecipado
- **Avaliações**: Sistema para avaliar barbeiros após o serviço
- **Modo Claro/Escuro**: Opção para alternar entre temas
- **Localização**: Encontrar barbearias próximas
- **Fidelidade**: Sistema de pontos para clientes frequentes

## Como Executar

1. Certifique-se de ter o Flutter instalado
2. Clone este repositório
3. Execute `flutter pub get` para instalar as dependências
4. Execute `flutter run` para iniciar o aplicativo

## Personalização

Para personalizar o aplicativo para sua barbearia:

1. Edite os dados de barbeiros e serviços em `lib/models/`
2. Ajuste as cores e estilos em `lib/utils/constants.dart`
3. Substitua os ícones por imagens reais da sua barbearia

## Requisitos

- Flutter 3.0.0 ou superior
- Dart 2.17.0 ou superior