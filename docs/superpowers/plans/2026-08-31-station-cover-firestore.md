# Station Cover in Firestore Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir Firebase Storage por uma única foto JPEG comprimida em um documento separado do Firestore, mantendo bandeira, prévias e perfil público sem exigir o plano Blaze.

**Architecture:** `StationCoverProcessor` normaliza JPG/PNG/WebP para JPEG de até 500 KiB. `StationPresentationService` grava bandeira e `station_covers/{uid}` atomicamente no Firestore; a lista pública continua lendo apenas `public_stations`, enquanto o detalhe busca os bytes da capa sob demanda.

**Tech Stack:** Flutter, Dart 3.12, Cloud Firestore, Firebase Auth, `image_picker`, `image: ^4.9.2`, Material 3, Flutter Test e Firebase Security Rules.

**Spec:** `docs/superpowers/specs/2026-08-31-station-cover-firestore-design.md`

## Global Constraints

- Trabalhar somente em `D:/TCCGIT/.worktrees/redesign-telas-posto`, branch `feature/redesign-telas-posto`.
- Não contratar Blaze e não usar Cloud Storage for Firebase.
- Não executar commit, push, merge ou deploy sem autorização explícita; substituir cada passo de commit por snapshot/diff de revisão.
- Aceitar entrada JPG, PNG ou WebP de até 5 MiB e persistir somente JPEG de até 500 KiB.
- Limitar a maior dimensão persistida a 1280 pixels e nunca ampliar imagens menores.
- Manter uma única foto por posto em `station_covers/{uid}`.
- A lista pública não pode ler `station_covers`; somente administração e detalhe público.
- Toda persistência da UI deve terminar ou falhar em até 20 segundos e sempre reabilitar o botão.
- Preservar o fallback ilustrado, as fontes e o visual já aprovado.
- As regras podem ser validadas com `dry-run`, mas não implantadas nesta execução.
- Usar `apply_patch` para edições manuais e formatar somente arquivos Dart tocados.

---

### Task 1: Normalização da foto para JPEG pequeno

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Modify: `lib/features/gas_station/models/station_presentation.dart`
- Test: `test/station_presentation_test.dart`

**Interfaces:**
- Produces: `StationCoverImage({required Uint8List bytes})`
- Produces: `StationCoverProcessor.normalize({required Uint8List bytes, required String fileName, String? mimeType}) -> StationCoverImage`
- Produces constants: `StationCoverProcessor.maxInputBytes == 5 * 1024 * 1024`, `maxOutputBytes == 500 * 1024`, `maxDimension == 1280`, `contentType == 'image/jpeg'`

- [ ] **Step 1: Adicionar a dependência e escrever testes que falham**

Adicionar `image: ^4.9.2` a `dependencies`, executar `flutter pub get` no SDK
gravável e substituir os testes de extensão/caminho por testes de comportamento
com imagens reais geradas pela biblioteca:

```dart
test('normaliza PNG para JPEG de até 500 KiB e 1280 px', () {
  final source = img.Image(width: 1800, height: 1200);
  img.fill(source, color: img.ColorRgb8(20, 120, 220));

  final result = StationCoverProcessor.normalize(
    bytes: Uint8List.fromList(img.encodePng(source)),
    fileName: 'posto.png',
    mimeType: 'image/png',
  );

  final decoded = img.decodeJpg(result.bytes)!;
  expect(result.contentType, 'image/jpeg');
  expect(result.bytes.lengthInBytes, lessThanOrEqualTo(500 * 1024));
  expect(decoded.width, 1280);
  expect(decoded.height, 853);
});

test('rejeita arquivo inválido sem produzir bytes', () {
  expect(
    () => StationCoverProcessor.normalize(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'posto.jpg',
      mimeType: 'image/jpeg',
    ),
    throwsArgumentError,
  );
});
```

Adicionar casos equivalentes para entrada JPEG, WebP, MIME incompatível, vazio e entrada acima de 5 MiB.

- [ ] **Step 2: Executar os testes e confirmar RED**

Run:

```powershell
flutter test --no-pub test/station_presentation_test.dart
```

Expected: FAIL porque `StationCoverProcessor` e `StationCoverImage` ainda não existem.

- [ ] **Step 3: Implementar o processador mínimo**

Em `station_presentation.dart`, manter bandeiras e substituir `StationCoverSelection` por:

