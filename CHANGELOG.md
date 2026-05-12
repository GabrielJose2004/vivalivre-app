# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto segue [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] - 2026-05-12

### 🎯 Tema
Otimização de performance e reatividade da feature de Saúde com eliminação de polling desnecessário.

### ✨ Adicionado
- Recarregamento instantâneo de registos de saúde após add/delete
- Melhor feedback visual ao utilizador após ações

### 🔄 Alterado
- **Refatoração da feature Health**: Migração de Stream-based para Future-based architecture
- Removido polling a cada 2 segundos (economia de bateria)
- Simplificado gerenciamento de estado no BLoC
- Melhorada testabilidade do código

### 🗑️ Removido
- `Stream.periodic()` polling mechanism
- `StreamSubscription` management
- Evento interno `_HealthEntriesUpdated`
- Método `_fetchEntries()` privado

### 🐛 Corrigido
- Atraso na atualização da UI após inserção/deleção de registos
- Consumo excessivo de bateria por polling contínuo
- Sobrecarga desnecessária no backend

### 📊 Performance
- ⬇️ Redução de ~95% em requisições HTTP (de 30 req/min para 2-3 req/ação)
- 🔋 Economia significativa de bateria
- ⚡ Atualização instantânea na UI (antes: 2-4 segundos)

### 🔧 Técnico
- Migração de `Stream<List<HealthEntry>> watchEntries()` para `Future<List<HealthEntry>> getEntries()`
- Implementação de recarregamento reativo via `add(WatchHealthEntries(userId))`
- Remoção de `import 'dart:async'` desnecessário
- Simplificação de handlers de erro

### 📚 Documentação
- ✅ README.md atualizado com arquitetura BLoC
- ✅ Guia de contribuição com padrões de código
- ✅ Documentação de endpoints da API
- ✅ Atualização de .github/profile com visão do projeto

### ✅ Testes
- ✅ Flutter analyze: 0 erros
- ✅ Flutter build: Sucesso
- ✅ Code review: Aprovado
- ✅ Cobertura de testes: Mantida

### 🔗 Relacionado
- Commit: `e2f73ec` - refactor(health): remove streams and implement reactive future-based updates
- Tag: `v1.1.0`
- Branch: `feat/health-refactor-reactive-updates` → `develop`

---

## [1.0.0] - 2026-04-26

### ✨ Adicionado
- Aplicativo mobile Flutter com suporte iOS/Android
- Autenticação com JWT
- Mapa de banheiros com PostGIS
- Diário de saúde com registos de sintomas
- Cartão digital DII
- Geolocalização e navegação
- Perfil de utilizador
- Temas claro/escuro

### 🛠️ Stack Inicial
- Flutter 3.x + Dart 3.x
- BLoC para gerenciamento de estado
- Backend Go com Gin Gonic
- PostgreSQL + PostGIS
- JWT para autenticação

---

## Versionamento

Este projeto segue [Semantic Versioning](https://semver.org/):
- **MAJOR**: Mudanças incompatíveis na API
- **MINOR**: Novas funcionalidades compatíveis
- **PATCH**: Correções de bugs

### Formato de Versão
```
MAJOR.MINOR.PATCH+BUILD
Exemplo: 1.1.0+2
```

---

## Como Contribuir

Ao contribuir, atualize o CHANGELOG.md com:
1. Seção `[Unreleased]` para mudanças não lançadas
2. Categorias: Adicionado, Alterado, Removido, Corrigido, Segurança
3. Links para commits/PRs quando relevante
4. Data de lançamento quando versão é finalizada

Exemplo:
```markdown
## [1.2.0] - 2026-06-01

### ✨ Adicionado
- Nova funcionalidade X (#123)

### 🐛 Corrigido
- Bug em Y (#124)
```

---

## Histórico de Releases

| Versão | Data | Tema |
|---|---|---|
| [1.1.0](#110---2026-05-12) | 2026-05-12 | Otimização de Performance |
| [1.0.0](#100---2026-04-26) | 2026-04-26 | Lançamento Inicial |

---

<div align="center">

**VivaLivre — Devolvendo autonomia, segurança e qualidade de vida**

[⬆ Voltar ao topo](#changelog)

</div>
