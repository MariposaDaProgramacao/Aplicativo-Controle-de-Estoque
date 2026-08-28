-- ============================================================
-- 📁 banco_dados.sql
-- ============================================================
-- 🎯 O QUE É ESSE ARQUIVO?
-- 
-- 🔍 ANALOGIA: Imagine que você tem um "MAPA DO TESOURO"
--              que mostra onde cada coisa está guardada.
--              Esse arquivo é o MAPA que mostra:
--              - Onde ficam os produtos (coleção "produtos")
--              - Onde ficam as movimentações (coleção "movimentacoes")
--              - Onde fica a lista de compras (coleção "lista_compras")
--              - Quais são as regras de segurança
--              - Quais índices foram criados para acelerar as buscas
-- 
-- 🏠 Ele é como a "PLANTA BAIXA" do seu estoque.
--    Mostra:
--    - O que cada "gaveta" (coleção) guarda
--    - Quem pode abrir cada gaveta (regras de segurança)
--    - Como encontrar as coisas mais rápido (índices)
-- ============================================================

-- ============================================================
-- 📊 BOXSTOCK - BANCO DE DADOS (FIRESTORE)
-- ============================================================
-- 🔍 ANALOGIA: É como a "IDENTIFICAÇÃO" do mapa.
--              Diz o nome do projeto, a tecnologia usada,
--              quem fez e quando foi feito.
-- ============================================================

-- Projeto: BoxStock - Controle de Estoque
-- Tecnologia: Cloud Firestore (Firebase)
-- Autor: [Seu Nome]
-- Data: 25/08/2026

-- ============================================================
-- 📋 ÍNDICES CRIADOS NO FIRESTORE
-- ============================================================
-- 🔍 ANALOGIA: Índices são como o "SUMÁRIO" de um livro.
--              Em vez de ler o livro inteiro para achar uma
--              informação, você olha no sumário e vai direto
--              na página certa. Eles aceleram as buscas!
-- ============================================================

-- ------------------------------------------------------------
-- 1. ÍNDICE PARA COLEÇÃO "produtos"
-- ------------------------------------------------------------
-- 🔍 ANALOGIA: É como ter uma "LISTA TELEFÔNICA" dos produtos.
--              Você pode procurar por nome (ordem alfabética)
--              e só ver os produtos de um usuário específico.
-- 
-- Motivo: Filtrar produtos por usuário e ordenar por nome
-- Campos:
--   - usuarioId (Crescente) → Primeiro separa por usuário
--   - nome (Crescente) → Depois ordena por nome (A-Z)
-- 
-- Exemplo de uso: "Me mostre todos os produtos do João,
--                  em ordem alfabética"
CREATE INDEX idx_produtos_usuario_nome
ON produtos (usuarioId ASC, nome ASC);

-- ------------------------------------------------------------
-- 2. ÍNDICE PARA COLEÇÃO "movimentacoes"
-- ------------------------------------------------------------
-- 🔍 ANALOGIA: É como ter um "DIÁRIO" onde as entradas
--              mais recentes aparecem primeiro.
--              Você pode ver as movimentações do usuário
--              e as mais recentes em cima.
-- 
-- Motivo: Filtrar movimentações por usuário e mostrar as mais recentes
-- Campos:
--   - usuarioId (Crescente) → Primeiro separa por usuário
--   - createdAt (Decrescente) → Depois ordena da mais nova para a mais antiga
-- 
-- Exemplo de uso: "Me mostre as últimas 10 movimentações
--                  do usuário João"
CREATE INDEX idx_movimentacoes_usuario_data
ON movimentacoes (usuarioId ASC, createdAt DESC);

-- ------------------------------------------------------------
-- 3. ÍNDICE PARA COLEÇÃO "lista_compras"
-- ------------------------------------------------------------
-- 🔍 ANALOGIA: É como ter uma "LISTA DE COMPRAS" organizada.
--              Primeiro separa por usuário,
--              depois separa o que já foi comprado do que não foi,
--              e mostra os mais recentes primeiro.
-- 
-- Motivo: Filtrar lista por usuário, separar pendentes/comprados
--         e mostrar os mais recentes
-- Campos:
--   - usuarioId (Crescente) → Primeiro separa por usuário
--   - comprado (Crescente) → Depois separa "false" (pendentes) e "true" (comprados)
--   - createdAt (Decrescente) → Por último, ordena do mais recente para o mais antigo
-- 
-- Exemplo de uso: "Me mostre os itens pendentes de compra
--                  do usuário João, começando pelos mais antigos"
CREATE INDEX idx_lista_compras_usuario_status_data
ON lista_compras (usuarioId ASC, comprado ASC, createdAt DESC);


