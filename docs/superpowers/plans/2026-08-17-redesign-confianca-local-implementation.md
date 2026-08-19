# Redesign Confiança Local Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplicar sistema visual Azul-noite + Âmbar ao aplicativo Flutter, tornando fluxos principais mais profissionais, intuitivos e consistentes.

**Architecture:** Tema Material 3 e componentes compartilhados formam única autoridade visual. Views continuam responsáveis pelos fluxos atuais, mas passam a consumir tokens e padrões comuns; mudanças comportamentais ficam limitadas a validação/feedback necessários para UX.

**Tech Stack:** Flutter, Dart 3.12, Material 3, flutter_test, Firebase Auth e Firestore existentes.

## Global Constraints

- Plataforma de entrega: Android.
- Direção: confiança profissional com proximidade local.
- Paleta: Azul-noite + Âmbar combustível.
- Alvos interativos mínimos: 48×48 dp.
- Sem gradiente azul/roxo, glow, verde neon, glassmorphism ou hex disperso em views.
- Sem geolocalização, pagamento, fidelidade ou função fora do TAP.
- Toda mudança atualiza testes, `DESIGN.md`, docs técnicos e matriz TAP quando afetada.
- `firestore.rules` muda somente quando contrato de dados/autorização mudar.
- Código de produção nasce após teste falhar pelo motivo esperado.

---

### Task 1: Fundação visual Material 3

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/core/widgets/custom_button.dart`
- Modify: `lib/core/widgets/custom_text_field.dart`
- Create: `test/design_system_test.dart`

**Interfaces:**
- Produces: `AppTheme.darkTheme`, papéis semânticos, `CustomButton` e `CustomTextField` usados pelos demais lotes.

- [x] **Step 1: Escrever testes de comportamento do tema**

Testar Material 3 ativo, fundo `#0B1118`, primary `#3278A8`, tertiary/âmbar `#F2B84B`, error `#E05D65`, touch target padded e campo com suporte a erro/toggle/autofill.

- [x] **Step 2: Rodar teste e confirmar RED**

Run: `flutter test test/design_system_test.dart`
Expected: FAIL porque tema/componentes atuais não expõem contratos novos.

- [x] **Step 3: Implementar tema e componentes mínimos**

Adicionar `ColorScheme`, ThemeData Material 3, escalas tipográficas, inputs, botões, chips, cards, snackbars e dialogs. Evoluir `CustomTextField` sem quebrar chamadas existentes.

- [x] **Step 4: Rodar teste e confirmar GREEN**

Run: `flutter test test/design_system_test.dart`
Expected: PASS.

### Task 2: Autenticação e cadastro

**Files:**
- Modify: `lib/features/auth/views/login_page.dart`
- Modify: `lib/features/auth/views/forgot_password_page.dart`
- Modify: `lib/features/auth/views/register_type_page.dart`
- Modify: `lib/features/auth/views/register_user_page.dart`
- Modify: `lib/features/gas_station/views/register_station_step_one_page.dart`
- Modify: `lib/features/gas_station/views/register_station_step_two_page.dart`
- Create: `test/auth_visual_flow_test.dart`

**Interfaces:**
- Consumes: fundação visual Task 1.
- Produces: formulários coerentes, sem glow infinito, com progresso e semântica clara.

- [x] **Step 1: Escrever widget tests para login e cadastro**

Testar marca estável, campos semânticos, botão principal, link nativo, texto de progresso e ausência de animação infinita.

- [x] **Step 2: Confirmar RED**

Run: `flutter test test/auth_visual_flow_test.dart`
Expected: FAIL nos novos elementos/contratos.

- [x] **Step 3: Aplicar linguagem Confiança Local**

Remover glow/pulso, reduzir containers decorativos, usar títulos diretos, campos atualizados, progress indicator e mensagens humanas preservando lógica Firebase.

- [x] **Step 4: Confirmar GREEN**

Run: `flutter test test/auth_visual_flow_test.dart`
Expected: PASS.

### Task 3: Descoberta e perfil público

