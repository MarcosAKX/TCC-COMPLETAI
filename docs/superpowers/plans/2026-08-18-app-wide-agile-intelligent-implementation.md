# App-wide “Ágil e inteligente” Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplicar a direção visual aprovada a todas as 12 telas existentes, consolidando tokens, componentes, navegação e documentação sem alterar o contrato Firestore.

**Architecture:** A migração começa no tema e em componentes pequenos, depois avança pelos fluxos de descoberta, perfis, autenticação e administração. Views consomem componentes semânticos; nenhuma view deve criar uma escala tipográfica ou paleta paralela.

**Tech Stack:** Flutter, Material 3, Dart 3.12, `google_fonts`, `flutter_test`, Firebase existente.

**Spec:** `docs/superpowers/specs/2026-08-18-app-wide-agile-intelligent-design.md`

## Global Constraints

- Android é a plataforma prioritária.
- Manrope é a única família tipográfica.
- `#315EFB` representa marca, foco e seleção; `#3559C7` representa preço comum; `#079B68` representa melhor valor.
- Nenhum preço, distância, logo, contador ou métrica fictícia.
- Logo usa fallback visual; upload e novo campo Firestore ficam fora do escopo.
- Alvo de toque mínimo 48×48dp; contraste WCAG AA; estado nunca depende apenas de cor.
- `firestore.rules` só muda se o contrato de dados/autorização mudar; isso não está previsto.
- O diretório atual não é reconhecido como repositório Git; checkpoints usam testes e registro de arquivos em vez de commits.

---

### Task 1: Consolidar tema, tipografia e tokens

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/core/widgets/brand_header.dart`
- Modify: `lib/core/widgets/decision_highlight_card.dart`
- Modify: `lib/core/widgets/price_display.dart`
- Test: `test/design_system_test.dart`

**Interfaces:**
- Produces: `AppTheme.surface`, `surfaceSubtle`, `textPrimary`, `textSecondary`, `primarySurface`, `price`, `priceSurface`, `rating`.
- Produces: `AppTheme.priceStyle({required double fontSize, required FontWeight fontWeight, required Color color})` usando Manrope e algarismos tabulares.

- [ ] **Step 1: Escrever testes de tokens e preço comum**

Adicionar asserts exatos em `test/design_system_test.dart`:

```dart
expect(AppTheme.background, const Color(0xFFF6F7F9));
expect(AppTheme.primary, const Color(0xFF315EFB));
expect(AppTheme.price, const Color(0xFF3559C7));
expect(AppTheme.savings, const Color(0xFF079B68));
expect(AppTheme.rating, const Color(0xFFD88710));
```

Renderizar `PriceDisplay(label: 'Etanol', price: 3.89)` e verificar que o `RichText` usa `AppTheme.price`.

- [ ] **Step 2: Confirmar falha inicial**

Run: `flutter test --no-pub test/design_system_test.dart`

Expected: FAIL porque os novos tokens não existem e o preço comum ainda usa `textLight`.

- [ ] **Step 3: Implementar o sistema aprovado**

Em `AppTheme`, substituir aliases ambíguos por tokens explícitos. Construir todo `TextTheme` com `GoogleFonts.manropeTextTheme`. Alterar `priceStyle` para `GoogleFonts.manrope` e manter `FontFeature.tabularFigures()`.

Em `PriceDisplay`, usar:

```dart
final priceColor = price == null
    ? AppTheme.textSecondary
    : bestValue
        ? AppTheme.savings
        : AppTheme.price;
