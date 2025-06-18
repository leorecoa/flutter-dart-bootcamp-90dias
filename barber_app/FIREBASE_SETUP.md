# Configuração do Firebase para o Barber Shop App

Este guia explica como configurar o Firebase para o aplicativo Barber Shop.

## 1. Criar um projeto no Firebase

1. Acesse o [Console do Firebase](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Digite um nome para o projeto (ex: "Barber Shop App")
4. Siga as instruções para criar o projeto

## 2. Configurar o Firebase para Flutter

### Instalar a CLI do Firebase

```bash
npm install -g firebase-tools
```

### Fazer login no Firebase

```bash
firebase login
```

### Configurar o Flutter para usar o Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=seu-projeto-firebase
```

Este comando irá gerar o arquivo `firebase_options.dart` com as configurações corretas para o seu projeto.

## 3. Configurar o Firestore Database

1. No Console do Firebase, vá para "Firestore Database"
2. Clique em "Criar banco de dados"
3. Escolha o modo de inicialização (recomendado: modo de teste)
4. Selecione a região mais próxima de seus usuários
5. Clique em "Ativar"

### Criar coleções e documentos iniciais

#### Coleção: barbers

Crie alguns documentos de barbeiros com a seguinte estrutura:

```json
{
  "name": "Nome do Barbeiro",
  "rating": 4.5,
  "imageUrl": "URL da imagem (opcional)",
  "whatsapp": "+5511999999999",
  "specialties": ["Corte", "Barba", "Sobrancelha"],
  "available": true
}
```

#### Coleção: services

Crie alguns documentos de serviços com a seguinte estrutura:

```json
{
  "name": "Nome do Serviço",
  "description": "Descrição do serviço",
  "price": 50.0,
  "discountPrice": 40.0,
  "hasDiscount": true,
  "durationMinutes": 30,
  "imageUrl": "URL da imagem (opcional)",
  "isPromotion": false
}
```

## 4. Configurar o Firebase Authentication

1. No Console do Firebase, vá para "Authentication"
2. Clique em "Começar"
3. Na aba "Sign-in method", habilite "Email/senha"
4. Opcionalmente, habilite outros métodos de autenticação (Google, Facebook, etc.)

## 5. Configurar o Firebase Storage

1. No Console do Firebase, vá para "Storage"
2. Clique em "Começar"
3. Escolha o modo de inicialização (recomendado: modo de teste)
4. Clique em "Avançar" e depois em "Concluído"

## 6. Configurar o Firebase Cloud Messaging

1. No Console do Firebase, vá para "Cloud Messaging"
2. Siga as instruções para configurar o FCM para Android e iOS

## 7. Configurar as regras de segurança

### Regras do Firestore

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Autenticação necessária para todas as operações
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Usuários podem ler seus próprios dados
    match /users/{userId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
    
    // Barbeiros e serviços podem ser lidos por todos os usuários autenticados
    match /barbers/{barberId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    match /services/{serviceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Agendamentos podem ser lidos e criados pelos usuários
    match /appointments/{appointmentId} {
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true
      );
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && (
        resource.data.userId == request.auth.uid || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true
      );
    }
  }
}
```

### Regras do Storage

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /barbers/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    match /services/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

## 8. Atualizar o arquivo firebase_options.dart

Substitua o conteúdo do arquivo `lib/firebase_options.dart` com as configurações geradas pelo comando `flutterfire configure`.

## 9. Testar a conexão com o Firebase

Execute o aplicativo e verifique se a autenticação e o acesso ao Firestore estão funcionando corretamente.