```dart
class StationCoverImage {
  const StationCoverImage({required this.bytes});

  final Uint8List bytes;
  int get byteSize => bytes.lengthInBytes;
  String get contentType => StationCoverProcessor.contentType;
}

abstract final class StationCoverProcessor {
  static const maxInputBytes = 5 * 1024 * 1024;
  static const maxOutputBytes = 500 * 1024;
  static const maxDimension = 1280;
  static const contentType = 'image/jpeg';

  static StationCoverImage normalize({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) {
    if (bytes.isEmpty || bytes.lengthInBytes > maxInputBytes) {
      throw ArgumentError('A imagem original deve ter no máximo 5 MB.');
    }
    final name = fileName.trim().toLowerCase();
    final type = (mimeType ?? '').trim().toLowerCase();
    final expectedType = name.endsWith('.jpg') || name.endsWith('.jpeg')
        ? 'image/jpeg'
        : name.endsWith('.png')
        ? 'image/png'
        : name.endsWith('.webp')
        ? 'image/webp'
        : null;
    if (expectedType == null || (type.isNotEmpty && type != expectedType)) {
      throw ArgumentError('Use uma imagem JPG, PNG ou WebP.');
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw ArgumentError('Não foi possível ler a imagem.');
    var working = img.bakeOrientation(decoded);
    final largest = math.max(working.width, working.height);
    if (largest > maxDimension) {
      working = working.width >= working.height
          ? img.copyResize(working, width: maxDimension)
          : img.copyResize(working, height: maxDimension);
    }

    while (true) {
      for (final quality in const [82, 72, 62, 52, 42]) {
        final encoded = img.encodeJpg(working, quality: quality);
        if (encoded.lengthInBytes <= maxOutputBytes) {
          return StationCoverImage(bytes: encoded);
        }
      }
      final currentLargest = math.max(working.width, working.height);
      if (currentLargest <= 320) break;
      working = img.copyResize(
        working,
        width: math.max(1, (working.width * .85).round()),
        height: math.max(1, (working.height * .85).round()),
      );
    }
    throw ArgumentError('Não foi possível reduzir a foto para 500 KB.');
  }
}
```

Usar `package:image/image.dart` apenas neste arquivo. Preservar `StationPresentation` e `normalizeStationBrand`, trocando `coverImagePath` por `Uint8List? coverImageBytes`.

- [ ] **Step 4: Executar testes e confirmar GREEN**

Run:

```powershell
flutter test --no-pub test/station_presentation_test.dart
```

Expected: todos os casos do processador e das bandeiras passam.

- [ ] **Step 5: Formatar e criar snapshot de revisão**

Formatar somente `station_presentation.dart` e seu teste. Salvar diff da tarefa em `.superpowers/sdd/2026-08-31-station-cover-firestore/task-1-review.diff`; não commitar.

---

### Task 2: Persistência atômica no Firestore

**Files:**
- Modify: `lib/features/gas_station/services/gas_station_service.dart`
- Modify: `lib/features/gas_station/services/station_presentation_service.dart`
- Modify: `test/gas_station_administrative_update_test.dart`
- Modify: `test/station_presentation_service_test.dart`

**Interfaces:**
- Consumes: `StationCoverImage`
- Produces: `buildPublicStationData(Map<String, dynamic> stationData, {Map<String, double>? fuelPrices, List<String>? tags, List<String>? services, Map<String, Map<String, dynamic>>? openingHours}) -> Map<String, dynamic>`
- Produces boundary methods `loadCover(String stationId)` and `commitPresentation({required String stationId, required Uint8List? coverBytes, required String stationBrand, required bool removeCover})`
- Produces: `StationPresentationService.loadCurrent()` com bandeira e bytes opcionais

- [ ] **Step 1: Escrever testes de serviço que falham**

Atualizar `_FakeBoundary` e cobrir a nova ordem observável:

```dart
test('salvar só bandeira preserva bytes da capa', () async {
  final cover = Uint8List.fromList([0xff, 0xd8, 0xff, 0xd9]);
  final boundary = _FakeBoundary(coverBytes: cover);
  final service = StationPresentationService.withBoundary(boundary);

  final current = await service.loadCurrent();
  final result = await service.savePresentation(
    current: current,
    stationBrand: 'Shell',
  );

  expect(boundary.events, ['load:station-1', 'cover:station-1',
    'commit:station-1:null:Shell:false']);
  expect(result.coverImageBytes, same(cover));
});

test('substitui capa com bytes JPEG normalizados', () async {
  final replacement = StationCoverImage(
    bytes: Uint8List.fromList([0xff, 0xd8, 0xff, 0xd9]),
  );
  final boundary = _FakeBoundary();
  final service = StationPresentationService.withBoundary(boundary);

  final result = await service.savePresentation(
    current: const StationPresentation(stationBrand: 'ALE'),
    stationBrand: 'Shell',
    newCover: replacement,
  );

  expect(boundary.committedCoverBytes, same(replacement.bytes));
  expect(result.coverImageBytes, same(replacement.bytes));
});
```

