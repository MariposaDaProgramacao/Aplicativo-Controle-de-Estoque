-- ============================================================
-- 📊 BOXSTOCK - BANCO DE DADOS (FIRESTORE)
-- ============================================================
-- Projeto: BoxStock - Controle de Estoque
-- Tecnologia: Cloud Firestore (Firebase)
-- Autor: [Seu Nome]
-- Data: 25/08/2026
-- ============================================================

-- ============================================================
-- 📋 ÍNDICES CRIADOS NO FIRESTORE
-- ============================================================

-- ------------------------------------------------------------
-- 1. ÍNDICE PARA COLEÇÃO "produtos"
-- ------------------------------------------------------------
-- Motivo: Filtrar produtos por usuário e ordenar por nome
-- Campos:
--   - usuarioId (Crescente)
--   - nome (Crescente)
-- 
-- Comando equivalente no Firebase Console:
-- CREATE INDEX idx_produtos_usuario_nome
-- ON produtos (usuarioId ASC, nome ASC);

-- ------------------------------------------------------------
-- 2. ÍNDICE PARA COLEÇÃO "movimentacoes"
-- ------------------------------------------------------------
-- Motivo: Filtrar movimentações por usuário e mostrar as mais recentes
-- Campos:
--   - usuarioId (Crescente)
--   - createdAt (Decrescente)
-- 
-- Comando equivalente no Firebase Console:
-- CREATE INDEX idx_movimentacoes_usuario_data
-- ON movimentacoes (usuarioId ASC, createdAt DESC);

-- ------------------------------------------------------------
-- 3. ÍNDICE PARA COLEÇÃO "lista_compras"
-- ------------------------------------------------------------
-- Motivo: Filtrar lista por usuário, separar pendentes/comprados
--         e mostrar os mais recentes
-- Campos:
--   - usuarioId (Crescente)
--   - comprado (Crescente)
--   - createdAt (Decrescente)
-- 
-- Comando equivalente no Firebase Console:
-- CREATE INDEX idx_lista_compras_usuario_status_data
-- ON lista_compras (usuarioId ASC, comprado ASC, createdAt DESC);


-- ============================================================
-- 🔒 REGRAS DE SEGURANÇA DO FIRESTORE
-- ============================================================
-- Cole este bloco no Firebase Console -> Regras
-- ============================================================

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    -- 🔐 FUNÇÕES DE SEGURANÇA
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    -- 👤 USUÁRIOS
    match /usuarios/{userId} {
      allow read, create, update: if isAuthenticated() && isOwner(userId);
      allow delete: if false;
    }
    
    -- 📦 PRODUTOS
    match /produtos/{productId} {
      allow read: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.usuarioId == request.auth.uid;
      allow update: if isAuthenticated() 
        && resource.data.usuarioId == request.auth.uid
        && request.resource.data.usuarioId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
    }
    
    -- 📜 MOVIMENTAÇÕES
    match /movimentacoes/{movimentoId} {
      allow read: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.usuarioId == request.auth.uid;
      allow update: if isAuthenticated() 
        && resource.data.usuarioId == request.auth.uid
        && request.resource.data.usuarioId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
    }
    
    -- 🏷️ CATEGORIAS
    match /categorias/{categoriaId} {
      allow read: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.usuarioId == request.auth.uid;
      allow update: if isAuthenticated() 
        && resource.data.usuarioId == request.auth.uid
        && request.resource.data.usuarioId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
    }
    
    -- 🛒 LISTA DE COMPRAS
    match /lista_compras/{itemId} {
      allow read: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.usuarioId == request.auth.uid;
      allow update: if isAuthenticated() 
        && resource.data.usuarioId == request.auth.uid
        && request.resource.data.usuarioId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
    }
    
    -- 🚫 BLOQUEIA OUTRAS COLEÇÕES
    match /{document=**} {
      allow read, write: if false;
    }
  }
}


-- ============================================================
-- 📝 ESTRUTURA DAS COLEÇÕES
-- ============================================================

-- ------------------------------------------------------------
-- COLEÇÃO: usuarios
-- ------------------------------------------------------------
-- Campos:
--   - uid (string): ID do usuário (igual ao Auth UID)
--   - email (string): E-mail do usuário
--   - displayName (string): Nome de exibição
--   - photoURL (string): URL da foto
--   - emailVerified (boolean): E-mail verificado?
--   - createdAt (timestamp): Data de criação
--   - updatedAt (timestamp): Data de atualização
--   - lastLogin (timestamp): Último login
--   - isActive (boolean): Conta ativa?

