# Barber Shop App

Um aplicativo de agendamento para barbearias desenvolvido com Flutter.

## Funcionalidades

- **Splash Screen** com animação e logo da barbearia
- **Catálogo de Serviços** com preços e descrições
- **Promoções Especiais** destacadas na interface
- **Seleção de Barbeiros** com fotos e avaliações
- **Agendamento Simplificado** com seleção de data e hora
- **Integração com WhatsApp** para confirmação do agendamento
- **Interface Luxuosa** com tema escuro e detalhes dourados

## Estrutura do Projeto

```
barber_app/
├── assets/
│   └── images/         # Imagens e ícones do aplicativo
├── lib/
│   ├── models/         # Modelos de dados
│   ├── screens/        # Telas do aplicativo
│   ├── utils/          # Utilitários e constantes
│   ├── widgets/        # Componentes reutilizáveis
│   └── main.dart       # Ponto de entrada do aplicativo
└── pubspec.yaml        # Dependências do projeto
```

## Modelos de Dados

- **Barber**: Informações sobre os barbeiros disponíveis
- **Service**: Detalhes dos serviços oferecidos
- **Appointment**: Dados de agendamento

## Telas

- **SplashScreen**: Tela inicial com animação
- **HomeScreen**: Tela principal com serviços e promoções
- **AppointmentScreen**: Tela de agendamento

## Como Executar

1. Certifique-se de ter o Flutter instalado
2. Clone este repositório
3. Execute `flutter pub get` para instalar as dependências
4. Execute `flutter run` para iniciar o aplicativo

## Personalização

Para personalizar o aplicativo para sua barbearia:

1. Substitua as imagens em `assets/images/`
2. Edite os dados de barbeiros e serviços em `lib/models/`
3. Ajuste as cores e estilos em `lib/utils/constants.dart`

## Requisitos

- Flutter 3.0.0 ou superior
- Dart 2.17.0 ou superior

## Dependências Principais

- **flutter**: Framework UI
- **intl**: Formatação de datas
- **url_launcher**: Integração com WhatsApp
- **google_fonts**: Fontes personalizadas
- **lottie**: Animações

## Próximos Passos

- Implementar autenticação de usuários
- Adicionar histórico de agendamentos
- Implementar notificações de lembrete
- Adicionar sistema de avaliação
- Integrar com backend para persistência de dados