Adicionar testes de remoção e de documento de capa ausente. Em
`gas_station_administrative_update_test.dart`, testar `buildPublicStationData`
com literais e verificar que a ramificação de projeção pública ausente usa o
builder dentro da transação.

- [ ] **Step 2: Executar os testes e confirmar RED**

Run:

```powershell
flutter test --no-pub test/station_presentation_service_test.dart test/gas_station_administrative_update_test.dart
```

Expected: FAIL nas assinaturas antigas baseadas em path/Storage.

- [ ] **Step 3: Tornar o builder público reutilizável**

Renomear `_buildPublicStationData` para `buildPublicStationData` no topo de
`gas_station_service.dart`, preservando defaults e usos atuais. O builder deve
omitir `coverImagePath` e incluir somente `stationBrand` válido como campo de
apresentação.

- [ ] **Step 4: Substituir a boundary de Storage pela boundary do Firestore**

Remover `FirebaseStorage`. A implementação concreta deve:

```dart
Future<Uint8List?> loadCover(String stationId) async {
  final snapshot = await _firestore.collection('station_covers').doc(stationId).get();
  final value = snapshot.data()?['bytes'];
  return value is Blob ? value.bytes : null;
}
```

`commitPresentation` deve executar uma transação que lê as projeções privada e
pública, reconstrói a pública com `buildPublicStationData` quando ausente,
remove qualquer `coverImagePath` legado e:

```dart
if (coverBytes != null) {
  transaction.set(coverReference, {
    'stationId': stationId,
    'bytes': Blob(coverBytes),
    'contentType': 'image/jpeg',
    'byteSize': coverBytes.lengthInBytes,
    'updatedAt': FieldValue.serverTimestamp(),
  });
} else if (removeCover) {
  transaction.delete(coverReference);
}
```

Usar `transaction.set(publicReference, publicData, SetOptions(merge: true))`
para suportar postos legados. Não gravar Base64 nem URL.

- [ ] **Step 5: Adaptar `StationPresentationService`**

`loadCurrent` lê primeiro o posto e depois a capa. `savePresentation` recebe
`StationCoverImage? newCover`, preserva os bytes atuais quando não há troca e
retorna os novos bytes após transação. `removeCover` apaga o documento e retorna
apresentação sem bytes. Remover upload, download URL e rollback de objetos.

- [ ] **Step 6: Executar testes e confirmar GREEN**

Run:

```powershell
flutter test --no-pub test/station_presentation_service_test.dart test/gas_station_administrative_update_test.dart
```

Expected: todos os testes passam e nenhum evento menciona upload/delete de Storage.

- [ ] **Step 7: Formatar e criar snapshot de revisão**

Formatar os quatro Dart tocados. Salvar `task-2-review.diff`; não commitar.

---

### Task 3: Capa pública carregada somente no detalhe

**Files:**
- Modify: `lib/features/gas_station/models/public_gas_station.dart`
- Modify: `lib/features/user/services/public_station_service.dart`
- Modify: `lib/features/user/views/public_station_profile_page.dart`
- Modify: `test/public_gas_station_test.dart`
- Modify: `test/profile_adaptability_test.dart`

**Interfaces:**
- Produces: `PublicGasStation.coverImageBytes: Uint8List?`
- Produces: `PublicGasStation.withCoverImageBytes(Uint8List? value)`
- Removes: `coverImagePath`, `coverImageUrl`, `withCoverImageUrl`
- Produces: `PublicStationService.getStationCover(String stationId)`

- [ ] **Step 1: Escrever testes que falham**

Trocar expectativas de path/URL por bytes:

```dart
test('preserva bytes da capa ao atualizar avaliação', () {
  final bytes = Uint8List.fromList([0xff, 0xd8, 0xff, 0xd9]);
  final station = PublicGasStation.fromDocument(
    _DocumentSnapshot('station-1', const {'name': 'Posto Avenida'}),
  ).withCoverImageBytes(bytes);

  final rated = station.withRating(average: 4.5, count: 6);
  expect(rated.coverImageBytes, same(bytes));
});
```