-- ------------------------------------------------------------
-- COLEÇÃO: produtos
-- ------------------------------------------------------------
-- Campos:
--   - nome (string): Nome do produto
--   - codigo (string): Código/SKU do produto
--   - categoria (string): Categoria do produto
--   - descricao (string): Descrição do produto
--   - quantidade (number): Quantidade em estoque
--   - estoqueMinimo (number): Quantidade mínima em estoque
--   - precoCusto (number): Preço de custo
--   - precoVenda (number): Preço de venda
--   - usuarioId (string): ID do usuário dono do produto
--   - createdAt (timestamp): Data de criação
--   - updatedAt (timestamp): Data de atualização

-- ------------------------------------------------------------
-- COLEÇÃO: movimentacoes
-- ------------------------------------------------------------
-- Campos:
--   - produtoId (string): ID do produto
--   - produtoNome (string): Nome do produto (denormalizado)
--   - tipo (string): 'entrada' ou 'saida'
--   - quantidade (number): Quantidade movimentada
--   - precoUnitario (number): Preço unitário (opcional)
--   - observacao (string): Observação (opcional)
--   - usuarioId (string): ID do usuário que fez a movimentação
--   - usuarioEmail (string): E-mail do usuário (denormalizado)
--   - createdAt (timestamp): Data da movimentação

-- ------------------------------------------------------------
-- COLEÇÃO: categorias
-- ------------------------------------------------------------
-- Campos:
--   - nome (string): Nome da categoria
--   - usuarioId (string): ID do usuário dono da categoria
--   - createdAt (timestamp): Data de criação

-- ------------------------------------------------------------
-- COLEÇÃO: lista_compras
-- ------------------------------------------------------------
-- Campos:
--   - produtoId (string): ID do produto
--   - produtoNome (string): Nome do produto (denormalizado)
--   - codigo (string): Código do produto (denormalizado)
--   - categoria (string): Categoria do produto (denormalizado)
--   - quantidadeNecessaria (number): Quantidade que precisa comprar
--   - quantidadeAtual (number): Quantidade atual em estoque
--   - estoqueMinimo (number): Estoque mínimo do produto
--   - usuarioId (string): ID do usuário
--   - comprado (boolean): Item já foi comprado?
--   - createdAt (timestamp): Data de criação
--   - updatedAt (timestamp): Data de atualização


-- ============================================================
-- 📊 CATEGORIAS PRÉ-DEFINIDAS
-- ============================================================

INSERT INTO categorias (nome) VALUES ('Informática');
INSERT INTO categorias (nome) VALUES ('Periféricos');
INSERT INTO categorias (nome) VALUES ('Eletrônicos');
INSERT INTO categorias (nome) VALUES ('Escritório');
INSERT INTO categorias (nome) VALUES ('Acessórios');
INSERT INTO categorias (nome) VALUES ('Alimentos');
INSERT INTO categorias (nome) VALUES ('Bebidas');
INSERT INTO categorias (nome) VALUES ('Limpeza');
INSERT INTO categorias (nome) VALUES ('Higiene');
INSERT INTO categorias (nome) VALUES ('Vestuário');
INSERT INTO categorias (nome) VALUES ('Calçados');
INSERT INTO categorias (nome) VALUES ('Livros');
INSERT INTO categorias (nome) VALUES ('Brinquedos');
INSERT INTO categorias (nome) VALUES ('Ferramentas');
INSERT INTO categorias (nome) VALUES ('Automotivo');
INSERT INTO categorias (nome) VALUES ('Construção');
INSERT INTO categorias (nome) VALUES ('Outros');


-- ============================================================
-- 📝 NOTAS SOBRE O FIRESTORE
-- ============================================================
-- 1. Firestore é um banco de dados NoSQL orientado a documentos.
-- 2. As "tabelas" são chamadas de "coleções".
-- 3. As "linhas" são chamadas de "documentos".
-- 4. Os índices são criados automaticamente pelo Firebase Console.
-- 5. As regras de segurança são escritas em uma linguagem própria.
-- 6. Os timestamps são salvos como objetos Timestamp do Firebase.
-- 7. As queries precisam de índices compostos para filtros + ordenação.
-- 8. Cada usuário só vê seus próprios dados (graças às regras).
-- 9. Os dados são sincronizados em tempo real com o app.
-- 10. O Firestore é escalável e cobra por operações de leitura/escrita.