```

Migrar estrelas para `AppTheme.rating`; remover usos de `AppTheme.amber` após migrar consumidores.

- [ ] **Step 4: Validar a fundação**

Run: `dart format lib/core/theme lib/core/widgets test/design_system_test.dart`

Run: `flutter test --no-pub test/design_system_test.dart`

Expected: PASS.

---

### Task 2: Criar avatar, logo, grid de preços e cards compartilhados

**Files:**
- Create: `lib/core/widgets/app_user_avatar.dart`
- Create: `lib/core/widgets/station_logo.dart`
- Create: `lib/core/widgets/fuel_price_grid.dart`
- Create: `lib/core/widgets/section_card.dart`
- Create: `lib/core/widgets/settings_tile.dart`
- Test: `test/agile_intelligent_components_test.dart`

**Interfaces:**
- Produces: `AppUserAvatar({String? imageUrl, required String displayName, required VoidCallback onTap})`.
- Produces: `StationLogo({String? imageUrl, required String stationName, double size = 48})`.
- Produces: `FuelPriceGrid({required Map<String,double> prices, FuelChoice? selectedFuel, Set<String> bestValueKeys = const {}})`.
- Produces: `SectionCard({required Widget child, EdgeInsetsGeometry padding})`.
- Produces: `SettingsTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap, bool destructive = false})`.

- [ ] **Step 1: Escrever widget tests dos contratos**

Cobrir:

```dart
expect(find.bySemanticsLabel('Abrir meu perfil'), findsOneWidget);
expect(find.text('PA'), findsOneWidget); // fallback de Posto Avenida
expect(find.text('R\$ 5,69'), findsOneWidget);
expect(find.text('R\$ 3,89'), findsOneWidget);
expect(find.text('R\$ 5,99'), findsOneWidget);
expect(find.text('Melhor valor'), findsOneWidget);
```

Também verificar `Não informado`, callback do avatar e fallback com nome vazio.

- [ ] **Step 2: Confirmar falha inicial**

Run: `flutter test --no-pub test/agile_intelligent_components_test.dart`

Expected: FAIL por imports inexistentes.

- [ ] **Step 3: Implementar componentes sem dados inventados**

`StationLogo` não faz leitura de rede quando `imageUrl` for nulo/vazio. Iniciais são derivadas de até duas palavras; nome vazio usa `Icons.local_gas_station_outlined`.

`FuelPriceGrid` usa as chaves existentes:

```dart
const fuelRows = <(String, String)>[
  ('gasolineRegular', 'Gasolina'),
  ('ethanol', 'Etanol'),
  ('dieselS10', 'Diesel S10'),
];
```

Cada célula mantém valor azul, seleção por superfície/contorno e melhor valor por verde + texto.

- [ ] **Step 4: Formatar e testar**

Run: `dart format lib/core/widgets test/agile_intelligent_components_test.dart`

Run: `flutter test --no-pub test/agile_intelligent_components_test.dart`

Expected: PASS.

---

### Task 3: Migrar descoberta e navegação para perfil

**Files:**
- Modify: `lib/features/user/widgets/discovery_station_card.dart`
- Modify: `lib/features/user/widgets/fuel_choice_selector.dart`
- Modify: `lib/features/user/views/station_list_page.dart`
- Modify: `lib/app/app_routes.dart`
- Modify: `test/station_discovery_widgets_test.dart`
- Modify: `test/station_visual_components_test.dart`

**Interfaces:**
- Consumes: `AppUserAvatar`, `StationLogo`, `FuelPriceGrid`.
- Preserves: `filterAndSortStations`, `bestPricedStationId`, `FuelChoice`.
- Produces: avatar → `AppRoutes.profile`; card → `PublicStationProfilePage(stationId: ...)`.

- [ ] **Step 1: Atualizar testes da lista aprovada**

Testar um card com três preços e um melhor valor. Exigir:

```dart
expect(find.text('Gasolina'), findsOneWidget);
expect(find.text('Etanol'), findsOneWidget);
expect(find.text('Diesel S10'), findsOneWidget);
expect(find.byKey(const Key('station-card-accent')), findsOneWidget);
```

No card não recomendado, exigir ausência da faixa azul. Testar tap no card e no avatar separadamente.

- [ ] **Step 2: Confirmar falha de contrato**

Run: `flutter test --no-pub test/station_discovery_widgets_test.dart test/station_visual_components_test.dart`

Expected: FAIL porque o card atual mostra um preço e aplica faixa a todos.

- [ ] **Step 3: Implementar lista e cards**

Remover `onShowAllPrices`. Tornar o `Material` inteiro acionável via `InkWell(onTap: onOpen)`. Inserir `StationLogo` e `FuelPriceGrid`. Renderizar faixa apenas quando `isBestValue == true`.

No cabeçalho de `StationListPage`, substituir o ícone genérico por:

```dart
AppUserAvatar(
  displayName: currentUserDisplayName,
  onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
)
```

Se o nome não estiver carregado, usar `Usuário` como rótulo textual de fallback, sem inventar identidade.

- [ ] **Step 4: Verificar comportamento da descoberta**

Run: `dart format lib/features/user lib/app/app_routes.dart test`

Run: `flutter test --no-pub test/station_discovery_filter_test.dart test/station_discovery_widgets_test.dart test/station_visual_components_test.dart`

Expected: PASS.

---

### Task 4: Migrar perfil público do posto

**Files:**
- Modify: `lib/features/user/views/public_station_profile_page.dart`
- Create: `test/public_station_profile_visual_test.dart`

**Interfaces:**
- Consumes: `StationLogo`, `FuelPriceGrid`, `SectionCard`, `StatusPill`.
- Preserves: favoritos, avaliações, denúncia, serviços e horários existentes.

- [ ] **Step 1: Criar teste da hierarquia do perfil**

Extrair ou tornar testável a superfície carregada com um `PublicGasStation`. Verificar ordem por posição vertical:

```dart
expect(tester.getTopLeft(find.byType(StationLogo)).dy,
    lessThan(tester.getTopLeft(find.text('Todos os preços')).dy));