No teste adaptativo, montar `PublicStationProfileContent` com bytes e verificar
que `StationVisualCover` contém `MemoryImage`. Manter teste de fallback sem capa.

- [ ] **Step 2: Executar os testes e confirmar RED**

Run:

```powershell
flutter test --no-pub test/public_gas_station_test.dart test/profile_adaptability_test.dart
```

Expected: FAIL porque o modelo e a view ainda usam URL/path.

- [ ] **Step 3: Adaptar modelo e view**

Adicionar `dart:typed_data`, substituir campos e preservar bytes em
`withRating`. Em `PublicStationProfileContent`, passar
`coverImageBytes: station.coverImageBytes` ao `StationVisualCover`.

- [ ] **Step 4: Adaptar `PublicStationService`**

Remover `FirebaseStorage` do construtor. `getStations()` não acessa
`station_covers`. Somente `getStation()` deve ler
`station_covers/{stationId}`, validar `Blob`, `contentType == image/jpeg` e
`byteSize == bytes.lengthInBytes`, e retornar `withCoverImageBytes(bytes)`.
Falha ou ausência preserva o fallback sem impedir o restante do detalhe.

- [ ] **Step 5: Executar testes e confirmar GREEN**

Run:

```powershell
flutter test --no-pub test/public_gas_station_test.dart test/profile_adaptability_test.dart test/station_visual_components_test.dart
```

Expected: todos passam; capa pública usa `MemoryImage` somente no detalhe.

- [ ] **Step 6: Formatar e criar snapshot de revisão**

Formatar arquivos Dart explícitos e salvar `task-3-review.diff`; não commitar.

---

### Task 4: Edição administrativa, timeout e mensagens acionáveis

**Files:**
- Modify: `lib/features/gas_station/views/station_presentation_page.dart`
- Modify: `lib/features/gas_station/views/station_dashboard_page.dart`
- Modify: `test/station_presentation_adaptability_test.dart`
- Modify: `test/station_dashboard_adaptability_test.dart`

**Interfaces:**
- Consumes: `StationCoverProcessor.normalize` e `StationCoverImage`
- Consumes: `StationPresentation.coverImageBytes`
- Produces: timeout constante `Duration(seconds: 20)` na página

- [ ] **Step 1: Escrever testes de UI que falham**

Adicionar teste com boundary cujo commit nunca conclui por `Completer`:

```dart
testWidgets('timeout encerra o spinner e permite tentar novamente', (tester) async {
  final boundary = _NeverCompletingBoundary();
  await pumpPresentationPage(tester, boundary: boundary);
  await selectBrandAndSave(tester, 'Shell');
  await tester.pump(const Duration(seconds: 21));

  expect(find.text('A operação demorou demais. Tente novamente.'), findsOneWidget);
  expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Salvar exibição')).onPressed, isNotNull);
});
```

Adicionar casos de `FirebaseException(code: 'permission-denied')`, sessão ausente,
seleção inválida, foto normalizada na prévia e sucesso retornando `true`.

- [ ] **Step 2: Executar testes e confirmar RED**

Run:

```powershell
flutter test --no-pub test/station_presentation_adaptability_test.dart test/station_dashboard_adaptability_test.dart
```

Expected: FAIL porque não há timeout nem mensagens específicas e a página ainda usa path/URL.

- [ ] **Step 3: Adaptar seleção, carregamento e prévias**

Em `_pickCover`, ler bytes e chamar `StationCoverProcessor.normalize`; guardar
somente `StationCoverImage` e mostrar seus bytes. Trocar `_coverUrl` por
`Uint8List? _persistedCoverBytes`. Dashboard e `DashboardPublicPreview` passam
`coverImageBytes` ao widget compartilhado.

- [ ] **Step 4: Implementar timeout e tradução de erros**

Executar a future de serviço com `.timeout(const Duration(seconds: 20))`.
Usar `finally` para restaurar `_isSaving` quando a rota continuar montada.
Mapear:

```text
TimeoutException -> A operação demorou demais. Tente novamente.
StateError de sessão -> Sua sessão expirou. Entre novamente.
FirebaseException permission-denied -> As permissões do Firestore ainda não permitem salvar esta exibição.
ArgumentError -> mensagem de validação da foto/bandeira.
demais -> Não foi possível salvar a exibição. Tente novamente.
```

