# Configurando Alertas de Orçamento no Firebase

Este guia explica como configurar alertas de orçamento no Firebase para evitar custos inesperados.

## 1. Acessar o Console do Firebase

1. Acesse o [Console do Firebase](https://console.firebase.google.com/)
2. Selecione seu projeto

## 2. Configurar Alertas de Orçamento

1. No menu lateral, clique em "Usage and Billing" (Uso e Faturamento)
2. Clique na aba "Budgets & alerts" (Orçamentos e alertas)
3. Clique em "Create budget" (Criar orçamento)

## 3. Definir Detalhes do Orçamento

1. **Nome do orçamento**: Digite um nome descritivo (ex: "Orçamento Mensal Barber App")
2. **Período do orçamento**: Selecione "Monthly recurring budget" (Orçamento mensal recorrente)
3. **Serviços**: Você pode escolher:
   - "All Firebase services" (Todos os serviços do Firebase)
   - Ou selecionar serviços específicos (Firestore, Authentication, Storage, etc.)
4. Clique em "Next" (Próximo)

## 4. Definir Valor do Orçamento

1. Digite o valor máximo que você deseja gastar por mês (ex: $10)
2. Clique em "Next" (Próximo)

## 5. Configurar Alertas

1. Configure alertas para diferentes percentuais do orçamento:
   - 50% do orçamento
   - 80% do orçamento
   - 100% do orçamento
2. Para cada alerta, você pode escolher quem receberá as notificações:
   - Gerentes de faturamento do projeto
   - Emails específicos
3. Clique em "Finish" (Concluir)

## 6. Verificar Configuração

1. Seu alerta de orçamento agora aparecerá na lista de orçamentos
2. Você receberá emails quando o uso atingir os percentuais configurados

## 7. Limites Gratuitos do Firebase

O Firebase oferece um plano gratuito (Spark) com os seguintes limites:

### Firestore
- 1 GB de armazenamento
- 50.000 leituras por dia
- 20.000 gravações por dia
- 20.000 exclusões por dia

### Authentication
- 50.000 autenticações por mês

### Storage
- 5 GB de armazenamento
- 1 GB de downloads por dia
- 20.000 uploads por dia

### Cloud Messaging
- Mensagens ilimitadas

## 8. Dicas para Economizar

1. **Otimize consultas ao Firestore**:
   - Use consultas com índices
   - Evite buscar documentos inteiros quando precisar apenas de alguns campos
   - Use paginação para grandes conjuntos de dados

2. **Reduza o tamanho das imagens**:
   - Comprima imagens antes de fazer upload
   - Use tamanhos apropriados para diferentes dispositivos

3. **Implemente cache local**:
   - Armazene dados frequentemente acessados localmente
   - Use o modo offline do Firestore

4. **Monitore o uso**:
   - Verifique regularmente o uso no console do Firebase
   - Use a tela de monitoramento de uso no aplicativo

5. **Limite funcionalidades em versões gratuitas**:
   - Restrinja uploads de imagens
   - Limite o número de agendamentos por usuário