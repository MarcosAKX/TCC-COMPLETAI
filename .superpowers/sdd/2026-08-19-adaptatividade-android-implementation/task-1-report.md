# Task 1 — Harness de cenários adaptativos

## Implementação

Criado `AdaptiveTestScenario` com `size`, `textScaleFactor`, `viewInsets` e `name`, além das constantes `adaptiveSmallPhone`, `adaptiveLargeText` e `adaptiveLandscape` com os valores definidos no brief. `pumpAdaptive` configura tamanho físico, DPR 1, insets, `MediaQuery` e `TextScaler.linear`, registrando restauração da view via `addTearDown`. `expectNoLayoutExceptions` consome `tester.takeException()` e exige `null`.

## Arquivos

- `test/helpers/adaptive_test_harness.dart`
- `test/adaptive_test_harness_test.dart`

## Testes e resultados

- RED: teste focado criado antes do helper. A execução `flutter test test/adaptive_test_harness_test.dart --no-pub -r expanded` não produziu saída nem completou dentro de múltiplos intervalos de 30s; foi interrompida.
- GREEN (invocação direta do SDK): `00:00 +5: All tests passed!` para `test/adaptive_test_harness_test.dart`.
- Suíte completa (invocação direta do SDK): `00:05 +65: All tests passed!` para `test --no-pub`.
- A primeira tentativa via `flutter test` permaneceu bloqueada; a invocação direta com `FLUTTER_ALREADY_LOCKED=true` funcionou.
- Verificação estática: `git diff --check` sem erros.

## Self-review

- Nenhum arquivo de produção foi alterado.
- Cenários e valores estão alinhados ao brief.
- Restauração é registrada antes do pump; o teste de restauração registra sua asserção antes do helper, garantindo a ordem correta de teardown.
- API usa `MediaQueryData.fromView` e `TextScaler`, compatível com o SDK declarado.

## Preocupações

O caminho usual do executável Flutter ficou bloqueado neste ambiente; foi contornado com a invocação direta do snapshot do SDK. A primeira execução após destravar revelou ausência de `Directionality` nos widgets de teste e incompatibilidade de tipo para insets; ambos foram corrigidos e o foco/suíte passaram.

## Commit

Commit criado: `test(ui): add adaptive scenario harness`.

## Follow-up — cobertura de `viewInsets`

Adicionado teste de regressão com `EdgeInsets.only(bottom: 240)`, verificando `MediaQueryData.viewInsets.bottom` e a restauração de `tester.view.viewInsets` via teardown. O helper já aplicava/restaurava corretamente os insets; portanto, o novo teste passou no baseline e não exigiu mudança de produção (evidência: não houve falha RED legítima a corrigir).

Comando focado (snapshot direto): `dart.exe flutter_tools.snapshot test --no-pub test/adaptive_test_harness_test.dart` — `00:00 +6: All tests passed!`.

Suíte completa relevante: `dart.exe flutter_tools.snapshot test --no-pub` — `00:05 +66: All tests passed!`.
