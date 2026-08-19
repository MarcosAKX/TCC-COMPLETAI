# Identidade Agilidade Urbana Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplicar no Flutter a identidade visual aprovada, incluindo splash, autenticação e descoberta, sem alterar regras Firebase nem navegação por papéis.

**Architecture:** A identidade será concentrada em tokens de tema e componentes visuais reutilizáveis. As páginas existentes manterão seus viewmodels, serviços e contratos de navegação; somente composição, superfícies, espaçamento e estados visuais serão atualizados.

**Tech Stack:** Flutter 3.47, Dart 3.13, Material 3, Firebase, flutter_test.

**Spec:** `docs/superpowers/specs/2026-08-18-identidade-agilidade-urbana-design.md`

## Global Constraints

- Azul principal `#315EFB`; fundo `#F6F7F9`; descoberta `#E8EEFF`; cards brancos.
- Sem gradientes, neon, glassmorphism, novas fontes externas ou dados novos.
- Não alterar Firebase, modelos, serviços ou redirecionamento por papel.
- Alvos interativos mínimos de 48 dp e suporte a redução de movimento.
- A rota completa aparece apenas em splash/login; nas demais telas, somente variantes compactas funcionais.

---

### Task 1: Fundação visual e assinatura de rota

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Create: `lib/core/widgets/urban_route_signature.dart`
- Create: `lib/core/widgets/brand_hero_panel.dart`
- Create: `lib/core/widgets/auth_surface_card.dart`
- Test: `test/urban_identity_components_test.dart`

**Interfaces:**
- Produces: `UrbanRouteSignature(variant)`, `BrandHeroPanel`, `AuthSurfaceCard`.

- [ ] Escrever testes de widget que exijam os três componentes, suas chaves semânticas e os tokens `discoveryBackground` e `authBackground`.
- [ ] Executar `flutter test test/urban_identity_components_test.dart` e confirmar falha por componentes ausentes.
- [ ] Implementar os componentes com `CustomPainter`, superfícies sólidas e semântica decorativa excluída.
- [ ] Executar o teste e confirmar aprovação.

### Task 2: Splash e entrada do aplicativo

**Files:**
- Create: `lib/features/splash/views/splash_page.dart`
- Modify: `lib/app/app_routes.dart`
- Modify: `lib/app/app_widget.dart`
- Test: `test/splash_page_test.dart`

**Interfaces:**
- Consumes: `UrbanRouteSignature`, `AppRoutes.login`.
- Produces: `AppRoutes.splash` e `SplashPage` com transição substitutiva para login.

- [ ] Escrever teste com duração injetável que exija marca, frase e navegação para login.
- [ ] Executar o teste e confirmar falha por splash ausente.
- [ ] Implementar splash sólida azul, animação única da rota e respeito a redução de movimento.
- [ ] Executar o teste e confirmar aprovação.

### Task 3: Autenticação coesa

**Files:**
- Modify: `lib/features/auth/views/login_page.dart`
- Modify: `lib/features/auth/views/register_type_page.dart`
- Modify: `lib/features/auth/views/register_user_page.dart`
- Modify: `lib/features/auth/views/forgot_password_page.dart`
- Modify: `lib/features/gas_station/views/register_station_step_one_page.dart`
- Modify: `lib/features/gas_station/views/register_station_step_two_page.dart`
- Modify: `lib/core/widgets/brand_header.dart`
- Modify: `lib/core/widgets/step_progress_header.dart`
- Test: `test/auth_visual_flow_test.dart`

**Interfaces:**
- Consumes: `BrandHeroPanel`, `AuthSurfaceCard`, `UrbanRouteSignature`.
- Preserves: controllers, validação, loading e rotas existentes.

- [ ] Atualizar testes para exigir o hero, card sobreposto, CTA contornado e progresso por waypoints.
- [ ] Executar os testes de autenticação e confirmar falha visual esperada.
- [ ] Recompor as páginas sem alterar suas ações ou viewmodels.
- [ ] Executar os testes e confirmar aprovação, incluindo viewport compacto e texto ampliado.

### Task 4: Descoberta e continuidade nas telas secundárias

**Files:**
- Modify: `lib/features/user/views/station_list_page.dart`
- Modify: `lib/features/user/widgets/fuel_choice_selector.dart`
- Modify: `lib/features/user/widgets/discovery_station_card.dart`
- Modify: `lib/core/widgets/welcome_summary_header.dart`
- Modify: `lib/features/user/views/public_station_profile_page.dart`
- Modify: `lib/features/user/views/profile_page.dart`
- Modify: `lib/features/user/views/settings_page.dart`
- Modify: `lib/features/gas_station/views/station_dashboard_page.dart`
- Modify: `lib/features/gas_station/views/station_profile_page.dart`
- Test: `test/station_discovery_widgets_test.dart`
- Test: `test/station_visual_components_test.dart`

**Interfaces:**
- Produces: faixa azul de combustível, resultado azul-gelo e cards brancos; preserva callbacks e filtros.

- [ ] Atualizar testes para exigir faixa sólida, opção ativa branca, fundo contextual e destaque lateral apenas no melhor resultado.
- [ ] Executar os testes e confirmar falhas visuais esperadas.
- [ ] Aplicar a composição aprovada e alinhar telas secundárias aos mesmos tokens e superfícies.
- [ ] Executar os testes e confirmar aprovação.

### Task 5: Verificação integrada

**Files:**
- Modify somente arquivos já listados se a verificação revelar problemas.

- [ ] Executar `dart format lib test`.
- [ ] Executar `flutter analyze` e corrigir todos os diagnósticos introduzidos.
- [ ] Executar `flutter test` e obter zero falhas.
- [ ] Executar `flutter run -d web-server --no-pub` e inspecionar splash, login e descoberta em largura compacta.
- [ ] Comparar cada requisito da especificação com a implementação e registrar qualquer limitação real.
