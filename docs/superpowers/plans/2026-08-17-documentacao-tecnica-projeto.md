# Documentação Técnica do Projeto — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Registrar arquitetura, estrutura, modelo de dados, regras, segurança, qualidade e interface do Completai com rastreabilidade ao código atual.

**Architecture:** A documentação será dividida por responsabilidade para evitar um arquivo monolítico. Um índice central conecta seis documentos especializados; cada afirmação relevante aponta para arquivos-fonte ou configuração do repositório.

**Tech Stack:** Markdown, Flutter/Dart, Firebase Authentication, Cloud Firestore, regras Firestore.

## Global Constraints

- Não alterar comportamento ou código da aplicação.
- Documentar estado observado em 17/08/2026, distinguindo fato, inferência e recomendação.
- Cobrir projeto inteiro, com foco no código autoral em `lib/`, `test/`, `firestore.rules` e configurações.
- Usar avaliação Impeccable para design/interface; registrar limitações de cobertura do detector em Flutter.

---

### Task 1: Índice e visão geral

**Files:**
- Create: `docs/README.md`
- Create: `docs/VISAO-GERAL-E-ESTRUTURA.md`

**Interfaces:**
- Consumes: árvore real do repositório, `pubspec.yaml`, `lib/main.dart` e `lib/app/`.
- Produces: mapa documental e vocabulário comum usado pelos demais documentos.

- [x] **Step 1: Mapear diretórios e tecnologias**
- [x] **Step 2: Registrar responsabilidades e pontos de entrada**
- [x] **Step 3: Criar navegação entre documentos**

### Task 2: Arquitetura e fluxos

**Files:**
- Create: `docs/ARQUITETURA.md`

**Interfaces:**
- Consumes: imports, rotas, views, viewmodels, repositories e services.
- Produces: visão de camadas, dependências, fluxos e dívida arquitetural.

- [x] **Step 1: Descrever arquitetura observada, sem idealizá-la**
- [x] **Step 2: Diagramar inicialização, login e dados públicos**
- [x] **Step 3: Priorizar riscos de acoplamento e escalabilidade**

### Task 3: Modelo, regras e segurança

**Files:**
- Create: `docs/MODELO-DE-DADOS.md`
- Create: `docs/REGRAS-DE-NEGOCIO-E-SEGURANCA.md`

**Interfaces:**
- Consumes: models, services, `firebase.json` e `firestore.rules`.
- Produces: catálogo de coleções/campos, invariantes e análise de autorização.

- [x] **Step 1: Documentar entidades e relações**
- [x] **Step 2: Cruzar validações Dart e regras Firestore**
- [x] **Step 3: Registrar falhas de papel, ciclo de vida e consistência**

### Task 4: Design, interface e qualidade

**Files:**
- Create: `docs/DESIGN-E-INTERFACE.md`
- Create: `docs/QUALIDADE-RISCOS-E-ROADMAP.md`

**Interfaces:**
- Consumes: Assessment A independente, detector Impeccable, análise Dart e testes.
- Produces: score UX, prioridades visuais, riscos técnicos e roadmap.

- [x] **Step 1: Sintetizar crítica Impeccable com evidências**
- [x] **Step 2: Registrar limites do detector e inspeção visual**
- [x] **Step 3: Ordenar roadmap por severidade e dependência**

### Task 5: Verificação documental

**Files:**
- Verify: `docs/**/*.md`

**Interfaces:**
- Consumes: todos os documentos criados.
- Produces: conjunto navegável, sem placeholders e coerente com código.

- [x] **Step 1: Verificar links e arquivos referenciados**
- [x] **Step 2: Procurar placeholders e contradições**
- [x] **Step 3: Conferir alterações finais e entregar**

### Task 6: Incorporar TAP

**Files:**
- Create: `docs/TAP-E-RASTREABILIDADE.md`
- Modify: `docs/README.md`
- Modify: `docs/QUALIDADE-RISCOS-E-ROADMAP.md`

**Interfaces:**
- Consumes: `TAP-TERMO DE ABERTURA DE PROJETO 2026.docx` e implementação observada.
- Produces: matriz de rastreabilidade, conflitos, critérios de aceite e riscos de escopo.

- [x] **Step 1: Extrair integralmente texto e tabelas do TAP**
- [x] **Step 2: Distinguir conteúdo do modelo de requisitos do projeto**
- [x] **Step 3: Cruzar escopo, não-escopo, premissas, restrições e riscos com código**
- [x] **Step 4: Atualizar índice e roadmap**
