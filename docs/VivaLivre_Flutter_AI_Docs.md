# VivaLivre — Documentação Técnica Completa para Desenvolvimento Flutter

> **Versão:** 2.0 | **Abril de 2026** | **Autor:** Gabriel José de Souza  
> **Este documento é otimizado para leitura por IA com o objetivo de desenvolver o app Flutter do VivaLivre do zero.**

---

## ÍNDICE RÁPIDO

1. [Visão Geral do Projeto](#1-visão-geral-do-projeto)
2. [Stack Tecnológico](#2-stack-tecnológico)
3. [Arquitetura do App Flutter](#3-arquitetura-do-app-flutter)
4. [Requisitos Funcionais](#4-requisitos-funcionais)
5. [Requisitos Não Funcionais](#5-requisitos-não-funcionais)
6. [Modelo de Dados (MongoDB)](#6-modelo-de-dados-mongodb)
7. [Estrutura de Telas e Navegação](#7-estrutura-de-telas-e-navegação)
8. [Casos de Uso Detalhados](#8-casos-de-uso-detalhados)
9. [Integrações Externas](#9-integrações-externas)
10. [Roadmap de Desenvolvimento (4 Sprints)](#10-roadmap-de-desenvolvimento-4-sprints)
11. [Métricas e KPIs](#11-métricas-e-kpis)
12. [Glossário](#12-glossário)

---

## 1. Visão Geral do Projeto

### O que é o VivaLivre

O **VivaLivre** é um aplicativo mobile nativo desenvolvido em **Flutter/Dart** voltado a portadores de **Doenças Inflamatórias Intestinais (DII)** — principalmente Doença de Crohn e Retocolite Ulcerativa — com objetivo de oferecer segurança, autonomia e qualidade de vida no dia a dia.

Há aproximadamente **200 mil brasileiros diagnosticados** com DII. Esses pacientes precisam de acesso urgente a banheiros e de ferramentas integradas de saúde. O VivaLivre resolve isso com três pilares:

1. **Mapa colaborativo de banheiros** — estilo Waze, validado pela comunidade, com GPS nativo.
2. **Controle de medicação com lembretes push** — cron jobs + Firebase Cloud Messaging.
3. **Histórico de sintomas com gráficos** — registro diário e exportação de relatório em PDF para o médico.

### Validação de Mercado

- 92% dos 45 portadores entrevistados consideram a solução útil
- 88% usariam diariamente
- 95% apontaram necessidade crítica de localizar banheiros via GPS
- NPS preliminar: **67** (excelente para fase de descoberta)
- 65% pagariam R$ 10–15/mês por versão premium

### Personas Principais

| Persona | Perfil | Necessidade Principal |
|---|---|---|
| **Maria** (32 anos) | Profissional com Retocolite Ativa | Encontrar banheiro urgente via GPS em qualquer lugar da cidade |
| **João** (45 anos) | Colaborador Comunitário com Crohn | Contribuir com dados de banheiros e validar informações da comunidade |
| **Dr. Roberto** (55 anos) | Gastroenterologista / Admin | Moderar conteúdo, acessar dados agregados de pacientes, painel web |

---

## 2. Stack Tecnológico

### Front-End (App Mobile + Painel Web)

| Camada | Tecnologia | Versão Mínima | Justificativa |
|---|---|---|---|
| Framework | **Flutter** | 3.x | Compilação nativa iOS + Android, 60fps, acesso direto ao GPS |
| Linguagem | **Dart** | 3.x | Tipagem forte, null safety, async/await nativo |
| Design System | Material 3 (Android) + Cupertino (iOS) | — | Experiência autêntica em cada plataforma |
| Gerenciamento de Estado | **BLoC** (flutter_bloc) | — | Separação clara entre UI e lógica de negócio |
| Painel Admin | **Flutter Web** | — | Mesmo código base compilado para web |

### Pacotes Flutter Essenciais

```yaml
dependencies:
  # Estado
  flutter_bloc: ^8.x
  equatable: ^2.x

  # Autenticação Firebase
  firebase_core: ^2.x
  firebase_auth: ^4.x
  google_sign_in: ^6.x

  # Notificações Push
  firebase_messaging: ^14.x

  # Mapa e GPS
  flutter_map: ^6.x          # Alternativa open-source ao Google Maps SDK
  geolocator: ^10.x          # GPS nativo iOS e Android
  latlong2: ^0.9.x           # Coordenadas geográficas

  # HTTP / API
  dio: ^5.x                  # Cliente HTTP robusto com interceptors
  retrofit: ^4.x             # Gerador de código para REST client

  # Armazenamento Seguro
  flutter_secure_storage: ^9.x  # JWT token armazenado criptografado

  # Gráficos
  fl_chart: ^0.65.x          # Gráficos de linha para histórico de sintomas

  # PDF
  pdf: ^3.x                  # Geração de relatórios PDF
  printing: ^5.x             # Impressão e compartilhamento de PDF

  # Câmera e Imagem
  image_picker: ^1.x         # Câmera ou galeria nativa
  cached_network_image: ^3.x # Cache de imagens da galeria de banheiros

  # Utilitários
  intl: ^0.18.x              # Formatação de datas (pt-BR)
  shared_preferences: ^2.x   # Cache leve de configurações locais

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.x
  build_runner: ^2.x
  retrofit_generator: ^7.x
```

### Back-End

| Camada | Tecnologia | Justificativa |
|---|---|---|
| Runtime | **Node.js** (LTS) | Event-driven, ideal para geolocalização e múltiplos usuários simultâneos |
| Framework | **Express.js** | Leve, maduro, bom ecossistema para REST APIs |
| Banco de Dados | **MongoDB Atlas** (NoSQL) | Queries geoespaciais nativas ($near, $geoWithin), schema flexível para dados de saúde |
| Autenticação | **Firebase Authentication** | Tokens JWT gerenciados automaticamente, login social Google/Apple |
| Notificações Push | **Firebase Cloud Messaging (FCM)** | Notificações nativas iOS e Android para lembretes de medicação |
| Cache | **Redis** | Cache de queries geoespaciais frequentes |
| Containerização | **Docker** | Consistência entre ambientes dev/staging/prod |
| CI/CD | **GitHub Actions** | Build Flutter + testes automáticos a cada pull request |

### Ferramentas de Desenvolvimento

| Ferramenta | Finalidade |
|---|---|
| Android Studio / VS Code | IDEs com emuladores iOS e Android integrados |
| Git / GitHub | Controle de versão e pull requests |
| Flutter Test + Mockito | Testes unitários e de widgets com mocking |
| Integration Test | Testes end-to-end em dispositivo real ou emulador |
| Postman | Teste e documentação dos endpoints REST |
| MongoDB Compass | Interface gráfica para debug das coleções |
| Figma | Referência dos protótipos de interface aprovados |
| Sentry Flutter SDK | Monitoramento de crashes em tempo real |
| Firebase Analytics | Eventos de uso (LGPD compliant) |

---

## 3. Arquitetura do App Flutter

### Padrão Arquitetural: Three-Tier + BLoC

```
┌─────────────────────────────────────────────────┐
│               App Flutter/Dart                  │
│  ┌──────────┐ ┌──────────┐ ┌─────────────────┐  │
│  │   UI /   │ │  BLoC /  │ │  Repositories / │  │
│  │ Widgets  │◄►│  Cubit   │◄►│  Data Sources   │  │
│  └──────────┘ └──────────┘ └────────┬────────┘  │
└───────────────────────────────────────┼──────────┘
                                        │ HTTP/REST
┌───────────────────────────────────────▼──────────┐
│              API REST Node.js/Express             │
│  AuthController | BathroomController             │
│  MedicationController | SymptomController        │
│  AdminController | SecurityMiddleware            │
└───────────────────────────────────────┬──────────┘
                                        │
             ┌──────────────────────────▼──────────────┐
             │          MongoDB Atlas (NoSQL)           │
             │  users | bathrooms | ratings            │
             │  medications | symptomLogs | adminLogs  │
             └─────────────────────────────────────────┘

Serviços Auxiliares (Firebase):
  Firebase Auth ─── JWT tokens e login social
  Firebase FCM  ─── Notificações push nativas
```

### Estrutura de Pastas do Projeto Flutter

```
lib/
├── main.dart
├── app.dart                    # MaterialApp / CupertinoApp root
├── core/
│   ├── constants/              # Cores, tipografia, strings, endpoints
│   ├── errors/                 # Exceções customizadas e failure types
│   ├── network/                # Dio client, interceptors, API base
│   ├── router/                 # GoRouter: rotas nomeadas e guards
│   ├── theme/                  # ThemeData Material 3 + Cupertino
│   └── utils/                  # Formatadores, validadores, helpers
├── features/
│   ├── auth/
│   │   ├── data/               # FirebaseAuthDataSource, AuthRepository impl
│   │   ├── domain/             # AuthRepository interface, use cases
│   │   └── presentation/       # AuthBloc, LoginPage, RegisterPage
│   ├── map/
│   │   ├── data/               # BathroomApiDataSource, MapRepository impl
│   │   ├── domain/             # Bathroom entity, MapRepository interface
│   │   └── presentation/       # MapBloc, MapPage, BathroomDetailSheet
│   ├── health/
│   │   ├── data/               # MedicationDataSource, SymptomDataSource
│   │   ├── domain/             # Medication/Symptom entities e use cases
│   │   └── presentation/       # HealthBloc, MedicationPage, SymptomPage
│   └── admin/
│       ├── data/               # AdminApiDataSource
│       ├── domain/             # AdminRepository interface
│       └── presentation/       # AdminBloc, AdminDashboardPage
└── shared/
    ├── widgets/                # Componentes reutilizáveis (AppBar, Cards)
    └── extensions/             # Dart extensions (Context, String, etc.)
```

### Navegação (GoRouter)

```dart
// Rotas principais
/splash
/onboarding
/auth/login
/auth/register
/auth/verify-email

// Autenticado — Paciente/Colaborador
/map                            # Tela principal
/map/bathroom/:id               # Detalhes do banheiro
/map/add                        # Adicionar banheiro
/health/medications             # Rastreador de medicação
/health/medications/add
/health/symptoms                # Histórico de sintomas
/health/symptoms/add
/profile

// Autenticado — Admin
/admin/dashboard
/admin/bathrooms-pending
/admin/comments-pending
/admin/stats
```

---

## 4. Requisitos Funcionais

### RF01 — Autenticação e Perfis de Acesso

- Login via **e-mail/senha**, **Google ID** e **Apple ID** (Firebase Authentication)
- Três perfis: `paciente`, `colaborador`, `admin` — com permissões distintas
- Token JWT gerenciado pelo Firebase, armazenado no dispositivo via **flutter_secure_storage**
- Sessão expira após **30 dias** de inatividade
- Após 3 tentativas de login falhas → botão bloqueado por 15 minutos

### RF02 — Mapa Interativo de Banheiros

- Mapa em tela cheia centralizado na **localização atual via GPS nativo** (package `geolocator`)
- Marcadores coloridos nos banheiros validados: **verde** (nota ≥ 4), **amarelo** (2–3.9), **vermelho** (< 2)
- FAB central: **"Modo Urgência"** → centraliza no banheiro mais próximo com maior avaliação
- Apenas banheiros com `status: 'validado'` aparecem no mapa público

### RF03 — Filtros de Busca no Mapa

Filtros disponíveis (barra deslizável na parte inferior do mapa):

| Filtro | Opções |
|---|---|
| Proximidade | 0.5 / 1 / 2 / 5 km |
| Avaliação mínima | 1 a 5 estrelas |
| Tipo | shopping, hospital, restaurante, estação, outro |
| Acessibilidade | cadeirante (booleano) |
| Papel higiênico | disponível (booleano) |
| Acesso livre | sem compra obrigatória (booleano) |

### RF04 — Detalhes do Banheiro (Bottom Sheet)

Ao tocar em marcador, exibir **bottom sheet** com:

- Nome do estabelecimento e endereço completo
- Avaliação média em estrelas + total de avaliações
- Ícones de atributos (cadeirante, papel, acesso livre)
- Horário de funcionamento
- Galeria de fotos (URLs do Firebase Storage, exibidas com `cached_network_image`)
- Últimos 3 comentários aprovados da comunidade
- Botão **"Como Chegar"** → abre Google Maps / Apple Maps nativos via `url_launcher`
- Botão **"Avaliar"** → abre modal de avaliação

### RF05 — Adicionar Novo Banheiro (Formulário Step-by-Step)

Fluxo em **4 passos** com barra de progresso:

| Passo | Campos |
|---|---|
| 1 – Localização | Confirma ponto GPS atual ou ajuste manual no mapa; campo obrigatório |
| 2 – Informações Básicas | Nome do estabelecimento (obrigatório), tipo (enum — obrigatório) |
| 3 – Atributos | Acessibilidade, papel, acesso livre (toggles), horário de funcionamento |
| 4 – Foto | Opcional — câmera ou galeria nativa via `image_picker`, máx. 5 MB |

- Submissão salva com `status: 'pendente_validacao'`
- Admin notificado via FCM
- Confirmação visual ao usuário: _"Enviado! Será avaliado em até 24h."_
- **Detecção de duplicata**: API retorna aviso se há banheiro similar em raio de 50m

### RF06 — Avaliação e Comentários

- Nota de **1 a 5 estrelas** (obrigatório)
- Comentário de até **500 caracteres** (opcional, com contador regressivo)
- Nota registrada imediatamente; MongoDB recalcula `avaliacaoMedia` do banheiro
- Comentário salvo com `status: 'pendente_moderacao'` → exibido ao autor com badge _"Em análise"_
- Usuário pode **reavaliar**: última nota prevalece, média recalculada
- Contador de caracteres fica vermelho ao se aproximar de 500

### RF07 — Painel Administrativo (Flutter Web + tela protegida no app)

Três abas principais:

| Aba | Conteúdo |
|---|---|
| Banheiros Pendentes | Lista de submissões com minimap, dados do ponto, autor, data. Botões: Aprovar / Rejeitar (motivo obrigatório) |
| Comentários Pendentes | Fila de moderação com contexto do banheiro avaliado. Botões: Aprovar / Remover |
| Estatísticas | Dashboard: MAU, total de banheiros por status, mapa de calor, NPS |

- Toda ação é confirmada por dialog modal
- Toda ação é registrada no `adminLogs` (MongoDB) com timestamp imutável
- Rejeitar sem preencher motivo → **bloqueado pelo sistema**

### RF08 — Controle de Medicação com Lembretes Push

- Cadastro de medicação: nome, dosagem, frequência (enum), horários (time picker nativo Flutter)
- Back-end agenda **cron jobs no Node.js** para cada horário configurado
- Cron job aciona **FCM** → notificação push nativa aparece na barra de status do dispositivo
- Usuário desliza a notificação → toca em **"Tomei"** → app registra ingestão no MongoDB
- Dashboard de **aderência mensal** (porcentagem de doses cumpridas)
- Editar/excluir medicação: API atualiza e reagenda cron jobs

### RF09 — Histórico de Sintomas Diários

Formulário de registro diário com:

| Campo | Tipo |
|---|---|
| Evacuações | Contador com botões + / - (mínimo 0) |
| Sangue presente | Toggle (sim/não) |
| Dor abdominal | Slider de 1 a 10 com ícone de face graduado |
| Fadiga | Slider de 1 a 10 |
| Notas livres | Campo de texto opcional, máx. 1000 chars |

- Gráficos de linha via **fl_chart** com filtros de 7, 30 e 90 dias
- Registros de dias anteriores: modo **somente leitura**
- Registro do dia atual: editável até 23h59
- Botão **"Gerar Relatório PDF"** → exporta PDF formatado via package `pdf` + `printing`
- Duplicata no mesmo dia: app oferece editar o registro existente

### RF10 — Compartilhamento com Profissional de Saúde

- Gera **link com token de acesso temporário** (read-only)
- Consentimento explícito conforme LGPD
- Token revogável a qualquer momento pelo usuário
- Dados compartilhados: histórico de sintomas + aderência à medicação

---

## 5. Requisitos Não Funcionais

### RNF01 — Segurança e LGPD

- Criptografia end-to-end para dados de saúde
- HTTPS com TLS/SSL em **todas** as comunicações
- Senhas **nunca** armazenadas em plain text (gerenciadas pelo Firebase)
- JWT armazenado via `flutter_secure_storage` (keychain iOS / keystore Android)
- Consentimento explícito e granular no onboarding
- Direito ao esquecimento: endpoint de exclusão de conta e dados
- Dados agregados **anonimizados** para analytics
- Log de auditoria imutável (`adminLogs` com TTL de 365 dias)

### RNF02 — Performance Mobile

- **60fps constantes** em dispositivos com hardware mínimo
- Suporte: **Android 6.0 (API 23+)** e **iOS 13+**
- Carregamento do mapa: **< 3 segundos** em conexão 4G
- Modo offline: cache da última posição e banheiros próximos

### RNF03 — Disponibilidade do Back-End

- Uptime: **99%** (máx. 7h downtime/mês)
- Redundância geográfica com failover automático
- RTO < 1 hora | RPO < 30 minutos
- Backup automático diário do MongoDB Atlas

### RNF04 — Escalabilidade

- Auto-scaling cloud (AWS ECS ou Google Cloud Run)
- MongoDB com sharding geográfico
- Redis para cache de queries geoespaciais frequentes

### RNF05 — Usabilidade e Acessibilidade

- Semantics API do Flutter (compatível com TalkBack/Android e VoiceOver/iOS)
- Modo escuro nativo
- Área mínima de toque: **48×48dp** (Material Design Guidelines)
- Feedback háptico em ações críticas

### RNF06 — Testabilidade

- Cobertura de testes mínima: **80%** (unitários + integração)
- Pipeline CI/CD com **GitHub Actions**: build + testes a cada pull request
- Testes em dispositivos reais via TestFlight (iOS) e Play Console Internal Track (Android)

---

## 6. Modelo de Dados (MongoDB)

> MongoDB Atlas com índice **2dsphere** para queries geoespaciais. Firebase Authentication gera os UIDs referenciados como chave estrangeira.

### Coleção: `users`

```json
{
  "_id": "ObjectId",
  "firebaseUid": "String (único, indexado)",
  "email": "String (único, indexado)",
  "nome": "String (obrigatório)",
  "perfil": "Enum: ['paciente', 'colaborador', 'admin']",
  "dataCriacao": "ISODate",
  "dataUltimoAcesso": "ISODate",
  "ativo": "Boolean (default: false até confirmar e-mail via Firebase)"
}
```

### Coleção: `bathrooms`

```json
{
  "_id": "ObjectId",
  "nomeEstabelecimento": "String (obrigatório)",
  "localizacao": {
    "type": "Point",
    "coordinates": ["lng (Number)", "lat (Number)"]
  },
  "endereco": "String",
  "tipo": "Enum: ['shopping', 'hospital', 'restaurante', 'estacao', 'outro']",
  "acessibilidade": "Boolean",
  "temPapel": "Boolean",
  "acessoLivre": "Boolean",
  "horarioFuncionamento": "String",
  "fotos": "Array<String> (URLs no Firebase Storage)",
  "status": "Enum: ['validado', 'pendente_validacao'] (default: 'pendente_validacao')",
  "avaliacaoMedia": "Number (0–5, recalculado a cada nova avaliação)",
  "totalAvaliacoes": "Number",
  "submetidoPor": "ObjectId (ref: users)",
  "aprovadoPor": "ObjectId (ref: users, nullable)",
  "dataCriacao": "ISODate",
  "dataAtualizacao": "ISODate"
}
```

> **Índice obrigatório:** `{ localizacao: '2dsphere' }` para queries `$near` e `$geoWithin`

### Coleção: `ratings`

```json
{
  "_id": "ObjectId",
  "bathroomId": "ObjectId (ref: bathrooms, indexado)",
  "userId": "ObjectId (ref: users, indexado)",
  "nota": "Number (1–5, obrigatório)",
  "comentario": "String (máx. 500 chars, nullable)",
  "dataAvaliacao": "ISODate",
  "moderado": "Boolean (default: false)",
  "dataAprovacao": "ISODate (nullable)"
}
```

> **Índice composto:** `{ bathroomId: 1, userId: 1 }` — garante uma avaliação por usuário por banheiro

### Coleção: `medications`

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: users, indexado)",
  "nomeMedicamento": "String (obrigatório)",
  "dosagem": "String (ex: '50mg')",
  "frequencia": "Enum: ['diaria', '12h', '8h', '6h', 'semanal']",
  "horarios": "Array<String> (ex: ['08:00', '20:00'])",
  "fcmJobIds": "Array<String> (IDs dos cron jobs agendados no Node.js)",
  "ativa": "Boolean (default: true)",
  "dataCriacao": "ISODate"
}
```

### Coleção: `symptomLogs`

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: users, indexado)",
  "data": "Date (índice — único por userId + data)",
  "evacuacoes": "Number (mínimo 0)",
  "sanguePresente": "Boolean",
  "dorAbdominal": "Number (1–10)",
  "fadiga": "Number (1–10)",
  "notas": "String (opcional, máx. 1000 chars)",
  "dataRegistro": "ISODate"
}
```

> **Índice único composto:** `{ userId: 1, data: 1 }` — um registro por dia por usuário

### Coleção: `adminLogs`

```json
{
  "_id": "ObjectId",
  "adminId": "ObjectId (ref: users)",
  "acao": "String (ex: 'aprovar_banheiro', 'remover_comentario', 'bloquear_usuario')",
  "recursoId": "ObjectId (ID do recurso afetado)",
  "tipoRecurso": "Enum: ['bathroom', 'rating', 'user']",
  "resultado": "Enum: ['aprovado', 'rejeitado', 'removido']",
  "motivo": "String (obrigatório para rejeição/remoção)",
  "dataHora": "ISODate"
}
```

> **Índice TTL:** `{ dataHora: 1, expireAfterSeconds: 31536000 }` — retenção de 365 dias (LGPD)

### Índices Completos para Performance

```javascript
// bathrooms — geoespacial (obrigatório)
db.bathrooms.createIndex({ localizacao: '2dsphere' });

// users
db.users.createIndex({ firebaseUid: 1 }, { unique: true });
db.users.createIndex({ email: 1 }, { unique: true });

// ratings
db.ratings.createIndex({ bathroomId: 1, userId: 1 }, { unique: true });

// symptomLogs
db.symptomLogs.createIndex({ userId: 1, data: 1 }, { unique: true });

// adminLogs — TTL
db.adminLogs.createIndex({ dataHora: 1 }, { expireAfterSeconds: 31536000 });
```

---

## 7. Estrutura de Telas e Navegação

### 7.1 Tela de Splash e Onboarding

**Splash Screen:**
- Exibe identidade visual do VivaLivre enquanto o app inicializa
- Verifica estado de autenticação no Firebase → redireciona para Onboarding (novo usuário) ou Mapa (autenticado)

**Onboarding (3 cards deslizáveis):**
1. 🗺️ Mapa de Banheiros — _"Encontre banheiros próximos agora"_
2. 💊 Controle de Saúde — _"Gerencie medicações e sintomas"_
3. 👥 Comunidade — _"Compartilhe e valide com outros portadores"_
- Botão "Começar" → navega para Login

### 7.2 Tela de Login e Cadastro

**Login:**
- Botão "Entrar com Google" (um toque)
- Botão "Entrar com Apple" (um toque)
- Campos: E-mail + Senha
- Link "Esqueci minha senha" → Firebase sendPasswordResetEmail
- Link "Criar Conta"

**Cadastro:**
- Campos: Nome, E-mail, Senha, Confirmar Senha, Perfil (Paciente / Colaborador)
- Validação em tempo real (feedback inline)
- Senha mínima: 8 chars, 1 maiúscula, 1 número
- Pós-cadastro: tela "Confirme seu e-mail" com opção de reenvio

### 7.3 Tela Principal — Mapa de Banheiros

**Layout:**
- Mapa em tela cheia (`flutter_map` ou Google Maps SDK)
- Marcadores coloridos (verde / amarelo / vermelho) por avaliação
- **Bottom Navigation Bar** com 4 abas: Mapa | Saúde | Comunidade | Perfil
- **FAB central** — Modo Urgência (centraliza no banheiro mais próximo com melhor nota)
- **Barra de busca** no topo (pesquisa por endereço via Google Places API)
- **Filtros** em barra deslizável horizontal na parte inferior

**Comportamento do Mapa:**
- GPS ativado → mapa centraliza na posição atual
- GPS negado → dialog explicativo + opção de busca manual
- Offline → carrega cache dos últimos banheiros consultados

### 7.4 Tela de Detalhes do Banheiro

**Bottom Sheet com:**
- Header: nome, nota média em estrelas, total de avaliações
- Ícones de atributos (cadeirante ♿, papel 🧻, acesso livre ✅)
- Horário de funcionamento
- Galeria horizontal de fotos
- Lista dos últimos 3 comentários aprovados (com opção "Ver todos")
- Botão primário: "Como Chegar" → `url_launcher` (Google Maps / Apple Maps)
- Botão secundário: "Avaliar" → modal de avaliação

### 7.5 Tela de Adicionar Banheiro

**Formulário step-by-step (4 passos com ProgressIndicator):**

```
[Passo 1/4] Localização
  - Mapa interativo com pin draggable
  - Botão "Usar minha localização atual" (GPS)
  - GPS indisponível → marcação manual no mapa

[Passo 2/4] Informações
  - Nome do estabelecimento (TextField obrigatório)
  - Tipo (DropdownButton com enum)

[Passo 3/4] Atributos
  - SwitchListTile: Acessível para cadeirantes
  - SwitchListTile: Tem papel higiênico
  - SwitchListTile: Acesso livre (sem compra)
  - TextField: Horário de funcionamento

[Passo 4/4] Foto (opcional)
  - Botão: Tirar Foto (câmera nativa)
  - Botão: Escolher da Galeria
  - Preview da imagem selecionada
  - Limite: 5 MB

[Confirmação]
  - SnackBar: "Enviado! Será avaliado em até 24h."
```

### 7.6 Tela de Rastreador de Medicação

**Layout:**
- Card de aderência mensal (% de doses cumpridas do mês)
- Lista de medicamentos com status do dia (tomado ✅ / pendente ⏰)
- Próximo lembrete exibido em cada card
- FAB: "+ Adicionar Medicação"

**Formulário de Medicação:**
- Nome (TextField obrigatório)
- Dosagem (TextField — ex: "50mg")
- Frequência (DropdownButton: diária, 12h, 8h, 6h, semanal)
- Horários (TimePicker nativo Flutter — múltiplos conforme frequência)

### 7.7 Tela de Histórico de Sintomas

**Formulário Diário:**
- Slider dor abdominal (1–10) com ícones de face
- Slider fadiga (1–10)
- Contador evacuações (botões + / -)
- Toggle sangue presente
- TextField notas livres (máx. 1000 chars)
- Botão "Salvar Registro de Hoje"

**Gráficos (fl_chart):**
- Gráfico de linha para dor abdominal
- Gráfico de linha para fadiga
- Gráfico de barras para evacuações
- Seletor de período: 7 dias / 30 dias / 90 dias
- Botão "Gerar Relatório PDF"

### 7.8 Tela do Painel Administrativo (Flutter Web + App)

**3 Abas:**

1. **Banheiros Pendentes:**
   - Lista de cards com: minimap do ponto, nome, endereço, autor, data de submissão
   - Botões: "Aprovar" (verde) / "Rejeitar" (vermelho)
   - Rejeitar → dialog modal exigindo motivo (obrigatório)

2. **Comentários Pendentes:**
   - Lista com: texto do comentário, banheiro avaliado, nota, usuário, data
   - Botões: "Aprovar" / "Remover"
   - Remover → dialog modal exigindo motivo

3. **Estatísticas:**
   - Cards: MAU, total de banheiros (validados / pendentes / rejeitados), NPS
   - Mapa de calor de uso por região
   - Gráfico de crescimento de usuários

---

## 8. Casos de Uso Detalhados

### UC01 — Autenticar-se no Aplicativo

**Ator:** Usuário não autenticado  
**Pré-condição:** Usuário possui conta cadastrada; conexão com internet

**Fluxo Principal:**
1. Usuário abre o app → tela de Login
2. Seleciona "Entrar com Google", "Entrar com Apple" [A1] ou digita e-mail/senha
3. App envia credenciais ao Firebase Authentication [E1][E2]
4. Firebase valida e retorna token JWT
5. App armazena token via `flutter_secure_storage`
6. Redireciona para Mapa (Paciente/Colaborador) ou Painel Admin

**[A1] Login Social:** Firebase exibe sheet nativa de seleção de conta → usuário retorna autenticado  
**[E1] Credenciais inválidas:** Exibe "E-mail ou senha incorretos". Após 3 tentativas → bloqueio por 15 min  
**[E2] Sem conexão:** Exibe "Sem internet. Tente novamente."

**Pós-condição:** Token JWT armazenado; sessão ativa por 30 dias

---

### UC02 — Cadastrar-se no Aplicativo

**Ator:** Usuário novo  
**Pré-condição:** Sem conta prévia

**Fluxo Principal:**
1. Toca em "Criar Conta"
2. Preenche: Nome, E-mail, Senha, Confirmar Senha, Perfil [E1]
3. App valida: e-mail único + força da senha (≥8 chars, 1 maiúscula, 1 número) [E2]
4. Firebase cria conta com status `não verificado` + envia e-mail de confirmação
5. App exibe tela "Confirme seu e-mail" com opção de reenvio
6. Usuário clica no link → conta ativada → pode fazer login (UC01)

**[A1] Google/Apple:** Nome e e-mail preenchidos automaticamente; usuário só seleciona perfil  
**[E1] Campo obrigatório ausente:** Campo destacado com mensagem inline  
**[E2] E-mail já cadastrado:** "Já existe conta com este e-mail." + link para Login

**Pós-condição:** Conta criada no Firebase + perfil salvo no MongoDB

---

### UC03 — Visualizar Mapa de Banheiros

**Ator:** Usuário autenticado (qualquer perfil)  
**Pré-condição:** UC01 concluído; permissão de localização concedida

**Fluxo Principal:**
1. App solicita permissão de localização (primeira abertura) [E1]
2. GPS fornece coordenadas → mapa centraliza na posição atual
3. App consulta API: `GET /api/bathrooms?lat=X&lng=Y&radius=1000`
4. MongoDB retorna banheiros em raio de 1km ordenados por proximidade (`$near`)
5. App renderiza marcadores coloridos no mapa
6. Usuário aplica filtros → app recarrega marcadores em tempo real
7. Toque no marcador → bottom sheet com dados básicos + botão "Ver Detalhes"

**[A1] Busca manual:** Usuário digita endereço → Google Places API geocodifica → mapa recentraliza  
**[E1] GPS negado:** Dialog explicativo + busca manual; mapa centraliza em localização aproximada via IP  
**[E2] Sem conexão:** Carrega cache local dos últimos banheiros consultados

---

### UC04 — Adicionar Novo Banheiro

**Ator:** Usuário autenticado (Paciente ou Colaborador)  
**Pré-condição:** UC01 concluído

**Fluxo Principal:**
1. Toca em "+" no mapa
2. Formulário step-by-step (4 passos com ProgressIndicator)
3. Passo 1: GPS captura coordenada; usuário pode ajustar pin [E1]
4. Passo 2: Nome do estabelecimento e tipo
5. Passo 3: Atributos (acessibilidade, papel, acesso livre, horários)
6. Passo 4: Foto opcional (câmera ou galeria, máx. 5 MB)
7. Toca em "Enviar para Validação"
8. API salva com `status: 'pendente_validacao'`; FCM notifica Admin
9. App exibe SnackBar de confirmação

**[A1] Duplicata:** API retorna aviso de banheiro similar em raio de 50m → dialog de escolha  
**[E1] GPS indisponível:** Permite marcação manual no mapa  
**[E2] Campo obrigatório:** App bloqueia avanço de passo e destaca o campo

**Pós-condição:** Banheiro salvo no MongoDB com `status: 'pendente_validacao'`; invisível até aprovação

---

### UC05 — Avaliar e Comentar Banheiro

**Ator:** Usuário autenticado  
**Pré-condição:** Visualizando detalhes de um banheiro; tocou em "Avaliar"

**Fluxo Principal:**
1. Modal com 5 estrelas interativas
2. Usuário seleciona nota (obrigatório) + escreve comentário (até 500 chars) [E1]
3. Toca em "Enviar Avaliação"
4. API registra nota; MongoDB recalcula `avaliacaoMedia` do banheiro
5. Comentário salvo com `status: 'pendente_moderacao'`
6. Modal fecha; SnackBar: "Nota registrada! Comentário aguarda revisão."

**[A1] Reavaliação:** App exibe avaliação anterior para edição  
**[E1] Comentário > 500 chars:** Campo bloqueia digitação; contador fica vermelho

---

### UC06 — Gerenciar Medicações

**Ator:** Usuário autenticado (perfil Paciente)  
**Pré-condição:** Na aba Saúde → Medicações

**Fluxo Principal:**
1. Toca em "+ Adicionar Medicação"
2. Preenche: nome, dosagem, frequência, horários (TimePicker nativo) [E1]
3. Toca em "Salvar"
4. API cria registro no MongoDB + agenda cron jobs no Node.js
5. No horário configurado: Node.js aciona FCM → notificação push nativa
6. Usuário desliza notificação → "Tomei" → ingestão registrada no MongoDB
7. Dashboard de aderência atualiza porcentagem mensal

**[A1] Editar medicação:** Altera campos → API atualiza + reagenda cron jobs  
**[E1] Horário inválido:** TimePicker Flutter impede entradas incorretas nativamente

---

### UC07 — Registrar Sintomas Diários

**Ator:** Usuário autenticado (perfil Paciente)  
**Pré-condição:** Na aba Saúde → Sintomas de Hoje

**Fluxo Principal:**
1. Preenche formulário: dor (slider 1–10), fadiga (slider 1–10), evacuações (contador), sangue (toggle), notas
2. Toca em "Salvar Registro de Hoje" [E1]
3. API salva `symptomLog` no MongoDB com timestamp UTC
4. App atualiza gráficos fl_chart (tendências de 7/30/90 dias)
5. Botão "Gerar Relatório PDF" → exportação via `pdf` + `printing`

**[A1] Editar registro do dia:** Permitido até 23h59 do mesmo dia  
**[E1] Duplicata no mesmo dia:** App oferece editar o registro existente

---

### UC08 — Gerenciar Validações (Administrador)

**Ator:** Usuário autenticado (perfil Admin)  
**Pré-condição:** No Painel Administrativo

**Fluxo Principal:**
1. Admin acessa aba "Banheiros Pendentes"
2. Visualiza lista de submissões com minimap, dados, autor e data
3. Revisa e toca em "Aprovar" ou "Rejeitar" [E1]
4. **Aprovar:** status → `validado`; ponto aparece no mapa para todos os usuários
5. **Rejeitar:** Admin preenche motivo → autor notificado via FCM e e-mail
6. Ação registrada no `adminLogs` (adminId, ação, recursoId, motivo, timestamp)
7. Repete o fluxo para aba "Comentários Pendentes"

**[A1] Remover comentário publicado:** Toca em "Remover" → dialog exige motivo obrigatório → registrado no adminLog  
**[E1] Rejeitar sem motivo:** Sistema bloqueia a ação + destaca campo "Motivo da Rejeição"

---

## 9. Integrações Externas

### Firebase Authentication

```dart
// Inicialização (main.dart)
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Login com Google
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
await FirebaseAuth.instance.signInWithCredential(credential);

// Armazenar token JWT no dispositivo
final token = await FirebaseAuth.instance.currentUser!.getIdToken();
await secureStorage.write(key: 'jwt_token', value: token);
```

### Firebase Cloud Messaging (Notificações Push)

```dart
// Solicitar permissão (iOS obrigatório)
final messaging = FirebaseMessaging.instance;
await messaging.requestPermission(alert: true, badge: true, sound: true);

// Handler de notificações em foreground
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Exibir snackbar ou dialog in-app
});

// Handler de tap na notificação
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Navegar para tela de medicação e marcar como tomada
});
```

### GPS / Geolocalização

```dart
// Solicitar permissão de localização
LocationPermission permission = await Geolocator.requestPermission();

// Obter posição atual
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);

// Stream de posição (atualização contínua no mapa)
StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
  locationSettings: LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // atualiza a cada 10 metros
  ),
).listen((Position? position) {
  // Atualizar posição no mapa
});
```

### API REST Node.js — Endpoints Principais

```
# Autenticação
POST   /api/auth/register              # Criar usuário no MongoDB
GET    /api/auth/profile               # Perfil do usuário autenticado

# Banheiros
GET    /api/bathrooms?lat=X&lng=Y&radius=1000&filters...
GET    /api/bathrooms/:id              # Detalhes de um banheiro
POST   /api/bathrooms                  # Submeter novo banheiro
GET    /api/bathrooms/pending          # Admin: listar pendentes

# Avaliações
POST   /api/bathrooms/:id/ratings      # Avaliar banheiro
GET    /api/bathrooms/:id/ratings      # Listar avaliações do banheiro

# Admin
PATCH  /api/admin/bathrooms/:id/approve
PATCH  /api/admin/bathrooms/:id/reject
PATCH  /api/admin/ratings/:id/approve
DELETE /api/admin/ratings/:id

# Medicações
GET    /api/medications                # Listar medicações do usuário
POST   /api/medications                # Criar medicação + agendar cron jobs
PUT    /api/medications/:id            # Editar + reagendar
DELETE /api/medications/:id            # Excluir + cancelar cron jobs
POST   /api/medications/:id/confirm    # Confirmar dose tomada

# Sintomas
GET    /api/symptoms?period=7          # Histórico (7, 30 ou 90 dias)
POST   /api/symptoms                   # Registrar sintomas do dia
PUT    /api/symptoms/:id               # Editar registro do dia atual
GET    /api/symptoms/report/pdf        # Exportar relatório PDF
```

### Comunicação com a API (Dio + Headers)

```dart
// Configuração do Dio com token Firebase
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.vivalivre.app',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 10),
));

// Interceptor para adicionar token JWT automaticamente
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await secureStorage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
));
```

---

## 10. Roadmap de Desenvolvimento (4 Sprints)

### Sprint 1 — Semana 1: Setup e Arquitetura

**Entregável: App rodando em emulador iOS e Android**

- [ ] Setup do ambiente: Flutter 3, Android Studio, Xcode, VS Code
- [ ] Criar projeto Flutter com estrutura de pastas definida (features + core)
- [ ] Configurar Firebase (Auth, FCM, Crashlytics)
- [ ] Setup MongoDB Atlas (cluster, usuário, rede)
- [ ] Scaffolding da API Node.js/Express com Docker
- [ ] Implementar BLoC base + GoRouter
- [ ] Configurar GitHub Actions (build Flutter + testes automáticos)
- [ ] Implementar tela de Splash + Onboarding

### Sprint 2 — Semana 2: Mapa e Autenticação

**Entregável: Usuário loga e vê mapa com banheiros via GPS**

- [ ] Firebase Auth: e-mail/senha + Google Sign-In + Apple Sign-In
- [ ] Telas de Login e Cadastro (UI + BLoC + validações)
- [ ] Integração `flutter_map` ou Google Maps SDK
- [ ] GPS nativo com `geolocator` (permissões iOS + Android)
- [ ] Endpoint `GET /api/bathrooms` com query geoespacial MongoDB `$near`
- [ ] Renderização de marcadores no mapa com cores por avaliação
- [ ] Bottom Sheet de detalhes do banheiro (dados básicos)
- [ ] Cache offline de banheiros próximos

### Sprint 3 — Semana 3: Core Features

**Entregável: Usuário adiciona, avalia e filtra banheiros**

- [ ] Formulário step-by-step de adição de banheiro (4 passos)
- [ ] Upload de foto via `image_picker` → Firebase Storage
- [ ] Sistema de avaliação (modal 1–5 estrelas + comentário)
- [ ] Filtros avançados no mapa (tipo, acessibilidade, nota)
- [ ] Fila de moderação de comentários (backend + admin)
- [ ] Tela básica do Painel Admin (banheiros pendentes + botões Aprovar/Rejeitar)
- [ ] Integração `url_launcher` para "Como Chegar"
- [ ] Testes unitários AuthBloc + MapBloc
- [ ] Testes de integração dos endpoints de banheiro

### Sprint 4 — Semana 4: Saúde, Admin Completo e Notificações

**Entregável: MVP completo para submissão nas lojas**

- [ ] Rastreador de medicação (CRUD + TimePicker + cron jobs Node.js)
- [ ] Integração FCM para lembretes de medicação
- [ ] Histórico de sintomas (formulário + fl_chart + gráficos)
- [ ] Exportação de relatório em PDF (`pdf` + `printing`)
- [ ] Painel Admin completo (Flutter Web + aba de comentários + estatísticas)
- [ ] Log de auditoria imutável (`adminLogs`)
- [ ] Performance tuning: 60fps, lazy loading, cache Redis
- [ ] Testes em dispositivos reais (TestFlight + Play Console Internal Track)
- [ ] Preparar screenshots, ícones e textos para App Store e Google Play

### Pós-MVP — Beta e Lançamento Público

- [ ] Beta testing com 50–100 usuários de associações de pacientes
- [ ] Bug fixes e melhorias de UX com base no feedback
- [ ] Documentação API em Swagger/OpenAPI
- [ ] Aprovação nas lojas + lançamento público
- [ ] Monitoramento com Sentry + Firebase Analytics
- [ ] **Meta: 1.000 usuários ativos no lançamento**

---

## 11. Métricas e KPIs

### Métricas de Produto (6 meses)

| Métrica | Meta | Critério de Saúde |
|---|---|---|
| Downloads (iOS + Android) | 10.000 | Crescimento ≥ 20% a.m. |
| MAU | 8.000 | ≥ 80% dos downloads |
| Retenção Dia 30 | 70% | ≥ 60% = product-market fit |
| Avaliação nas lojas | ≥ 4,5 ⭐ | ≥ 4,0 = comercialmente viável |
| NPS | ≥ 50 | Excelente para fase inicial |
| Banheiros validados | 5.000 | Cobertura em 3+ capitais |
| Aderência (medicação) | 85% | Impacto positivo na saúde |

### Métricas Técnicas

| Métrica | Target |
|---|---|
| API Response Time P95 | < 500ms |
| Mapa Load Time (4G) | < 3s |
| Frame Rate Flutter | 60fps constantes |
| Uptime API | ≥ 99% |
| Error Rate | < 0,1% das requisições |
| MTTR | < 30 min |
| Cobertura de Testes | ≥ 80% |

---

## 12. Glossário

| Termo | Definição |
|---|---|
| **BLoC** | Business Logic Component — padrão arquitetural Flutter para separação de estado e UI |
| **DII / IBD** | Doenças Inflamatórias Intestinais — engloba Doença de Crohn e Retocolite Ulcerativa |
| **EHR** | Electronic Health Record — prontuário eletrônico do paciente |
| **FAB** | Floating Action Button — botão de ação flutuante no layout Material |
| **FCM** | Firebase Cloud Messaging — notificações push nativas iOS e Android |
| **Flutter** | Framework open-source do Google para apps nativos iOS, Android e Web |
| **GoRouter** | Package Flutter para navegação declarativa com deep links e guards |
| **GPS** | Sistema de geolocalização por satélite acessado nativamente via `geolocator` |
| **JWT** | JSON Web Token — token de autenticação stateless gerenciado pelo Firebase |
| **KPI** | Key Performance Indicator — métrica de sucesso de negócio |
| **LGPD** | Lei Geral de Proteção de Dados (Lei nº 13.709/2018) |
| **MAU** | Monthly Active Users — usuários únicos ativos em um mês |
| **MVP** | Minimum Viable Product — versão mínima funcional para validação |
| **NPS** | Net Promoter Score — índice de recomendação (0 a 100) |
| **RTO / RPO** | Recovery Time/Point Objective — métricas de recuperação de desastres |
| **SII** | Síndrome do Intestino Irritável — público secundário do VivaLivre |
| **TAM** | Total Addressable Market — tamanho total do mercado endereçável |
| **TestFlight** | Plataforma Apple para beta testing de apps iOS |
| **TTL** | Time To Live — tempo de vida automático de dados no MongoDB |
| **2dsphere** | Tipo de índice MongoDB para queries geoespaciais (`$near`, `$geoWithin`) |

---

*Documentação gerada a partir de: VivaLivre_Documentacao.docx v2.0 — Abril de 2026*  
*Otimizada para desenvolvimento Flutter por IA — Todos os requisitos, arquitetura e fluxos estão descritos para implementação direta.*