-- ============================================================
-- 🔒 REGRAS DE SEGURANÇA DO FIRESTORE
-- ============================================================
-- 🔍 ANALOGIA: São as "REGRAS DA CASA".
--              Dizem quem pode entrar, quem pode ver o que,
--              e quem pode mexer nas coisas.
-- 
--              É como ter um "PORTERO" na porta do seu estoque
--              que só deixa entrar quem tem a chave certa.
-- 
-- Cole este bloco no Firebase Console -> Regras
-- ============================================================

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    -- 🔐 FUNÇÕES DE SEGURANÇA (as "regras da casa")
    -- 🔍 Analogia: São como as "PERGUNTAS" que o porteiro faz:
    --              "Você está autenticado?" (tem a chave?)
    --              "Você é o dono disso?" (é a sua casa?)
    -- ============================================================

    -- 🔐 Verifica se o usuário está logado
    --    Analogia: "Você tem a chave para entrar?"
    function isAuthenticated() {
      return request.auth != null;
    }
    
    -- 🔐 Verifica se o usuário é o dono do documento
    --    Analogia: "Você é o dono desta casa?"
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    -- 👤 USUÁRIOS (a "porta" dos usuários)
    --    Analogia: É a "porta da frente" da sua casa.
    --              Só você pode abrir, ver e modificar seus dados.
    match /usuarios/{userId} {
      allow read, create, update: if isAuthenticated() && isOwner(userId);
      allow delete: if false; -- Ninguém pode deletar usuários (nem você!)
    }
    
    -- 📦 PRODUTOS (a "porta" dos produtos)
    --    Analogia: É a "porta do armazém" onde ficam os produtos.
    --              Só você pode ver, criar, modificar e deletar
    --              os produtos que estão no seu armazém.
    match /produtos/{productId} {
      allow read: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.usuarioId == request.auth.uid;
      allow update: if isAuthenticated() 
        && resource.data.usuarioId == request.auth.uid
        && request.resource.data.usuarioId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
    }
    
    -- 📜 MOVIMENTAÇÕES (a "porta" do histórico)
    --    Analogia: É a "porta do diário" onde você registra
    --              tudo que entra e sai do estoque.
    match /movimentacoes/{movimentoId} {
      allow read: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.usuarioId == request.auth.uid;
      allow update: if isAuthenticated() 
        && resource.data.usuarioId == request.auth.uid
        && request.resource.data.usuarioId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
    }
    
    -- 🏷️ CATEGORIAS (a "porta" das categorias)
    --    Analogia: É a "porta das gavetas" onde você guarda
    --              os produtos separados por categoria.
    match /categorias/{categoriaId} {
      allow read: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.usuarioId == request.auth.uid;
      allow update: if isAuthenticated() 
        && resource.data.usuarioId == request.auth.uid
        && request.resource.data.usuarioId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
    }
    
    -- 🛒 LISTA DE COMPRAS (a "porta" da lista de compras)
    --    Analogia: É a "porta do carrinho de compras".
    --              Só você pode ver, criar, modificar e deletar
    --              os itens da sua lista de compras.
    match /lista_compras/{itemId} {
      allow read: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.usuarioId == request.auth.uid;
      allow update: if isAuthenticated() 
        && resource.data.usuarioId == request.auth.uid
        && request.resource.data.usuarioId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.usuarioId == request.auth.uid;
    }
    
    -- 🚫 BLOQUEIA OUTRAS COLEÇÕES
    --    Analogia: É a "porta trancada" que ninguém pode abrir.
    --              Se alguém tentar criar uma coleção nova,
    --              o sistema bloqueia.
    match /{document=**} {
      allow read, write: if false;
    }
  }
}


-- ============================================================
-- 📝 ESTRUTURA DAS COLEÇÕES
-- ============================================================
-- 🔍 ANALOGIA: É como a "DESCRIÇÃO DOS MÓVEIS" da sua casa.
--              Mostra o que cada gaveta guarda e como está
--              organizado.
-- ============================================================

-- ------------------------------------------------------------
-- COLEÇÃO: usuarios (os "moradores" da casa)
-- ------------------------------------------------------------
-- 🔍 Analogia: É a "GAVETA DOS MORADORES" onde guardamos
--              os dados de cada usuário.
-- 
-- Campos:
--   - uid (string): O "RG" do usuário (igual ao Auth UID)
--   - email (string): O "e-mail" do usuário
--   - displayName (string): O "nome" que aparece
--   - photoURL (string): A "foto" do usuário
--   - emailVerified (boolean): O e-mail já foi confirmado?
--   - createdAt (timestamp): Quando o usuário entrou na casa
--   - updatedAt (timestamp): Quando foi a última atualização
--   - lastLogin (timestamp): Quando foi o último login
--   - isActive (boolean): A conta está ativa?

