# Meu combustível Implementation Plan

**Status:** concluído em 18/08/2026. Análise, 28 testes e APK debug aprovados; captura Android não concluída porque o emulador ficou offline durante a instalação.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar a descoberta por combustível com tema neutro/cobalto, melhor valor verde, filtro de postos abertos e cards simplificados.

**Architecture:** Extrair seleção, ordenação e cálculo de melhor valor para uma unidade pura e testável. A página mantém busca, carregamento, refresh e navegação existentes, mas passa a renderizar um único preço por card. Tokens visuais permanecem centralizados em `AppTheme`.

**Tech Stack:** Flutter, Material 3, Dart, `flutter_test`, Google Fonts.

## Global Constraints

- Fundo `#F7F7F7`, superfície `#FFFFFF`, grafite `#171717`, cinza `#666666`, contorno `#D4D4D4`.
- Azul-cobalto `#315EFB` somente para marca, navegação, seleção e foco.
- Verde-esmeralda `#00A86B` somente para melhor valor comprovado.
- Verde `#237A47` para aberto/sucesso; erro `#C9362B`.
- Um preço dominante por card fechado; sem distância ou economia inventada.
- Alvos mínimos de 48×48dp, estados com texto/ícone e redução de movimento respeitada.
- `firestore.rules` permanece inalterado porque não há mudança de dados ou autorização.

---

### Task 1: Modelo de seleção e ranking

**Files:**
- Create: `lib/features/user/models/station_discovery_filter.dart`
- Create: `test/station_discovery_filter_test.dart`

**Interfaces:**
- Produces: `enum FuelChoice { gasoline, ethanol, diesel }`.
- Produces: `FuelChoice.fuelKey`, `FuelChoice.label`, `FuelChoice.priceLabel`.
- Produces: `filterAndSortStations(List<PublicGasStation>, FuelChoice, {required bool onlyOpen, required DateTime moment, String query = ''})`.
- Produces: `bestPricedStationId(List<PublicGasStation>, FuelChoice)`.

- [ ] **Step 1: Write failing tests** covering selected-fuel ordering, missing prices at end, open-only filtering, text search and best valid price.
- [ ] **Step 2: Run** `flutter test test/station_discovery_filter_test.dart` and confirm failure because API does not exist.
- [ ] **Step 3: Implement minimal pure model** with deterministic filtering and sorting.
- [ ] **Step 4: Run** `flutter test test/station_discovery_filter_test.dart` and confirm pass.

### Task 2: Theme tokens and price contract

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/core/widgets/price_display.dart`
- Modify: `test/design_system_test.dart`
- Modify: `test/station_visual_components_test.dart`

**Interfaces:**
- Produces: `AppTheme.savings`, `AppTheme.savingsSurface`.
- Preserves: `AppTheme.amber` and compatibility aliases only where old screens still compile; new discovery does not use them.
- Extends: `PriceDisplay(..., bool bestValue = false)`.

- [ ] **Step 1: Change token and widget tests first** to require approved colors and green best-value semantics.
- [ ] **Step 2: Run focused tests** and confirm expected token/constructor failures.
- [ ] **Step 3: Implement palette, Manrope text theme and `bestValue` rendering** without oversized price.
- [ ] **Step 4: Run focused tests** and confirm pass.

### Task 3: Discovery controls and station card

**Files:**
- Create: `lib/features/user/widgets/fuel_choice_selector.dart`
- Create: `lib/features/user/widgets/discovery_station_card.dart`
- Create: `test/station_discovery_widgets_test.dart`

**Interfaces:**
- `FuelChoiceSelector(choice: FuelChoice, onChanged: ValueChanged<FuelChoice>)`.
- `DiscoveryStationCard(station: PublicGasStation, fuel: FuelChoice, isBestValue: bool, onOpen: VoidCallback, onShowAllPrices: VoidCallback)`.

- [ ] **Step 1: Write failing widget tests** for selection semantics, 48dp targets, one displayed price, blue lateral signature, best-value label and missing-price copy.
- [ ] **Step 2: Run** `flutter test test/station_discovery_widgets_test.dart` and confirm failure because widgets do not exist.
- [ ] **Step 3: Implement Material 3 widgets** using theme tokens, 4dp approved signature and accessible labels.
- [ ] **Step 4: Run focused test** and confirm pass.

### Task 4: Integrate discovery page

**Files:**
- Modify: `lib/features/user/views/station_list_page.dart`
- Create: `test/station_list_page_contract_test.dart`

**Interfaces:**
- Consumes: Task 1 filter/ranking functions.
- Consumes: Task 3 selector and card.
- Preserves: refresh, search, loading, retry, empty state and profile navigation.

- [ ] **Step 1: Write failing source/widget contract tests** requiring “Gasolina”, “Etanol”, “Diesel”, “Só abertos”, one-price cards and removal of old decision highlights.
- [ ] **Step 2: Run focused test** and confirm expected failure.
- [ ] **Step 3: Replace sort chips/highlights with selector, switch and simplified cards**; show bottom sheet for all prices.
- [ ] **Step 4: Run focused test** and confirm pass.

### Task 5: Documentation and verification

**Files:**
- Modify: `DESIGN.md`
- Modify: `STRUCTURE.md`
- Modify: `docs/DESIGN-E-INTERFACE.md`
- Modify: `docs/superpowers/specs/2026-08-18-redesign-meu-combustivel-design.md`

- [ ] **Step 1: Mark implementation status and actual file contracts**; record `firestore.rules` review with no security-rule edit.
- [ ] **Step 2: Run** `dart format lib test`.
- [ ] **Step 3: Run** `flutter analyze --no-pub`.
- [ ] **Step 4: Run** `flutter test`.
- [ ] **Step 5: Run** `flutter build apk --debug --no-pub`.
- [ ] **Step 6: Report Android visual inspection limitation** if no emulator/device is available.
