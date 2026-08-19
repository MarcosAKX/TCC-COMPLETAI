# Dashboard do operador Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganizar o dashboard do posto em quatro tarefas independentes, com preços como entrada principal e persistência explícita por seção.

**Architecture:** O dashboard mantém uma única carga inicial, mas separa estado inicial, detecção de mudanças, validação e salvamento para preços, informações e horários. `GasStationService` expõe atualizações parciais que sincronizam o documento privado e o perfil público sem reenviar campos de outras seções.

**Tech Stack:** Flutter, Dart, Material 3, Firebase Auth, Cloud Firestore, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-08-19-dashboard-operador-design.md`

## Global Constraints

- O dashboard abre em **Preços**.
- Há exatamente um CTA de persistência por área editável.
- Cada CTA grava somente os campos da própria área.
- Não existe salvamento automático.
- Sair de uma área com alterações pendentes exige confirmação.
- Falhas mantêm as alterações locais.
- Alvos interativos têm pelo menos 48 dp e todas as telas permanecem roláveis.

---

### Task 1: Operações administrativas parciais

**Files:**
- Modify: `lib/features/gas_station/services/gas_station_service.dart`
- Create: `test/gas_station_administrative_update_test.dart`

**Interfaces:**
- Produces: `Future<void> updateFuelPrices(Map<String, double> fuelPrices)`
- Produces: `Future<void> updateStationInformation({required Set<String> tags, required Set<String> services})`
- Produces: `Future<void> updateOpeningHours(Map<String, Map<String, dynamic>> openingHours)`

- [ ] **Step 1: Write failing contract tests**

Create source-contract tests that read `gas_station_service.dart` and assert the three method signatures exist, `updateFuelPrices` validates values, and each private update map contains only its owned fields plus `updatedAt`.

```dart
test('serviço expõe atualizações administrativas parciais', () {
  final source = File('lib/features/gas_station/services/gas_station_service.dart')
      .readAsStringSync();
  expect(source, contains('Future<void> updateFuelPrices('));
  expect(source, contains('Future<void> updateStationInformation('));
  expect(source, contains('Future<void> updateOpeningHours('));
});
```

- [ ] **Step 2: Verify the test fails**

Run: Flutter test snapshot with `test/gas_station_administrative_update_test.dart --no-pub`.
Expected: FAIL because the partial methods do not exist.

- [ ] **Step 3: Implement partial Firestore updates**

Add the three public methods and one private synchronization helper. Each method must read the current private station, merge only its owned fields into the public projection, batch-update the private document, and merge the public document. Remove `updateAdministrativeData` after all call sites migrate.

```dart
Future<void> updateFuelPrices(Map<String, double> fuelPrices)
Future<void> updateStationInformation({
  required Set<String> tags,
  required Set<String> services,
})
Future<void> updateOpeningHours(
  Map<String, Map<String, dynamic>> openingHours,
)
```

- [ ] **Step 4: Verify the focused test passes**

Run: Flutter test snapshot with `test/gas_station_administrative_update_test.dart --no-pub`.
Expected: PASS.

- [ ] **Step 5: Commit**

```text
refactor(data): split station updates by section
```

### Task 2: Testable section state and navigation protection

**Files:**
- Create: `lib/features/gas_station/models/station_dashboard_draft.dart`
- Create: `test/station_dashboard_draft_test.dart`

**Interfaces:**
- Produces: immutable snapshots for prices, tags, services and opening hours.
- Produces: `bool get hasPriceChanges`, `bool get hasInformationChanges`, `bool get hasOpeningHourChanges`.
- Produces: restore and mark-saved methods scoped per section.

- [ ] **Step 1: Write failing unit tests**

Cover unchanged initial state, one changed price, set-order independence, nested hours comparison, section restore, and marking only one section as saved.

```dart
expect(draft.hasPriceChanges, isFalse);
draft.setPrice('gasolineRegular', '5,499');
expect(draft.hasPriceChanges, isTrue);
expect(draft.hasInformationChanges, isFalse);
```

- [ ] **Step 2: Verify the test fails**

Run: Flutter test snapshot with `test/station_dashboard_draft_test.dart --no-pub`.
Expected: FAIL because `StationDashboardDraft` is undefined.

- [ ] **Step 3: Implement the draft model**

Store defensive copies of the loaded and edited values. Normalize decimal separators for price comparison, compare sets without order, deep-copy the day maps, and expose scoped restore/mark-saved methods.

- [ ] **Step 4: Verify the focused test passes**

Run: Flutter test snapshot with `test/station_dashboard_draft_test.dart --no-pub`.
Expected: PASS.

- [ ] **Step 5: Commit**

```text
feat(dashboard): track changes by section
```

### Task 3: Four-destination dashboard shell

**Files:**
- Modify: `lib/features/gas_station/views/station_dashboard_page.dart`
- Create: `test/station_dashboard_navigation_test.dart`

**Interfaces:**
- Consumes: section dirty-state API from Task 2.
- Produces: destinations `Preços`, `Informações`, `Horários`, `Avaliações`.
- Produces: `Future<bool> _confirmDiscardCurrentSection()` used before section changes and route exit.

- [ ] **Step 1: Write failing widget/source tests**

Assert the four labels exist in the source, `Preços` is index zero, the old labels `Administração`, `Salvar alterações` and duplicate `Publicar novos preços` are absent, and the discard dialog contains `Continuar editando` and `Descartar alterações`.

- [ ] **Step 2: Verify the test fails**

Run: Flutter test snapshot with `test/station_dashboard_navigation_test.dart --no-pub`.
Expected: FAIL while the two-tab dashboard remains.

- [ ] **Step 3: Replace the two-tab shell**

Use an indexed destination state. Render a bottom `NavigationBar` on compact widths and `NavigationRail` on wide widths. Intercept destination changes and `PopScope` exits; if the current editable section is dirty, show the approved discard dialog and restore only that section after confirmation.

- [ ] **Step 4: Verify the focused test passes**

Run: Flutter test snapshot with `test/station_dashboard_navigation_test.dart --no-pub`.
Expected: PASS.

- [ ] **Step 5: Commit**

```text
feat(dashboard): add task-based navigation
```

### Task 4: Independent price publishing

**Files:**
- Modify: `lib/features/gas_station/views/station_dashboard_page.dart`
- Create: `test/station_dashboard_prices_test.dart`

**Interfaces:**
- Consumes: `GasStationService.updateFuelPrices` and draft price state.
- Produces: `_savePrices()` and one dynamic CTA label.

- [ ] **Step 1: Write failing tests**

Assert one price CTA, singular/plural labels, disabled unchanged state, field-specific invalid-price copy, success copy `Preços publicados.` and no references to tags, services or opening hours inside `_savePrices`.

- [ ] **Step 2: Verify the test fails**

Run: Flutter test snapshot with `test/station_dashboard_prices_test.dart --no-pub`.
Expected: FAIL because price publishing still calls the aggregate save.

- [ ] **Step 3: Build the focused Prices page**

Move station summary below the task header, retain the responsive price fields, show the pending-change count and call only `updateFuelPrices`. On success, mark only prices as saved and refresh the update timestamp; on failure, leave controllers unchanged.

- [ ] **Step 4: Verify the focused test passes**

Run: Flutter test snapshot with `test/station_dashboard_prices_test.dart --no-pub`.
Expected: PASS.

- [ ] **Step 5: Commit**

```text
feat(dashboard): focus price publishing flow
```

### Task 5: Independent information and hours saving

**Files:**
- Modify: `lib/features/gas_station/views/station_dashboard_page.dart`
- Create: `test/station_dashboard_sections_test.dart`

**Interfaces:**
- Consumes: `updateStationInformation`, `updateOpeningHours`, and draft section state.
- Produces: `_saveInformation()` and `_saveOpeningHours()`.

- [ ] **Step 1: Write failing tests**

Assert `Informações` contains station summary, tags, services and exactly one `Salvar informações` CTA; assert `Horários` contains the schedule and exactly one `Salvar horários` CTA; assert section-specific success/error copy and calls.

- [ ] **Step 2: Verify the test fails**

Run: Flutter test snapshot with `test/station_dashboard_sections_test.dart --no-pub`.
Expected: FAIL because both sections are still part of the aggregate form.

- [ ] **Step 3: Implement both pages and saves**

Keep all content scrollable. Disable each CTA unless its section is dirty. Call only the matching service method; mark only that section saved after success and preserve edits after error.

- [ ] **Step 4: Verify the focused test passes**

Run: Flutter test snapshot with `test/station_dashboard_sections_test.dart --no-pub`.
Expected: PASS.

- [ ] **Step 5: Commit**

```text
feat(dashboard): separate profile maintenance
```

### Task 6: Regression, accessibility and documentation

**Files:**
- Modify: `DESIGN.md`
- Modify: tests from Tasks 1–5 as required by verified behavior.

**Interfaces:**
- Consumes: completed dashboard and service APIs.
- Produces: documented four-area operator flow and full regression evidence.

- [ ] **Step 1: Add accessibility assertions**

Assert destination and CTA hit targets are at least 48 dp in a widget-test harness that does not require Firebase initialization. Verify the compact layout under enlarged text remains scrollable without overflow.

- [ ] **Step 2: Run focused tests**

Run all `station_dashboard_*_test.dart` and `gas_station_administrative_update_test.dart` files.
Expected: all PASS.

- [ ] **Step 3: Update design documentation**

Document Preços as the entry task, the three explicit persistence actions, four navigation destinations and discard confirmation in `DESIGN.md`.

- [ ] **Step 4: Run complete verification**

Run Dart analyze on `lib test`, the full Flutter test suite with `--no-pub`, and `git diff --check`.
Expected: no analyzer findings, all tests pass, no whitespace errors.

- [ ] **Step 5: Commit**

```text
docs(dashboard): record operator workflow
```
