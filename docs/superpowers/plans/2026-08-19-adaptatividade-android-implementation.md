# Adaptatividade Android Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tornar os fluxos existentes integralmente utilizáveis em celulares Android compactos, em paisagem, com teclado aberto e escala de texto até 2,0×.

**Architecture:** Uma camada pequena de widgets adaptativos centraliza largura, insets e reflow. As telas são migradas por risco, preservando identidade e comportamento; testes de widget renderizam os mesmos cenários de janela e escala para impedir novos overflows.

**Tech Stack:** Flutter 3.44, Dart 3.12, Material 3, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-08-19-adaptatividade-android-design.md`

## Global Constraints

- Suportar celulares Android entre 320 e 600 dp, retrato e paisagem.
- Suportar escala de texto do sistema até 2,0× sem limitar `textScaler`.
- Preservar a identidade visual atual; não redesenhar as telas.
- Não usar altura fixa em blocos que contêm texto variável.
- Manter ações e conteúdo essenciais acessíveis por scroll.
- Manter alvos interativos com pelo menos 48×48 dp.
- Não bloquear orientação nem detectar modelo de aparelho.
- Tablets e foldables expandidos permanecem fora deste plano.

---

### Task 1: Harness de cenários adaptativos

**Files:**
- Create: `test/helpers/adaptive_test_harness.dart`
- Create: `test/adaptive_test_harness_test.dart`

**Interfaces:**
- Produces: `AdaptiveTestScenario` com `size`, `textScaleFactor`, `viewInsets` e `name`.
- Produces: `Future<void> pumpAdaptive(WidgetTester tester, Widget child, AdaptiveTestScenario scenario)`.
- Produces: `void expectNoLayoutExceptions(WidgetTester tester)`.

- [ ] **Step 1: Write the failing harness tests**

```dart
testWidgets('harness aplica janela e escala de texto', (tester) async {
  await pumpAdaptive(tester, const Text('Teste'), adaptiveLargeText);
  expect(tester.view.physicalSize, const Size(360, 800));
  final media = tester.widget<MediaQuery>(find.byType(MediaQuery).first);
  expect(media.data.textScaler.scale(10), 20);
});
```

Também testar `adaptiveSmallPhone` como 320×568/1,0×, `adaptiveLandscape` como 640×360/1,3× e restauração de `tester.view` via `addTearDown`.

- [ ] **Step 2: Run test to verify it fails**

Run: Flutter test snapshot with `test/adaptive_test_harness_test.dart --no-pub`.
Expected: FAIL because the helper and scenario constants do not exist.

- [ ] **Step 3: Implement the shared harness**

```dart
const adaptiveSmallPhone = AdaptiveTestScenario(
  name: '320x568 @ 1.0',
  size: Size(320, 568),
  textScaleFactor: 1,
);
const adaptiveLargeText = AdaptiveTestScenario(
  name: '360x800 @ 2.0',
  size: Size(360, 800),
  textScaleFactor: 2,
);
const adaptiveLandscape = AdaptiveTestScenario(
  name: '640x360 @ 1.3',
  size: Size(640, 360),
  textScaleFactor: 1.3,
);
```

`pumpAdaptive` deve configurar `physicalSize`, `devicePixelRatio = 1`, envolver o conteúdo em `MediaQuery.copyWith(textScaler: TextScaler.linear(...))` e registrar restauração. `expectNoLayoutExceptions` consome `tester.takeException()` e exige `null`.

- [ ] **Step 4: Run test to verify it passes**

Run: Flutter test snapshot with `test/adaptive_test_harness_test.dart --no-pub`.
Expected: PASS.

- [ ] **Step 5: Commit**

```text
test(ui): add adaptive scenario harness
```

### Task 2: Primitivas adaptativas reutilizáveis

**Files:**
- Create: `lib/core/widgets/responsive_content.dart`
- Create: `lib/core/widgets/adaptive_layout.dart`
- Create: `lib/core/widgets/adaptive_action_row.dart`
- Modify: `lib/core/widgets/responsive_form_content.dart`
- Create: `test/adaptive_layout_widgets_test.dart`
- Modify: `test/responsive_form_content_test.dart`

**Interfaces:**
- Consumes: cenários e helper da Task 1.
- Produces: `ResponsiveContent({required Widget child, double maxWidth = 900, EdgeInsetsGeometry padding, bool scrollable = false, ScrollController? controller})`.
- Produces: `AdaptiveLayout({required double breakpoint, required Widget compact, required Widget expanded})`.
- Produces: `AdaptiveActionRow({required List<Widget> children, double breakpoint = 520, double spacing = 12})`.
- Preserves: API pública existente de `ResponsiveFormContent`.

- [ ] **Step 1: Write failing widget tests**

Testar que `ResponsiveContent` limita largura e rola até uma chave final; `AdaptiveLayout` escolhe `compact` abaixo do breakpoint; `AdaptiveActionRow` usa coluna em 320 dp e linha em 640 dp; `ResponsiveFormContent` conserva 20 dp de inset em 360 dp.

```dart
expect(find.byKey(const Key('compact-layout')), findsOneWidget);
expect(find.byKey(const Key('expanded-layout')), findsNothing);
```

- [ ] **Step 2: Run tests to verify they fail**

Run: Flutter test snapshot with `test/adaptive_layout_widgets_test.dart test/responsive_form_content_test.dart --no-pub`.
Expected: FAIL because the three new widgets do not exist.

- [ ] **Step 3: Implement minimal adaptive widgets**

Usar `LayoutBuilder`, `Center`, `ConstrainedBox` e `ListView`/`SingleChildScrollView`; não consultar `MediaQuery.size` dentro dos breakpoints de conteúdo. Fazer `ResponsiveFormContent` compor `ResponsiveContent` sem alterar sua largura padrão de 440 dp.

- [ ] **Step 4: Run focused tests**

Run: Flutter test snapshot with `test/adaptive_layout_widgets_test.dart test/responsive_form_content_test.dart --no-pub`.
Expected: PASS with no layout exceptions in all three scenarios.

- [ ] **Step 5: Commit**

```text
feat(ui): add adaptive layout primitives
```

### Task 3: Configurações e autenticação

**Files:**
- Modify: `lib/features/user/views/settings_page.dart`
- Modify: `lib/features/auth/views/login_page.dart`
- Modify: `lib/features/auth/views/register_type_page.dart`
- Modify: `lib/features/auth/views/forgot_password_page.dart`
- Modify: `lib/features/auth/views/register_user_page.dart`
- Modify: `lib/features/gas_station/views/register_station_step_one_page.dart`
- Modify: `lib/features/gas_station/views/register_station_step_two_page.dart`
- Create: `test/settings_adaptability_test.dart`
- Create: `test/auth_adaptability_test.dart`

**Interfaces:**
- Consumes: `ResponsiveContent`, `AdaptiveLayout`, `AdaptiveActionRow` e o harness.
- Produces: `Key('settings-danger-zone')` para provar alcance por scroll.
- Produces: `Key('auth-primary-action')` nas ações principais dos formulários.

- [ ] **Step 1: Write failing tests for settings and auth**

Renderizar Configurações nos três cenários, arrastar até `settings-danger-zone` e exigir visibilidade. Para login e formulários, simular `viewInsets.bottom = 300`, focar o último campo, chamar `ensureVisible(auth-primary-action)` e exigir ausência de exceções.

```dart
await tester.dragUntilVisible(
  find.byKey(const Key('settings-danger-zone')),
  find.byType(Scrollable),
  const Offset(0, -200),
);
expect(find.byKey(const Key('settings-danger-zone')), findsOneWidget);
```

- [ ] **Step 2: Run tests to verify they fail**

Run: Flutter test snapshot with `test/settings_adaptability_test.dart test/auth_adaptability_test.dart --no-pub`.
Expected: settings cannot scroll and at least one auth composition reports overflow or inaccessible action.

- [ ] **Step 3: Migrate settings and auth layouts**

Trocar a `Column` raiz de Configurações por conteúdo rolável. Remover `Transform.translate` do login; ocultar ou compactar o hero quando teclado ou altura reduzida exigirem, sem deslocamento negativo. Usar `TextTheme` nos títulos afetados e deixar blocos de texto crescerem. Preservar autofill, validação, rotas e copy existentes.

- [ ] **Step 4: Run focused tests**

Run: Flutter test snapshot with `test/settings_adaptability_test.dart test/auth_adaptability_test.dart test/auth_visual_flow_test.dart --no-pub`.
Expected: PASS in small phone, large text, landscape and keyboard scenarios.

- [ ] **Step 5: Commit**

```text
fix(ui): make settings and auth scrollable
```

### Task 4: Descoberta e cards

**Files:**
- Modify: `lib/features/user/views/station_list_page.dart`
- Modify: `lib/features/user/widgets/discovery_station_card.dart`
- Modify: `lib/features/user/widgets/fuel_choice_selector.dart`
- Modify: `lib/features/user/widgets/fuel_discovery_tip.dart`
- Modify: `lib/core/widgets/fuel_price_grid.dart`
- Modify: `lib/core/widgets/welcome_summary_header.dart`
- Create: `test/discovery_adaptability_test.dart`

**Interfaces:**
- Consumes: harness e widgets adaptativos.
- Produces: cards cuja ordem semântica permanece nome/status → preço → confiança → ação.
- Preserves: seleção de combustível, busca, filtros, ranking e abertura do perfil.

- [ ] **Step 1: Write failing discovery tests**

Renderizar seletor, dica e `DiscoveryStationCard` nos três cenários com nomes longos, preço ausente e texto 2,0×. Exigir alvos de combustível ≥48 dp, múltiplas linhas sem overflow e primeiro card alcançável após o cabeçalho.

- [ ] **Step 2: Run test to verify it fails**

Run: Flutter test snapshot with `test/discovery_adaptability_test.dart --no-pub`.
Expected: FAIL in at least one rigid `Row` or fixed-height selector.

- [ ] **Step 3: Implement content-driven reflow**

Substituir altura fixa do seletor por constraints mínimas; permitir labels multiline ou composição compacta; reorganizar cabeçalhos e badges com `Wrap`/`Flexible`; fazer a grade de preços mudar para coluna/`Wrap` somente quando a largura útil não comportar três células legíveis. Não ocultar preço, status ou frescor.

- [ ] **Step 4: Run focused tests**

Run: Flutter test snapshot with `test/discovery_adaptability_test.dart test/station_discovery_widgets_test.dart test/fuel_discovery_tip_test.dart --no-pub`.
Expected: PASS with existing interaction contracts preserved.

- [ ] **Step 5: Commit**

```text
fix(discovery): adapt cards and controls
```

### Task 5: Perfis, diálogos e bottom sheets

**Files:**
- Modify: `lib/features/user/views/profile_page.dart`
- Modify: `lib/features/gas_station/views/station_profile_page.dart`
- Modify: `lib/features/user/views/public_station_profile_page.dart`
- Create: `test/profile_adaptability_test.dart`

**Interfaces:**
- Consumes: harness, `ResponsiveContent` e `AdaptiveActionRow`.
- Produces: perfis e superfícies modais roláveis com ações sempre alcançáveis.
- Preserves: edição de campos, avaliações, denúncia e dados públicos.

- [ ] **Step 1: Write failing profile tests**

Renderizar cabeçalhos e seções testáveis com nomes/endereço longos nos três cenários. Abrir diálogos e sheets existentes, aplicar texto 2,0× e exigir acesso ao último botão por scroll sem exceções.

- [ ] **Step 2: Run test to verify it fails**

Run: Flutter test snapshot with `test/profile_adaptability_test.dart --no-pub`.
Expected: FAIL where rigid rows or modal columns cannot fit.

- [ ] **Step 3: Migrate profile surfaces**

Aplicar `Flexible`/`Wrap` aos cabeçalhos; usar `AdaptiveActionRow` nas ações; limitar altura de sheets pelo viewport e dar scroll apenas ao conteúdo; manter botões fora de regiões cortadas pelo teclado. Substituir tamanhos locais pelos papéis de `TextTheme` apenas nas áreas tocadas.

- [ ] **Step 4: Run focused tests**

Run: Flutter test snapshot with `test/profile_adaptability_test.dart test/station_visual_components_test.dart --no-pub`.
Expected: PASS in all scenarios.

- [ ] **Step 5: Commit**

```text
fix(profile): support compact large-text layouts
```

### Task 6: Dashboard administrativo

**Files:**
- Modify: `lib/features/gas_station/views/station_dashboard_page.dart`
- Create: `test/station_dashboard_adaptability_test.dart`
- Modify: `test/station_dashboard_navigation_test.dart`

**Interfaces:**
- Consumes: harness, `AdaptiveLayout` e `AdaptiveActionRow`.
- Preserves: quatro destinos, estados sujos e persistência parcial.
- Produces: header, navegação, horários e avaliações sem overflow nos três cenários.

- [ ] **Step 1: Write failing dashboard tests**

Extrair ou expor widgets puros necessários para testar sem Firebase. Renderizar header, barra/rail, cartões de preço, linha de horário e item de avaliação. Exigir barra inferior abaixo de 840 dp, rail acima de 840 dp, reflow do horário em paisagem/2,0× e alvos ≥48 dp.

- [ ] **Step 2: Run test to verify it fails**

Run: Flutter test snapshot with `test/station_dashboard_adaptability_test.dart --no-pub`.
Expected: FAIL in header, navegação ou controles horários rígidos.

- [ ] **Step 3: Adapt dashboard components**

Permitir que status e ações secundárias do header ocupem outra linha; usar layout por constraints para navegação; manter labels acessíveis na barra inferior; reorganizar dia/interruptor/horários em coluna quando necessário; garantir scroll até CTAs e avaliações.

- [ ] **Step 4: Run focused tests**

Run: Flutter test snapshot with `test/station_dashboard_adaptability_test.dart test/station_dashboard_navigation_test.dart test/station_dashboard_draft_test.dart --no-pub`.
Expected: PASS without changing persistence or discard behavior.

- [ ] **Step 5: Commit**

```text
fix(dashboard): adapt operator layouts
```

### Task 7: Auditoria final e documentação

**Files:**
- Modify: `DESIGN.md`
- Modify: `docs/DESIGN-E-INTERFACE.md`
- Modify: tests das Tasks 1–6 somente quando a evidência final revelar uma lacuna real.

**Interfaces:**
- Consumes: todas as superfícies migradas.
- Produces: documentação do contrato adaptativo e evidência final automatizada.

- [ ] **Step 1: Run all adaptive tests together**

Run: Flutter test snapshot with every `*_adaptability_test.dart`, `adaptive_layout_widgets_test.dart` and `adaptive_test_harness_test.dart` using `--no-pub`.
Expected: all PASS with no `RenderFlex overflow` or uncaught layout exception.

- [ ] **Step 2: Run the design detector**

Run: `node C:/Users/Marcos/.agents/skills/impeccable/scripts/detect.mjs --no-advisory lib/core/widgets lib/features`.
Expected: zero blocking findings introduced by this plan.

- [ ] **Step 3: Update design documentation**

Registrar os três cenários mínimos, uso de `ResponsiveContent`, breakpoints orientados pelo conteúdo, escala máxima validada de 2,0× e pendência de inspeção Android quando não houver dispositivo.

- [ ] **Step 4: Run complete verification**

Run Dart analyze on `lib test`, full Flutter tests with `--no-pub`, and `git diff --check`.
Expected: analyzer clean, all tests pass and no whitespace errors.

- [ ] **Step 5: Record Android validation state**

Run `C:/Users/Marcos/AppData/Local/Android/sdk/platform-tools/adb.exe devices`. If a device is available, capture portrait, landscape and font scale 1.3×. If none is available, do not claim visual approval; record the pending verification in the handoff.

- [ ] **Step 6: Commit**

```text
docs(ui): record adaptive layout contract
```