expect(find.text('Gasolina'), findsOneWidget);
expect(find.text('Etanol'), findsOneWidget);
expect(find.text('Diesel S10'), findsOneWidget);
```

Verificar que logo ausente não dispara erro e que favorito/denúncia continuam presentes.

- [ ] **Step 2: Confirmar falha inicial**

Run: `flutter test --no-pub test/public_station_profile_visual_test.dart`

Expected: FAIL por ausência de `StationLogo` e `FuelPriceGrid`.

- [ ] **Step 3: Reorganizar a superfície sem alterar serviços**

Aplicar ordem: identidade → status/endereço → todos os preços → serviços/horários → avaliações → denúncia. Substituir cards locais equivalentes por `SectionCard`; usar `AppTheme.rating` nas estrelas.

- [ ] **Step 4: Testar perfil público**

Run: `dart format lib/features/user/views/public_station_profile_page.dart test/public_station_profile_visual_test.dart`

Run: `flutter test --no-pub test/public_station_profile_visual_test.dart`

Expected: PASS.

---

### Task 5: Migrar perfil do usuário e configurações

**Files:**
- Create: `lib/core/widgets/profile_header.dart`
- Modify: `lib/features/user/views/profile_page.dart`
- Modify: `lib/features/user/views/settings_page.dart`
- Create: `test/user_profile_visual_test.dart`

**Interfaces:**
- Produces: `ProfileHeader({required String title, required String subtitle, String? imageUrl, required VoidCallback onEdit, Widget? identity})`.
- Consumes: `SettingsTile`, `SectionCard`, `AppUserAvatar`.
- Preserves: edição, mudança de senha, reautenticação e exclusão atuais.

- [ ] **Step 1: Testar perfil sem métricas fictícias**

Verificar nome/e-mail, “Editar perfil”, “Configurações” e ausência de textos de contadores não derivados do backend. Em configurações, iniciar exclusão e exigir `CircularProgressIndicator` enquanto a operação estiver ativa.

- [ ] **Step 2: Confirmar falhas iniciais**

Run: `flutter test --no-pub test/user_profile_visual_test.dart`

Expected: FAIL por `ProfileHeader` inexistente e progresso de exclusão ausente.

- [ ] **Step 3: Implementar perfil e configurações**

Migrar cabeçalho para `ProfileHeader`. Usar `SettingsTile` somente para rotas/ações reais. Manter favoritos e avaliações fora do menu se não houver ação navegável. Adicionar estado `_isDeleting` para desabilitar ações e exibir progresso durante exclusão.

- [ ] **Step 4: Testar fluxos de conta**

Run: `dart format lib/core/widgets/profile_header.dart lib/features/user/views/profile_page.dart lib/features/user/views/settings_page.dart test/user_profile_visual_test.dart`

Run: `flutter test --no-pub test/user_profile_visual_test.dart test/auth_visual_flow_test.dart`

Expected: PASS.

---

### Task 6: Migrar autenticação e cadastros

**Files:**
- Modify: `lib/features/auth/views/login_page.dart`
- Modify: `lib/features/auth/views/forgot_password_page.dart`
- Modify: `lib/features/auth/views/register_type_page.dart`
- Modify: `lib/features/auth/views/register_user_page.dart`
- Modify: `lib/features/gas_station/views/register_station_step_one_page.dart`
- Modify: `lib/features/gas_station/views/register_station_step_two_page.dart`
- Modify: `test/auth_visual_flow_test.dart`

**Interfaces:**
- Consumes: tema global, `BrandHeader`, `StepProgressHeader`, `CustomTextField`, `CustomButton`, `SectionCard`.
- Preserves: viewmodels, validação, payload e navegação existentes.

- [ ] **Step 1: Ampliar testes de consistência**

Exigir `StepProgressHeader` nas duas etapas de cadastro do posto, um único botão elevado dominante por formulário e ausência de `AppTheme.amber`/animação infinita nas superfícies de auth.

- [ ] **Step 2: Confirmar falhas atuais**

Run: `flutter test --no-pub test/auth_visual_flow_test.dart`

Expected: FAIL na etapa sem progresso consistente e nos elementos ainda ligados ao alias âmbar.

- [ ] **Step 3: Aplicar componentes e escala global**

Remover `fontSize` locais que duplicam papéis do tema. Migrar ícones decorativos para `primary`/`primarySurface`. Manter labels, validação inline, autofill e ações de teclado. Na etapa 2, incluir resumo textual dos dados recebidos da etapa 1 sem alterar seu modelo.

- [ ] **Step 4: Verificar auth e validações**

Run: `dart format lib/features/auth/views lib/features/gas_station/views/register_station_step_one_page.dart lib/features/gas_station/views/register_station_step_two_page.dart test/auth_visual_flow_test.dart`

Run: `flutter test --no-pub test/auth_visual_flow_test.dart test/validation_test.dart`

Expected: PASS.

---

### Task 7: Migrar perfil e dashboard do posto

**Files:**
- Modify: `lib/features/gas_station/views/station_profile_page.dart`
- Modify: `lib/features/gas_station/views/station_dashboard_page.dart`
- Create: `test/station_admin_visual_test.dart`

**Interfaces:**
- Consumes: `ProfileHeader`, `StationLogo`, `SectionCard`, `FuelPriceGrid`, tokens de preço e avaliação.
- Preserves: streams, salvamento, horários, tags, serviços, avaliações e dialogs existentes.

- [ ] **Step 1: Criar testes administrativos focados**

Verificar que preços aparecem antes de tags/serviços, avaliações usam `AppTheme.rating`, CTA mantém “Salvar alterações”/“Publicar preços” conforme ação existente e sucesso usa “Preços atualizados para os clientes”.

- [ ] **Step 2: Confirmar falhas atuais**

Run: `flutter test --no-pub test/station_admin_visual_test.dart`

Expected: FAIL por hierarquia e aliases antigos.

- [ ] **Step 3: Migrar sem reescrever a camada de dados**

Aplicar `ProfileHeader` e `StationLogo` ao perfil administrativo. No dashboard, migrar cards de seção e preço; manter detecção de alterações existente; tornar tags, serviços e horários seções expansíveis com resumo usando `ExpansionTile` Material. Não adicionar autosave.

- [ ] **Step 4: Verificar telas administrativas**

Run: `dart format lib/features/gas_station/views/station_profile_page.dart lib/features/gas_station/views/station_dashboard_page.dart test/station_admin_visual_test.dart`

Run: `flutter test --no-pub test/station_admin_visual_test.dart`

Expected: PASS.

---

### Task 8: Sincronizar documentação, rules e executar verificação final

**Files:**
- Modify: `DESIGN.md`
- Modify: `docs/DESIGN-E-INTERFACE.md`
- Modify: `STRUCTURE.md`
- Modify: `ARCHITECTURE.md` only if navigation/component boundaries changed
- Modify: `docs/TAP-E-RASTREABILIDADE.md` when the approved requirement is traceable
- Review: `firestore.rules`
- Review: all `lib/**/*.dart`

**Interfaces:**
- Consumes: resultado real das Tasks 1–7.
- Produces: documentação canônica sem contradições e relatório de verificação.

- [ ] **Step 1: Atualizar regras duráveis**

Em `DESIGN.md`, substituir Barlow, grafite e “um preço por card” por Manrope, azul médio e grid de três preços. Documentar `AppUserAvatar`, `StationLogo`, `FuelPriceGrid`, faixa exclusiva do recomendado e proibições.

- [ ] **Step 2: Atualizar estrutura e histórico**

Registrar novos componentes em `STRUCTURE.md`. Em `docs/DESIGN-E-INTERFACE.md`, marcar a direção anterior como substituída e registrar o lote real. Atualizar `ARCHITECTURE.md` apenas para mudanças efetivamente feitas.

- [ ] **Step 3: Revisar segurança sem alteração cosmética**

Comparar o diff funcional: se nenhum campo, coleção ou autorização mudou, manter `firestore.rules` byte a byte e registrar “revisado, sem mudança de contrato”. Se houver mudança inesperada, interromper o lote e exigir nova especificação de dados/segurança.

- [ ] **Step 4: Executar verificações completas**

Run: `dart format --output=none --set-exit-if-changed lib test`

Run: `flutter analyze --no-pub`

Run: `flutter test --no-pub`

Run: `flutter build apk --debug --no-pub`

Expected: format exit 0, analyzer 0 issues, todos os testes PASS e APK em `build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 5: Inspecionar Android em duas passagens**

Abrir lista, perfil público, perfil do usuário, auth e dashboard no emulador. Primeira passagem: fonte padrão. Segunda: fonte ampliada. Corrigir em um lote e confirmar uma única vez. Registrar qualquer superfície não alcançável por falta de dados.

- [ ] **Step 6: Fechar rastreabilidade**

Listar arquivos alterados, testes executados, status das rules e limitações reais. Não declarar homologação visual de telas que não foram abertas no Android.