No sucesso, autorizar pop com `true`. Em erro, preservar imagem e bandeira locais.

- [ ] **Step 5: Executar testes e confirmar GREEN**

Run:

```powershell
flutter test --no-pub test/station_presentation_adaptability_test.dart test/station_dashboard_adaptability_test.dart
```

Expected: todos passam; nenhum spinner permanece após 20 segundos simulados.

- [ ] **Step 6: Formatar e criar snapshot de revisão**

Formatar os quatro arquivos e salvar `task-4-review.diff`; não commitar.

---

### Task 5: Regras, dependências, documentação e verificação integrada

**Files:**
- Modify: `firestore.rules`
- Modify: `firebase.json`
- Delete: `storage.rules`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Regenerate: `linux/flutter/generated_plugin_registrant.cc`
- Regenerate: `linux/flutter/generated_plugins.cmake`
- Regenerate: `macos/Flutter/GeneratedPluginRegistrant.swift`
- Regenerate: `windows/flutter/generated_plugin_registrant.cc`
- Regenerate: `windows/flutter/generated_plugins.cmake`
- Modify: `PRODUCT.md`
- Modify: `ARCHITECTURE.md`
- Modify: `STRUCTURE.md`
- Modify: `DESIGN.md`
- Modify: `docs/MODELO-DE-DADOS.md`
- Modify: `docs/REGRAS-DE-NEGOCIO-E-SEGURANCA.md`
- Modify: `docs/DESIGN-E-INTERFACE.md`

**Interfaces:**
- Consumes: `station_covers/{uid}` schema from the spec
- Removes: `firebase_storage` and Firebase Storage rules/configuration

- [ ] **Step 1: Alterar regras e configuração local**

Remover validação de `coverImagePath` das projeções e adicionar:

```text
match /station_covers/{stationId} {
  allow read: if true;
  allow create, update: if ownsDocument(stationId)
      && request.resource.data.keys().hasOnly([
        'stationId', 'bytes', 'contentType', 'byteSize', 'updatedAt'
      ])
      && request.resource.data.keys().hasAll([
        'stationId', 'bytes', 'contentType', 'byteSize', 'updatedAt'
      ])
      && request.resource.data.stationId == stationId
      && request.resource.data.bytes is bytes
      && request.resource.data.bytes.size() <= 500 * 1024
      && request.resource.data.contentType == 'image/jpeg'
      && request.resource.data.byteSize == request.resource.data.bytes.size()
      && request.resource.data.updatedAt == request.time;
  allow delete: if ownsDocument(stationId);
}
```

Remover o bloco `storage` de `firebase.json` e apagar `storage.rules` via
`apply_patch`.

- [ ] **Step 2: Remover plugin e regenerar dependências**

Remover `firebase_storage`, manter `image_picker` e `image`. Executar
`flutter pub get` no SDK gravável. Revisar registradores gerados para confirmar
que somente o plugin de Storage saiu; não editar registradores manualmente.

- [ ] **Step 3: Atualizar documentação canônica**

Substituir referências a bucket/path/URL por documento binário separado,
compressão de 500 KiB, leitura somente no detalhe, timeout e ausência de Blaze.
Registrar explicitamente que regras foram apenas validadas, não implantadas.

- [ ] **Step 4: Validar regras sem deploy**

Run:

```powershell
firebase deploy --only firestore:rules --project completai-tcc --dry-run --json
```

Expected: status `success`. Não executar `firebase deploy` sem `--dry-run`.

- [ ] **Step 5: Executar análise e suíte completa**

Run:

```powershell
flutter analyze --no-pub
flutter test --no-pub
git diff --check
```

Expected: análise sem issues, todos os testes aprovados e diff sem erros de whitespace.

- [ ] **Step 6: Revisar escopo e produzir relatório**

Confirmar em `git status --short` que não existem builds, segredos ou arquivos
temporários novos. Registrar número exato de testes, limitações do `dry-run`,
branch/worktree e ausência de commit/push/merge/deploy em
`.superpowers/sdd/2026-08-31-station-cover-firestore/task-5-report.md`.

- [ ] **Step 7: Criar snapshot final de revisão**

Gerar diff completo da mudança Storage -> Firestore incluindo arquivos novos e
removidos. Solicitar revisão de especificação, qualidade e segurança antes de
qualquer alegação de conclusão.