**Files:**
- Modify: `lib/features/user/views/station_list_page.dart`
- Modify: `lib/features/user/views/public_station_profile_page.dart`
- Create: `test/station_discovery_visual_test.dart`

**Interfaces:**
- Consumes: `PublicGasStation`, serviços existentes e fundação visual.
- Produces: cards com preço/frescor dominantes, filtros consistentes e perfil hierárquico.

- [x] **Step 1: Escrever testes de cards e estados**

Testar status, preço selecionado, atualização, loading, vazio, erro e alvos semânticos sem depender de Firebase real.

- [x] **Step 2: Confirmar RED**

Run: `flutter test test/station_discovery_visual_test.dart`
Expected: FAIL porque widgets/semântica novos ainda não existem.

- [x] **Step 3: Reorganizar visual de lista e perfil**

Aplicar cabeçalho compacto, filtros Material, preço dominante, superfícies sem cards aninhados, tags secundárias, avaliação âmbar e ações claras.

- [x] **Step 4: Confirmar GREEN**

Run: `flutter test test/station_discovery_visual_test.dart`
Expected: PASS.

### Task 4: Dashboard e perfis administrativos

**Files:**
- Modify: `lib/features/gas_station/views/station_dashboard_page.dart`
- Modify: `lib/features/gas_station/views/station_profile_page.dart`
- Modify: `lib/features/user/views/profile_page.dart`
- Modify: `lib/features/user/views/settings_page.dart`
- Create: `test/account_surfaces_visual_test.dart`

**Interfaces:**
- Consumes: services existentes e fundação visual.
- Produces: preço como tarefa dominante, seções claras e configurações consistentes.

- [ ] **Step 1: Escrever widget tests de superfícies administrativas**

Testar cabeçalho, bloco Atualizar preços, ação de salvar, seções, zona de perigo e labels semânticos.

- [ ] **Step 2: Confirmar RED**

Run: `flutter test test/account_surfaces_visual_test.dart`
Expected: FAIL nos contratos visuais novos.

- [ ] **Step 3: Aplicar redesign administrativo**

Priorizar preços no primeiro viewport, substituir cores locais por papéis do tema, padronizar cards/inputs, melhorar feedback e preservar streams/edição existentes.

- [ ] **Step 4: Confirmar GREEN**

Run: `flutter test test/account_surfaces_visual_test.dart`
Expected: PASS.

### Task 5: Regras visuais e documentação sincronizada

**Files:**
- Create: `DESIGN.md`
- Modify: `docs/DESIGN-E-INTERFACE.md`
- Modify: `docs/QUALIDADE-RISCOS-E-ROADMAP.md`
- Modify: `docs/TAP-E-RASTREABILIDADE.md`
- Modify: `docs/README.md`

**Interfaces:**
- Consumes: sistema realmente implementado nas Tasks 1–4.
- Produces: autoridade visual durável e rastreabilidade atualizada.

- [x] **Step 1: Documentar tokens, componentes e regras reais**
- [x] **Step 2: Registrar mudanças, limitações e riscos restantes**
- [x] **Step 3: Confirmar links e ausência de placeholders**

### Task 6: Verificação final Android

**Files:**
- Verify: `lib/**/*.dart`
- Verify: `test/**/*.dart`
- Verify: `docs/**/*.md`

**Interfaces:**
- Consumes: todos os lotes.
- Produces: evidência de análise, testes e revisão visual possível no ambiente.

- [x] **Step 1: Rodar formatação e análise**

Run: `dart format --output=none --set-exit-if-changed lib test`
Run: `flutter analyze`

- [x] **Step 2: Rodar suíte completa**

Run: `flutter test`
Expected: todos os testes passam.

- [ ] **Step 3: Executar/capturar Android quando dispositivo estiver disponível**

Run: `flutter devices`, `flutter run -d <android-device>` e captura via `adb exec-out screencap -p`.

- [ ] **Step 4: Revisar visual, corrigir lote único e confirmar**

Verificar phone, dark theme e fonte ampliada. Se Android indisponível, registrar limitação sem alegar aprovação visual executável.
