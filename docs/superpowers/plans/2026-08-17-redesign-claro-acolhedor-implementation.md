# Redesign Claro e Acolhedor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplicar visual claro, acolhedor e confiável ao Completai, com hierarquia tipográfica calma e experiência melhor nas três superfícies críticas.

**Architecture:** `AppTheme` continua autoridade de tokens. Componentes compartilhados encapsulam cabeçalho, frescor e preço; views só compõem domínio. Mudanças de UX ficam locais e não alteram Firestore.

**Tech Stack:** Flutter, Material 3, Dart, flutter_test.

## Global Constraints

- Android é plataforma de entrega.
- Sem dependência nova.
- Sem dados, claims, distância ou histórico inventados.
- Uma única cor semântica por papel.
- Cada mudança visual atualiza documentos; `firestore.rules` só muda quando autorização/dados mudam.

---

### Task 1: Tema claro e escala tipográfica

**Files:** `lib/core/theme/app_theme.dart`, `lib/app/app_widget.dart`, `test/design_system_test.dart`.

- [ ] Escrever testes esperando `Brightness.light`, paleta quente e papéis tipográficos.
- [ ] Executar teste e confirmar falha por tema ainda escuro.
- [ ] Implementar `lightTheme`, manter alias temporário compatível e migrar app.
- [ ] Executar testes e confirmar passagem.

### Task 2: Componentes de confiança

**Files:** `lib/core/widgets/price_display.dart`, `lib/core/widgets/status_pill.dart`, criar `lib/core/widgets/trust_badge.dart`, criar `lib/core/widgets/welcome_summary_header.dart`, `test/station_visual_components_test.dart`.

- [ ] Escrever testes de semântica, tipografia e conteúdo.
- [ ] Confirmar falhas por componentes ausentes.
- [ ] Implementar componentes mínimos.
- [ ] Confirmar passagem.

### Task 3: Lista clara e viva

**Files:** `lib/features/user/views/station_list_page.dart`, criar `test/station_list_visual_test.dart`.

- [ ] Escrever testes para cabeçalho, resumo e destaque do primeiro resultado.
- [ ] Confirmar falha.
- [ ] Compor lista com dados existentes e sem distância.
- [ ] Confirmar passagem.

### Task 4: Perfil público confiável

**Files:** `lib/features/user/views/public_station_profile_page.dart`, criar `test/public_station_profile_visual_test.dart`.

- [ ] Escrever teste para origem/frescor, hierarquia de preço e ausência de histórico inventado.
- [ ] Confirmar falha.
- [ ] Reorganizar seções e aplicar superfícies tonais.
- [ ] Confirmar passagem.

### Task 5: Atualização de preços agradável

**Files:** `lib/features/gas_station/views/station_dashboard_page.dart`, criar `test/station_dashboard_price_visual_test.dart`.

- [ ] Escrever testes para contador de mudanças e confirmação contextual.
- [ ] Confirmar falha.
- [ ] Implementar detecção local, proteção de saída e barra de publicação.
- [ ] Confirmar passagem.

### Task 6: Documentação e verificação

**Files:** `DESIGN.md`, `docs/DESIGN-E-INTERFACE.md`, `docs/ARQUITETURA.md`, `docs/VISAO-GERAL-E-ESTRUTURA.md`, `docs/README.md`.

- [ ] Atualizar autoridade visual e protocolo de novas telas.
- [ ] Registrar oportunidades de imagem e decisão de não alterar `firestore.rules`.
- [ ] Rodar `dart format`, `flutter analyze`, `flutter test` e `flutter build apk --debug`.
- [ ] Registrar limite de inspeção Android se nenhum dispositivo estiver disponível.
