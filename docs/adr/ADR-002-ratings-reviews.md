# ADR-002: Sistema de Ratings e Reviews para Banheiros

**Status**: Proposto  
**Data**: 2026-05-12  
**Decisor**: @Architect (Gabriel José de Souza)  
**Contexto**: Sprint de Ratings & Reviews

---

## 📋 Contexto

O VivaLivre precisa de um sistema de ratings e reviews para:
- Permitir utilizadores avaliar banheiros (1-5 estrelas)
- Deixar comentários sobre experiência
- Compartilhar fotos do banheiro
- Ajudar outros utilizadores a encontrar banheiros de qualidade
- Manter histórico de avaliações

### Requisitos
- ✅ Rating de 1-5 estrelas
- ✅ Comentários de texto (até 500 caracteres)
- ✅ Upload de fotos (até 3 por review)
- ✅ Validação de utilizador autenticado
- ✅ Prevenção de spam (1 review por utilizador por banheiro)
- ✅ Moderação de conteúdo
- ✅ Cálculo de média de ratings
- ✅ Ordenação por relevância (recentes, úteis)

---

## 🎯 Decisão

**Implementar sistema de ratings e reviews próprio com PostgreSQL, sem dependências externas.**

### Justificativa

| Aspecto | Solução Própria | Alternativas |
|---|---|---|
| **Controle** | 100% nosso | ❌ Terceiros (Yelp API, Google Reviews) |
| **Dados** | Soberania total | ❌ Dependência externa |
| **Custo** | Apenas BD | ❌ APIs pagas |
| **Privacidade** | Garantida | ❌ Compartilhamento com terceiros |
| **Customização** | Total | ❌ Limitada |
| **Moderação** | Controle total | ✅ Comparável |

---

## 🏗️ Schema PostgreSQL

```sql
-- Tabela de ratings e reviews
CREATE TABLE bathroom_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bathroom_id UUID NOT NULL REFERENCES bathrooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(100),
    comment TEXT CHECK (LENGTH(comment) <= 500),
    cleanliness_rating INTEGER CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5),
    accessibility_rating INTEGER CHECK (accessibility_rating >= 1 AND accessibility_rating <= 5),
    spaciousness_rating INTEGER CHECK (spaciousness_rating >= 1 AND spaciousness_rating <= 5),
    helpful_count INTEGER DEFAULT 0,
    unhelpful_count INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(bathroom_id, user_id) -- Um review por utilizador por banheiro
);

-- Tabela de fotos de reviews
CREATE TABLE review_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES bathroom_reviews(id) ON DELETE CASCADE,
    photo_url VARCHAR(500) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de helpful votes
CREATE TABLE review_helpful_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES bathroom_reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(review_id, user_id) -- Um voto por utilizador por review
);

-- View para média de ratings por banheiro
CREATE VIEW bathroom_rating_stats AS
SELECT 
    bathroom_id,
    COUNT(*) as total_reviews,
    ROUND(AVG(rating)::NUMERIC, 2) as average_rating,
    ROUND(AVG(cleanliness_rating)::NUMERIC, 2) as avg_cleanliness,
    ROUND(AVG(accessibility_rating)::NUMERIC, 2) as avg_accessibility,
    ROUND(AVG(spaciousness_rating)::NUMERIC, 2) as avg_spaciousness
FROM bathroom_reviews
WHERE status = 'approved'
GROUP BY bathroom_id;

-- Índices para performance
CREATE INDEX idx_bathroom_reviews_bathroom_id ON bathroom_reviews(bathroom_id);
CREATE INDEX idx_bathroom_reviews_user_id ON bathroom_reviews(user_id);
CREATE INDEX idx_bathroom_reviews_created_at ON bathroom_reviews(created_at DESC);
CREATE INDEX idx_bathroom_reviews_status ON bathroom_reviews(status);
CREATE INDEX idx_review_photos_review_id ON review_photos(review_id);
CREATE INDEX idx_review_helpful_votes_review_id ON review_helpful_votes(review_id);
```

---

## 📱 Arquitetura de Dados

```
Bathroom
├── id
├── name
├── location
└── ratings_stats (VIEW)
    ├── average_rating
    ├── total_reviews
    ├── avg_cleanliness
    ├── avg_accessibility
    └── avg_spaciousness

BathroomReview
├── id
├── bathroom_id (FK)
├── user_id (FK)
├── rating (1-5)
├── title
├── comment
├── cleanliness_rating
├── accessibility_rating
├── spaciousness_rating
├── helpful_count
├── unhelpful_count
├── status (pending/approved/rejected)
├── photos (1:N)
└── helpful_votes (1:N)

ReviewPhoto
├── id
├── review_id (FK)
└── photo_url

ReviewHelpfulVote
├── id
├── review_id (FK)
├── user_id (FK)
└── is_helpful (boolean)
```

---

## 🔌 API Endpoints

### Criar Review
```http
POST /api/bathrooms/:bathroom_id/reviews
Authorization: Bearer {token}
Content-Type: application/json

{
  "rating": 4,
  "title": "Banheiro limpo e acessível",
  "comment": "Excelente localização, muito limpo e bem mantido",
  "cleanliness_rating": 5,
  "accessibility_rating": 4,
  "spaciousness_rating": 3
}

Response (201 Created):
{
  "id": "uuid-123",
  "bathroom_id": "uuid-456",
  "user_id": "uuid-789",
  "rating": 4,
  "title": "Banheiro limpo e acessível",
  "comment": "Excelente localização, muito limpo e bem mantido",
  "status": "pending",
  "created_at": "2026-05-12T22:43:28Z"
}
```