-- ------------------------------------------------------------
-- COLEÇÃO: produtos (a "despensa" do estoque)
-- ------------------------------------------------------------
-- 🔍 Analogia: É a "GAVETA DOS PRODUTOS" onde guardamos
--              todos os produtos do estoque.
-- 
-- Campos:
--   - nome (string): O "nome" do produto
--   - codigo (string): O "código de barras" do produto
--   - categoria (string): Em qual "gaveta" o produto fica
--   - descricao (string): O que o produto faz
--   - quantidade (number): Quantos têm na prateleira
--   - estoqueMinimo (number): O "alerta" para não deixar vazio
--   - precoCusto (number): Quanto custou para comprar
--   - precoVenda (number): Por quanto vende
--   - usuarioId (string): De quem é o produto
--   - createdAt (timestamp): Quando chegou
--   - updatedAt (timestamp): Quando foi atualizado pela última vez

-- ------------------------------------------------------------
-- COLEÇÃO: movimentacoes (o "diário de bordo")
-- ------------------------------------------------------------
-- 🔍 Analogia: É a "GAVETA DO DIÁRIO" onde registramos
--              tudo que entra e sai do estoque.
-- 
-- Campos:
--   - produtoId (string): Qual produto foi movimentado
--   - produtoNome (string): O nome do produto (cópia para facilitar)
--   - tipo (string): "entrada" ou "saida" (entrou ou saiu)
--   - quantidade (number): Quantas unidades
--   - precoUnitario (number): Quanto custou cada unidade (opcional)
--   - observacao (string): Um comentário sobre a movimentação
--   - usuarioId (string): Quem fez a movimentação
--   - usuarioEmail (string): O e-mail de quem fez (cópia)
--   - createdAt (timestamp): Quando aconteceu

-- ------------------------------------------------------------
-- COLEÇÃO: categorias (as "gavetas" do estoque)
-- ------------------------------------------------------------
-- 🔍 Analogia: É a "GAVETA DAS CATEGORIAS" onde guardamos
--              os nomes das categorias para organizar os produtos.
-- 
-- Campos:
--   - nome (string): O nome da categoria
--   - usuarioId (string): De quem é a categoria
--   - createdAt (timestamp): Quando foi criada

-- ------------------------------------------------------------
-- COLEÇÃO: lista_compras (o "carrinho de compras")
-- ------------------------------------------------------------
-- 🔍 Analogia: É a "GAVETA DO CARRINHO" onde colocamos
--              os produtos que precisam ser comprados.
-- 
-- Campos:
--   - produtoId (string): Qual produto precisa ser comprado
--   - produtoNome (string): O nome do produto (cópia)
--   - codigo (string): O código do produto (cópia)
--   - categoria (string): A categoria do produto (cópia)
--   - quantidadeNecessaria (number): Quantas unidades precisa comprar
--   - quantidadeAtual (number): Quantas tem agora
--   - estoqueMinimo (number): O mínimo que deve ter
--   - usuarioId (string): De quem é a lista
--   - comprado (boolean): Já foi comprado?
--   - createdAt (timestamp): Quando foi adicionado à lista
--   - updatedAt (timestamp): Quando foi atualizado pela última vez


-- ============================================================
-- 📊 CATEGORIAS PRÉ-DEFINIDAS
-- ============================================================
-- 🔍 Analogia: É como ter uma "LISTA DE COMPRAS PRONTA"
--              com as categorias mais comuns.
--              O usuário pode escolher uma delas.
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
-- 🔍 Analogia: É como as "INSTRUÇÕES DE USO" do seu sistema.
--              Explica como tudo funciona.
-- ============================================================

-- 1. Firestore é um banco de dados NoSQL orientado a documentos.
--    (É como uma "grande estante" onde cada documento é uma "caixa")

-- 2. As "tabelas" são chamadas de "coleções".
--    (São as "prateleiras" da estante)

-- 3. As "linhas" são chamadas de "documentos".
--    (São as "caixas" nas prateleiras)

-- 4. Os índices são criados automaticamente pelo Firebase Console.
--    (É como o "sistema de organização" que coloca as caixas em ordem)

-- 5. As regras de segurança são escritas em uma linguagem própria.
--    (É o "manual de segurança" que diz quem pode mexer em cada caixa)

-- 6. Os timestamps são salvos como objetos Timestamp do Firebase.
--    (É como uma "etiqueta de data" colada em cada caixa)

-- 7. As queries precisam de índices compostos para filtros + ordenação.
--    (É como ter um "índice remissivo" para achar as caixas mais rápido)

-- 8. Cada usuário só vê seus próprios dados (graças às regras).
--    (É como ter uma "chave" que só abre a sua própria caixa)

-- 9. Os dados são sincronizados em tempo real com o app.
--    (É como ter um "espelho" que mostra as mudanças na hora)

-- 10. O Firestore é escalável e cobra por operações de leitura/escrita.
--     (É como pagar por cada vez que você abre ou guarda uma caixa)