### Listar Reviews de um Banheiro
```http
GET /api/bathrooms/:bathroom_id/reviews?sort=recent&limit=10&offset=0
Authorization: Bearer {token}

Response (200 OK):
{
  "reviews": [
    {
      "id": "uuid-123",
      "user": {
        "id": "uuid-789",
        "name": "João Silva"
      },
      "rating": 4,
      "title": "Banheiro limpo e acessível",
      "comment": "Excelente localização...",
      "cleanliness_rating": 5,
      "accessibility_rating": 4,
      "spaciousness_rating": 3,
      "helpful_count": 12,
      "unhelpful_count": 2,
      "photos": ["url1", "url2"],
      "created_at": "2026-05-12T22:43:28Z"
    }
  ],
  "total": 45,
  "average_rating": 4.2
}
```

### Atualizar Review
```http
PUT /api/reviews/:review_id
Authorization: Bearer {token}
Content-Type: application/json

{
  "rating": 5,
  "comment": "Atualizei minha avaliação..."
}

Response (200 OK): Review atualizado
```

### Deletar Review
```http
DELETE /api/reviews/:review_id
Authorization: Bearer {token}

Response (204 No Content)
```

### Marcar como Útil/Inútil
```http
POST /api/reviews/:review_id/helpful
Authorization: Bearer {token}
Content-Type: application/json

{
  "is_helpful": true
}

Response (200 OK):
{
  "helpful_count": 13,
  "unhelpful_count": 2
}
```

### Upload de Fotos
```http
POST /api/reviews/:review_id/photos
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: [image.jpg]

Response (201 Created):
{
  "id": "uuid-photo",
  "photo_url": "https://cdn.vivalivre.com/reviews/uuid-photo.jpg"
}
```

### Obter Estatísticas de Banheiro
```http
GET /api/bathrooms/:bathroom_id/rating-stats
Authorization: Bearer {token}

Response (200 OK):
{
  "bathroom_id": "uuid-456",
  "total_reviews": 45,
  "average_rating": 4.2,
  "avg_cleanliness": 4.5,
  "avg_accessibility": 4.1,
  "avg_spaciousness": 3.8,
  "rating_distribution": {
    "5": 20,
    "4": 15,
    "3": 7,
    "2": 2,
    "1": 1
  }
}
```

---

## 🔐 Segurança e Validação

### Validação de Input
- ✅ Rating: 1-5 (obrigatório)
- ✅ Título: 1-100 caracteres (opcional)
- ✅ Comentário: 1-500 caracteres (opcional)
- ✅ Ratings específicos: 1-5 (opcional)
- ✅ Fotos: máximo 3, máximo 5MB cada

### Prevenção de Spam
- ✅ Um review por utilizador por banheiro (UNIQUE constraint)
- ✅ Rate limiting: máximo 10 reviews por hora por utilizador
- ✅ Validação de utilizador autenticado
- ✅ Moderação de conteúdo (palavras-chave)

### Privacidade
- ✅ Utilizador só pode editar/deletar seus próprios reviews
- ✅ Dados pessoais não expostos (apenas nome)
- ✅ Fotos armazenadas em CDN seguro
- ✅ Conformidade GDPR

### Moderação
- ✅ Reviews criados com status "pending"
- ✅ Admin aprova/rejeita reviews
- ✅ Comentários com palavras-chave são sinalizados
- ✅ Histórico de moderação

---

## 📊 Tipos de Ratings

### Rating Geral (1-5 estrelas)
- 5 ⭐ — Excelente
- 4 ⭐ — Muito Bom
- 3 ⭐ — Bom
- 2 ⭐ — Razoável
- 1 ⭐ — Ruim

### Ratings Específicos (Opcionais)
- **Limpeza**: 1-5 (estado geral do banheiro)
- **Acessibilidade**: 1-5 (adaptação para DII)
- **Espaçosidade**: 1-5 (tamanho e conforto)

---

## 🎯 Fluxo de Review

```
1. Utilizador abre banheiro no mapa
   ↓
2. Clica em "Deixar Avaliação"
   ↓
3. Preenche formulário (rating, comentário, fotos)
   ↓
4. Submete review
   ↓
5. Backend valida e salva com status "pending"
   ↓
6. Admin aprova/rejeita
   ↓
7. Se aprovado, aparece no mapa para outros utilizadores
   ↓
8. Outros utilizadores votam se foi útil
```

---

## ✅ Consequências

### Positivas
✅ Comunidade engajada (ratings incentivam participação)  
✅ Qualidade de dados (reviews ajudam a manter banheiros atualizados)  
✅ Confiança (ratings ajudam na escolha)  
✅ Soberania de dados (sem dependências)  
✅ Customização total (ratings específicos para DII)  
✅ Moderação controlada  

### Negativas
⚠️ Requer moderação manual  
⚠️ Possível spam/conteúdo inapropriado  
⚠️ Overhead de armazenamento (fotos)  
⚠️ Complexidade de implementação  

---

## 📅 Timeline

| Fase | Duração | Responsável |
|---|---|---|
| Design & ADR | 1 dia | @Architect |
| Backend (CRUD) | 2 dias | @Backend |
| Frontend (UI) | 2 dias | @Coder |
| Testes | 1 dia | @TestEngineer |
| Code Review | 1 dia | @Reviewer |
| **Total** | **~7 dias** | **Sprint** |

---

## 🔗 Referências

- PostgreSQL UNIQUE constraints
- File upload best practices
- Content moderation strategies
- Rating systems design

---

## ✍️ Aprovação

- [ ] @Gabriel — Aprovação final
- [ ] @Architect — Design validado
- [ ] @Backend — Viabilidade confirmada
- [ ] @Coder — Integração possível

---

<div align="center">

**ADR-002: Sistema de Ratings e Reviews para Banheiros**

Status: 🟡 Proposto | Data: 2026-05-12

</div>
