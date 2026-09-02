# Station Photo, Brand, and Logout Implementation Plan

> **Plano histórico:** as tarefas de Firebase Storage foram substituídas por
> `2026-08-31-station-cover-firestore.md`. A edição de bandeira, a interface e
> a mudança do logout permanecem válidas.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permitir que um posto configure uma única foto de capa e sua bandeira em “Editar exibição”, publicar essa apresentação para clientes e mover o logout apenas do posto para o perfil administrativo.

**Architecture:** Um modelo puro valida arquivo e bandeira; `StationPresentationService` concentra Firebase Storage e sincronização dos documentos privado/público; `PublicStationService` resolve somente a foto do perfil aberto. A capa compartilhada recebe URL e bandeira opcionais, enquanto uma nova página administrativa edita a apresentação. O logout do posto é movido para o perfil e a página de configurações decide a visibilidade da sessão pelo tipo da conta.

**Tech Stack:** Flutter, Dart, Material 3, Firebase Auth, Cloud Firestore, Firebase Storage, `image_picker`, widget tests e regras Firebase.

**Spec:** `docs/superpowers/specs/2026-08-31-station-presentation-photo-brand-design.md`

## Global Constraints

- Trabalhar somente em `feature/redesign-telas-posto`, no worktree `D:\TCCGIT\.worktrees\redesign-telas-posto`.
- Não fazer commit, push, merge, deploy ou alteração na `main` sem autorização separada.
- Aceitar apenas uma imagem JPG, PNG ou WebP de até `5 * 1024 * 1024` bytes.
- Usar `coverImagePath` e `stationBrand` como campos opcionais e retrocompatíveis.
- Não usar logos oficiais, coordenadas, mapa real, galeria ou Base64 no Firestore.
- Manter a capa ilustrada como fallback em ausência ou falha de imagem.
- Preservar Manrope, alvos mínimos de 48 dp, largura de 320 dp e texto em 2,0×.
- Manter logout nas configurações do usuário comum; ocultá-lo apenas para posto.
- Cada tarefa encerra com testes e revisão do diff; commits foram deliberadamente omitidos pelas regras do repositório.

---

### Task 1: Contrato puro de apresentação e dependências

**Files:**
- Create: `lib/features/gas_station/models/station_presentation.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Create: `test/station_presentation_test.dart`

**Interfaces:**
- Produces: `stationBrandOptions`, `StationCoverSelection`, `StationPresentation`, `normalizeStationBrand(...)`.
- Consumes: somente `dart:typed_data`; não acessa Flutter, Firebase ou filesystem.

- [ ] **Step 1: Escrever os testes falhos do contrato**

```dart
import 'dart:typed_data';

import 'package:completai_app/features/gas_station/models/station_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aceita JPG, PNG e WebP até 5 MB', () {
    for (final file in [
      ('capa.jpg', 'image/jpeg'),
      ('capa.png', 'image/png'),
      ('capa.webp', 'image/webp'),
    ]) {
      final selection = StationCoverSelection.create(
        bytes: Uint8List(10),
        fileName: file.$1,
        mimeType: file.$2,
      );
      expect(selection.extension, isIn(['jpg', 'png', 'webp']));
    }
  });

  test('rejeita arquivo maior que 5 MB e formato não suportado', () {
    expect(
      () => StationCoverSelection.create(
        bytes: Uint8List(5 * 1024 * 1024 + 1),
        fileName: 'capa.jpg',
        mimeType: 'image/jpeg',
      ),
      throwsArgumentError,
    );
    expect(
      () => StationCoverSelection.create(
        bytes: Uint8List(10),
        fileName: 'capa.gif',
        mimeType: 'image/gif',
      ),
      throwsArgumentError,
    );
  });

  test('normaliza lista conhecida e exige nome quando Outra', () {
    expect(normalizeStationBrand('Shell', ''), 'Shell');
    expect(normalizeStationBrand('Outra', '  Posto Regional  '), 'Posto Regional');
    expect(() => normalizeStationBrand('Outra', ' '), throwsArgumentError);
    expect(
      () => normalizeStationBrand(
        'Outra',
        List<String>.filled(61, 'x').join(),
      ),
      throwsArgumentError,
    );
  });

  test('documento antigo usa apresentação padrão', () {
    final presentation = StationPresentation.fromMap(const {});
    expect(presentation.coverImagePath, isNull);
    expect(presentation.stationBrand, 'Bandeira branca');
  });
}
```

- [ ] **Step 2: Executar o teste para confirmar RED**

Run: `flutter test --no-pub test/station_presentation_test.dart`

Expected: FAIL porque `station_presentation.dart` e os símbolos ainda não existem.

- [ ] **Step 3: Criar a implementação mínima**

```dart
import 'dart:typed_data';

const stationBrandOptions = <String>[
  'Shell',
  'Ipiranga',
  'Petrobras',
  'ALE',
  'RodOil',
  'Bandeira branca',
  'Outra',
];

class StationPresentation {
  const StationPresentation({this.coverImagePath, required this.stationBrand});

  final String? coverImagePath;
  final String stationBrand;

  factory StationPresentation.fromMap(Map<String, dynamic> data) {
    final rawPath = data['coverImagePath'];
    final rawBrand = data['stationBrand'];
    return StationPresentation(
      coverImagePath: rawPath is String && rawPath.trim().isNotEmpty
          ? rawPath.trim()
          : null,
      stationBrand: rawBrand is String && rawBrand.trim().length >= 2
          ? rawBrand.trim()
          : 'Bandeira branca',
    );
  }
}

class StationCoverSelection {
  const StationCoverSelection._({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.extension,
  });

  static const maxBytes = 5 * 1024 * 1024;
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final String extension;

  static StationCoverSelection create({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) {
    if (bytes.isEmpty || bytes.lengthInBytes > maxBytes) {
      throw ArgumentError('A imagem deve ter no máximo 5 MB.');
    }
    final name = fileName.trim().toLowerCase();
    final type = (mimeType ?? '').trim().toLowerCase();
    final extension = name.endsWith('.jpeg') || name.endsWith('.jpg')
        ? 'jpg'
        : name.endsWith('.png')
        ? 'png'
        : name.endsWith('.webp')
        ? 'webp'
        : '';
    final expectedType = {
      'jpg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
    }[extension];
    if (expectedType == null || (type.isNotEmpty && type != expectedType)) {
      throw ArgumentError('Use uma imagem JPG, PNG ou WebP.');
    }
    return StationCoverSelection._(
      bytes: bytes,
      fileName: fileName.trim(),
      mimeType: expectedType,
      extension: extension,
    );
  }
}

String normalizeStationBrand(String selection, String customName) {
  if (!stationBrandOptions.contains(selection)) {
    throw ArgumentError('Selecione uma bandeira válida.');
  }
  final value = selection == 'Outra' ? customName.trim() : selection;
  if (value.length < 2 || value.length > 60) {
    throw ArgumentError('Informe uma bandeira entre 2 e 60 caracteres.');
  }
  return value;
}
```

- [ ] **Step 4: Adicionar dependências pelo resolvedor do projeto**

Run: `flutter pub add firebase_storage image_picker`

Expected: `pubspec.yaml` e `pubspec.lock` atualizados com versões compatíveis com o Firebase e Flutter já usados.

- [ ] **Step 5: Executar os testes do contrato**

Run: `flutter test --no-pub test/station_presentation_test.dart`

Expected: PASS.

- [ ] **Step 6: Revisar o diff da tarefa**

Run: `git diff --check && git diff -- pubspec.yaml lib/features/gas_station/models/station_presentation.dart test/station_presentation_test.dart`

Expected: sem erro de whitespace e sem dependência fora do escopo.

---

### Task 2: Storage, sincronização Firestore e regras de segurança

**Files:**
- Create: `lib/features/gas_station/services/station_presentation_service.dart`
- Create: `storage.rules`
- Modify: `firebase.json`
- Modify: `firestore.rules`
- Modify: `lib/features/gas_station/services/gas_station_service.dart`
- Modify: `test/gas_station_administrative_update_test.dart`
- Create: `test/station_presentation_service_test.dart`

**Interfaces:**
- Consumes: `StationCoverSelection`, `StationPresentation` da Task 1.
- Produces: `StationPresentationService.loadCurrent()`, `resolveCoverUrl(String?)`, `savePresentation(...)` e `removeCover(...)`.
- Produces campos públicos opcionais `coverImagePath` e `stationBrand`.

- [ ] **Step 1: Escrever o teste falho do payload público**

Acrescentar ao teste administrativo uma verificação comportamental do builder público exposto para teste no mesmo pacote:

```dart
test('perfil público preserva apresentação opcional do posto', () {
  final result = buildPublicStationPresentationFields(const {
    'coverImagePath': 'station_covers/station-1/cover_1.jpg',
    'stationBrand': 'Shell',
  });
  expect(result, {
    'coverImagePath': 'station_covers/station-1/cover_1.jpg',
    'stationBrand': 'Shell',
  });
  expect(buildPublicStationPresentationFields(const {}), isEmpty);
});
```

- [ ] **Step 2: Executar o teste para confirmar RED**

Run: `flutter test --no-pub test/gas_station_administrative_update_test.dart`

Expected: FAIL porque `buildPublicStationPresentationFields` não existe.

Também escrever testes comportamentais falhos para o coordenador do serviço, usando uma fronteira injetável sem Firebase real, que comprovem:

1. upload novo antes do batch de metadados;
2. remoção do objeto novo quando o batch falhar;
3. remoção do objeto antigo apenas depois do batch bem-sucedido;
4. remoção de metadados antes da limpeza do objeto na ação de remover capa;
5. falha de limpeza em melhor esforço não desfaz metadados já confirmados.

Run: `flutter test --no-pub test/station_presentation_service_test.dart`

Expected: FAIL porque o coordenador/serviço ainda não existe.

- [ ] **Step 3: Implementar o builder puro e integrá-lo ao perfil público**

Em `gas_station_service.dart`, criar:

```dart
Map<String, dynamic> buildPublicStationPresentationFields(
  Map<String, dynamic> stationData,
) {
  final result = <String, dynamic>{};
  final path = stationData['coverImagePath'];
  final brand = stationData['stationBrand'];
  if (path is String && path.trim().isNotEmpty) {
    result['coverImagePath'] = path.trim();
  }
  if (brand is String && brand.trim().length >= 2) {
    result['stationBrand'] = brand.trim();
  }
  return result;
}
```

Espalhar o retorno dentro de `_buildPublicStationData(...)`, sem tornar os campos obrigatórios.

- [ ] **Step 4: Criar `StationPresentationService` com dependências injetáveis**

```dart
class StationPresentationService {
  StationPresentationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<StationPresentation> loadCurrent();
  Future<String?> resolveCoverUrl(String? path);
  Future<StationPresentation> savePresentation({
    required StationPresentation current,
    required String stationBrand,
    StationCoverSelection? newCover,
  });
  Future<StationPresentation> removeCover({
    required StationPresentation current,
    required String stationBrand,
  });
}
```

Implementar `savePresentation` nesta ordem exata:

1. exigir `currentUser`;
2. quando `newCover != null`, enviar para `station_covers/$uid/cover_${DateTime.now().millisecondsSinceEpoch}.${newCover.extension}` com `SettableMetadata(contentType: newCover.mimeType)`;
3. escrever `coverImagePath`, `stationBrand` e `updatedAt` em `gas_stations/$uid` e `public_stations/$uid` usando `WriteBatch`;
4. se o batch falhar, apagar o novo objeto em `try/catch` e relançar;
5. após sucesso, apagar o caminho antigo diferente do novo em melhor esforço;
6. retornar o novo `StationPresentation`.

Implementar `removeCover` removendo os campos com `FieldValue.delete()` nos dois documentos antes de excluir o objeto antigo em melhor esforço.

- [ ] **Step 5: Criar regras de Storage fechadas por padrão**

```text
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /station_covers/{stationId}/{fileName} {
      allow read: if true;
      allow create, update: if request.auth != null
          && request.auth.uid == stationId
          && request.resource.size <= 5 * 1024 * 1024
          && (
            (fileName.matches('^cover_[0-9]+\\.jpg$')
              && request.resource.contentType == 'image/jpeg')
            || (fileName.matches('^cover_[0-9]+\\.png$')
              && request.resource.contentType == 'image/png')
            || (fileName.matches('^cover_[0-9]+\\.webp$')
              && request.resource.contentType == 'image/webp')
          );
      allow delete: if request.auth != null
          && request.auth.uid == stationId;
    }
  }
}
```

Em `firebase.json`, adicionar:

```json
"storage": {
  "rules": "storage.rules"
}
```

- [ ] **Step 6: Atualizar as whitelists e validações do Firestore**

Adicionar `coverImagePath` e `stationBrand` às chaves opcionais permitidas de `gas_stations` e `public_stations`, mas não a `hasAll`. Validar:

```text
(!('stationBrand' in data) || validString(data.stationBrand, 2, 60))
&& (!('coverImagePath' in data)
    || (data.coverImagePath is string
        && data.coverImagePath.matches('^station_covers/' + stationId + '/cover_[0-9]+\\.(jpg|png|webp)$')))
```

Permitir esses campos em `affectedKeys().hasOnly(...)` juntamente com `updatedAt` nas atualizações do proprietário.

- [ ] **Step 7: Verificar testes e sintaxe de regras**

Run: `flutter test --no-pub test/gas_station_administrative_update_test.dart test/station_presentation_test.dart test/station_presentation_service_test.dart`

Expected: PASS.

Se Firebase CLI e Java estiverem disponíveis, executar:

`firebase emulators:exec --only firestore,storage "echo rules-loaded"`

Expected: emuladores carregam `firestore.rules` e `storage.rules` sem erro de compilação. Se indisponível, registrar a limitação e não fazer deploy.

---

### Task 3: Modelo público e capa com foto/bandeira

**Files:**
- Modify: `lib/features/gas_station/models/public_gas_station.dart`
- Modify: `lib/features/user/services/public_station_service.dart`
- Modify: `lib/core/widgets/station_visual_cover.dart`
- Modify: `lib/features/user/views/public_station_profile_page.dart`
- Create: `test/public_gas_station_test.dart`
- Modify: `test/station_visual_components_test.dart`
- Modify: `test/profile_adaptability_test.dart`

**Interfaces:**
- Consumes: `coverImagePath` e `stationBrand` da Task 2.
- Produces: `PublicGasStation.coverImagePath`, `coverImageUrl`, `stationBrand`, `withCoverImageUrl(...)`.
- Estende: `StationVisualCover({String? coverImageUrl, Uint8List? coverImageBytes, String stationBrand = 'Bandeira branca'})`.

- [ ] **Step 1: Escrever testes falhos de parsing e compatibilidade**

Adicionar fixtures Firestore existentes com:

```dart
expect(station.coverImagePath, 'station_covers/station-1/cover_1.jpg');
expect(station.stationBrand, 'Shell');
expect(oldStation.coverImagePath, isNull);
expect(oldStation.stationBrand, 'Bandeira branca');
```

- [ ] **Step 2: Escrever teste falho da capa fotográfica**

Adicionar `import 'dart:convert';` ao teste para usar bytes PNG determinísticos, sem rede.

```dart
testWidgets('capa usa foto e selo de bandeira quando disponíveis', (tester) async {
  final tinyPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
    'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: StationVisualCover(
        stationName: 'Posto Avenida',
        locationLabel: 'Centro · Bebedouro',
        isOpen: true,
        coverImageBytes: tinyPng,
        stationBrand: 'Shell',
      ),
    ),
  );
  expect(find.byType(Image), findsOneWidget);
  expect(find.text('Shell'), findsOneWidget);
  expect(find.text('PARADA COMPLETA'), findsNothing);
});
```

- [ ] **Step 3: Executar testes para confirmar RED**

Run: `flutter test --no-pub test/public_gas_station_test.dart test/station_visual_components_test.dart`

Expected: FAIL nos novos campos e parâmetros.

- [ ] **Step 4: Implementar parsing e resolução da URL**

Adicionar campos opcionais a `PublicGasStation` e preservar todos em `withRating`. Criar:

```dart
PublicGasStation withCoverImageUrl(String? value) => PublicGasStation(
  // copiar campos existentes
  coverImagePath: coverImagePath,
  coverImageUrl: value,
  stationBrand: stationBrand,
);
```

Injetar `FirebaseStorage? storage` em `PublicStationService`. Em `getStation`, depois do parsing:

```dart
final station = PublicGasStation.fromDocument(...);
final path = station.coverImagePath;
if (path == null) return station;
try {
  return station.withCoverImageUrl(await _storage.ref(path).getDownloadURL());
} on FirebaseException catch (error) {
  debugPrint('Falha ao carregar capa de ${station.id}: ${error.code}.');
  return station;
}
```

Não resolver capas na lista de descoberta nesta entrega.

- [ ] **Step 5: Implementar foto, overlay e fallback na capa**

Quando `coverImageBytes` estiver preenchido, usar `Image.memory`; caso contrário, quando `coverImageUrl` não estiver vazio, usar `Image.network`. Posicionar a imagem em `Positioned.fill` com `fit: BoxFit.cover` e `errorBuilder` que devolve a ilustração atual. Assegurar por `assert` que URL e bytes não sejam fornecidos simultaneamente. Sobrepor gradiente escuro antes do conteúdo. Trocar o chip fixo por:

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Icon(Icons.local_gas_station_rounded, size: 14),
    const SizedBox(width: 6),
    Flexible(child: Text(stationBrand.toUpperCase())),
  ],
)
```

Atualizar a semântica para indicar “foto de capa” quando houver URL e continuar informando nome, localização e status.

- [ ] **Step 6: Conectar o perfil público**

Passar `station.coverImageUrl` e `station.stationBrand` para `StationVisualCover` em `PublicStationProfileContent`.

- [ ] **Step 7: Executar testes públicos e adaptativos**

Run: `flutter test --no-pub test/public_gas_station_test.dart test/station_visual_components_test.dart test/profile_adaptability_test.dart`

Expected: PASS, sem overflow em 320 dp, paisagem e texto 2,0×.

---

### Task 4: Página “Editar exibição” e integração administrativa

**Files:**
- Create: `lib/features/gas_station/views/station_presentation_page.dart`
- Modify: `lib/app/app_routes.dart`
- Modify: `lib/features/gas_station/views/station_dashboard_page.dart`
- Create: `test/station_presentation_adaptability_test.dart`
- Modify: `test/station_dashboard_adaptability_test.dart`

**Interfaces:**
- Consumes: `StationPresentationService`, `StationCoverSelection`, `stationBrandOptions`, `StationVisualCover`.
- Produces: rota `AppRoutes.stationPresentation = '/station-presentation'` e `StationPresentationContent` testável sem Firebase.
- Atualiza: `DashboardPublicPreview` com `coverImageUrl`, `stationBrand` e `onEditPresentation`.

- [ ] **Step 1: Escrever o teste falho da tela de edição**

```dart
testWidgets('edição permite escolher bandeira e salvar em largura compacta', (tester) async {
  String? savedBrand;
  await pumpAdaptive(
    tester,
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: StationPresentationContent(
          initialPresentation: const StationPresentation(
            stationBrand: 'Bandeira branca',
          ),
          initialCoverUrl: null,
          selectedCoverBytes: null,
          isSaving: false,
          onPickCover: () async {},
          onRemoveCover: () {},
          onSave: (brand) async => savedBrand = brand,
        ),
      ),
    ),
    adaptiveSmallPhone,
  );
  expect(find.text('Editar exibição'), findsOneWidget);
  expect(find.text('Selecionar foto'), findsOneWidget);
  await tester.tap(find.byKey(const Key('station-brand-selector')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Shell').last);
  await tester.tap(find.text('Salvar exibição'));
  expect(savedBrand, 'Shell');
  expectNoLayoutExceptions(tester);
});
```

- [ ] **Step 2: Escrever o teste falho do dashboard**

Atualizar o teste da prévia para esperar tooltip **Editar exibição**, foto/bandeira encaminhadas e callback acionável.

- [ ] **Step 3: Executar testes para confirmar RED**

Run: `flutter test --no-pub test/station_presentation_adaptability_test.dart test/station_dashboard_adaptability_test.dart`

Expected: FAIL porque a página, rota e parâmetros ainda não existem.

- [ ] **Step 4: Implementar `StationPresentationContent` puro**

A classe recebe estado e callbacks, renderiza:

- `StationVisualCover` como prévia;
- botão de 48 dp “Selecionar foto” ou “Substituir foto”;
- botão destrutivo “Remover foto” apenas quando houver foto atual/selecionada;
- `DropdownButtonFormField<String>` com key `station-brand-selector`;
- `TextFormField` de 60 caracteres quando a seleção for “Outra”;
- CTA “Salvar exibição” desabilitado durante salvamento;
- layout rolável via `ResponsiveContent(maxWidth: 720, scrollable: true)`.

Se `initialPresentation.stationBrand` não estiver em `stationBrandOptions`, iniciar o seletor em **Outra** e preencher o campo personalizado com o valor salvo. O callback `onSave` recebe a bandeira final já normalizada por `normalizeStationBrand`, sem persistir separadamente a origem conhecida/personalizada.

- [ ] **Step 5: Implementar a página com picker e proteção de alterações**

`StationPresentationPage` deve:

1. carregar `StationPresentationService.loadCurrent()` e resolver a URL;
2. usar `ImagePicker().pickImage(source: ImageSource.gallery)`;
3. ler `XFile.readAsBytes()` e criar `StationCoverSelection.create(...)`;
4. manter bytes locais e passá-los a `StationVisualCover.coverImageBytes` para a prévia antes do upload;
5. representar separadamente “seleção local removida” e “foto persistida marcada para remoção”, confirmar a remoção e proteger a saída com alterações pendentes usando `PopScope`;
6. chamar `savePresentation` ou `removeCover`;
7. retornar `true` ao dashboard após sucesso;
8. traduzir falhas para “Não foi possível salvar a exibição. Tente novamente.”.

- [ ] **Step 6: Registrar rota e integrar dashboard**

Em `AppRoutes`:

```dart
static const stationPresentation = '/station-presentation';
// routes
stationPresentation: (_) => const StationPresentationPage(),
```

No dashboard, carregar apresentação junto dos dados do posto, resolver URL e passar para `DashboardPublicPreview`. Substituir:

```dart
tooltip: 'Editar dados cadastrais'
```

por:

```dart
tooltip: 'Editar exibição'
onPressed: () async {
  final changed = await Navigator.pushNamed<bool>(
    context,
    AppRoutes.stationPresentation,
  );
  if (changed == true) await _loadStationData();
}
```

- [ ] **Step 7: Executar matriz adaptativa**

Run: `flutter test --no-pub test/station_presentation_adaptability_test.dart test/station_dashboard_adaptability_test.dart`

Expected: PASS em 320×568, 360×800 com texto 2,0× e 640×360.

---

### Task 5: Mover logout somente para o perfil do posto

**Files:**
- Modify: `lib/features/gas_station/views/station_profile_page.dart`
- Modify: `lib/features/user/views/settings_page.dart`
- Modify: `test/profile_adaptability_test.dart`
- Modify: `test/settings_adaptability_test.dart`

**Interfaces:**
- Produces: `StationProfileContent.onLogout` e `SettingsContent(showLogout, ...)`.
- Preserva: logout do usuário comum e exclusão de conta para ambos.

- [ ] **Step 1: Escrever testes falhos de posicionamento e visibilidade**

No teste de perfil administrativo:

```dart
expect(find.text('Alterar senha'), findsOneWidget);
expect(find.text('Sair da conta'), findsOneWidget);
expect(
  tester.getTopLeft(find.text('Sair da conta')).dy,
  greaterThan(tester.getTopLeft(find.text('Alterar senha')).dy),
);
```

Nos testes de configurações:

```dart
await tester.pumpWidget(SettingsContent(showLogout: false, ...));
expect(find.text('Sair da conta'), findsNothing);
expect(find.text('Excluir conta'), findsOneWidget);

await tester.pumpWidget(SettingsContent(showLogout: true, ...));
expect(find.text('Sair da conta'), findsOneWidget);
```

- [ ] **Step 2: Executar testes para confirmar RED**

Run: `flutter test --no-pub test/profile_adaptability_test.dart test/settings_adaptability_test.dart`

Expected: FAIL nos novos parâmetros e expectativas.

- [ ] **Step 3: Adicionar logout ao perfil do posto**

Adicionar `required VoidCallback onLogout` em `StationProfileContent`. Logo abaixo do botão de senha, renderizar `OutlinedButton.icon` com key `station-profile-logout-action`, ícone `Icons.logout`, cor `AppTheme.error`, altura mínima 52 e texto **Sair da conta**.

Em `StationProfilePage`, implementar confirmação e saída:

```dart
Future<void> _logout() async {
  final confirmed = await showDialog<bool>(...);
  if (confirmed != true) return;
  await FirebaseAuth.instance.signOut();
  if (!mounted) return;
  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
}
```

- [ ] **Step 4: Extrair conteúdo testável das configurações**

Criar `SettingsContent` com:

```dart
const SettingsContent({
  required this.showLogout,
  required this.onEditProfile,
  required this.onLogout,
  required this.onDeleteAccount,
});
```

Renderizar a seção **Sessão** somente quando `showLogout == true`. Manter sempre **Minha conta** e **Zona de perigo**.

Converter `SettingsPage` para `StatefulWidget` ou usar `FutureBuilder<bool>` com:

```dart
Future<bool> _isGasStation() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return false;
  final document = await FirebaseFirestore.instance
      .collection('gas_stations')
      .doc(uid)
      .get();
  return document.exists && document.data()?['type'] == 'gas_station';
}
```

Passar `showLogout: !isGasStation` ao conteúdo. Em erro de leitura, manter logout visível para não bloquear saída do usuário.

- [ ] **Step 5: Executar testes focados**

Run: `flutter test --no-pub test/profile_adaptability_test.dart test/settings_adaptability_test.dart`

Expected: PASS e ações finais alcançáveis por rolagem.

---

### Task 6: Documentação, verificação integrada e revisão

**Files:**
- Modify: `PRODUCT.md`
- Modify: `ARCHITECTURE.md`
- Modify: `STRUCTURE.md`
- Modify: `DESIGN.md`
- Modify: `docs/MODELO-DE-DADOS.md`
- Modify: `docs/REGRAS-DE-NEGOCIO-E-SEGURANCA.md`
- Modify: `docs/DESIGN-E-INTERFACE.md`
- Verify: all files changed since `c1cb414e37133079bec7e816de529f306beb36be`

**Interfaces:**
- Consumes todas as tarefas anteriores.
- Produces documentação canônica coerente e evidência final.

- [ ] **Step 1: Atualizar documentos sem declarar deploy**

Registrar explicitamente:

- campos opcionais `coverImagePath` e `stationBrand`;
- caminho e limite do Storage;
- dono escreve, público lê;
- fallback sem foto;
- lista de bandeiras e ausência de logos oficiais;
- rota **Editar exibição**;
- logout do posto no perfil;
- necessidade de habilitar/deployar Storage separadamente.

- [ ] **Step 2: Formatar somente Dart alterado**

Run: `dart format lib test`

Expected: formatter conclui sem erro; revisar `git diff --stat` para garantir que não houve reescrita fora do escopo. Se houver, formatar apenas a lista explícita de arquivos e restaurar mecanicamente arquivos sem mudança lógica.

- [ ] **Step 3: Executar análise estática**

Run: `flutter analyze --no-pub`

Expected: `No issues found!`.

- [ ] **Step 4: Executar suíte completa**

Run: `flutter test --no-pub`

Expected: todos os testes aprovados, zero falhas e zero exceções de layout.

- [ ] **Step 5: Verificar integridade do diff**

Run: `git diff --check && git status --short && git diff --stat`

Expected: apenas arquivos da feature, documentação e lockfiles; nenhum segredo, build output ou plugin registrant com conteúdo alterado.

- [ ] **Step 6: Validar manualmente no navegador**

Run: `flutter run -d web-server --web-hostname localhost --web-port 8080`

Verificar:

1. lápis abre **Editar exibição**;
2. seleção de imagem mostra prévia antes de salvar;
3. Shell e Bandeira branca aparecem como selo;
4. Outra exige nome;
5. substituição atualiza a capa sem cache antigo;
6. remoção volta para a ilustração;
7. perfil público mostra a mesma foto/bandeira;
8. posto sai pelo perfil e não vê logout nas configurações;
9. usuário comum ainda vê logout nas configurações.

- [ ] **Step 7: Solicitar revisão independente**

Pedir revisão read-only com foco em segurança de Storage, sincronização privada/pública, rollback de upload, compatibilidade de documentos antigos, acessibilidade e logout por papel de conta. Corrigir todo item Critical/Important e repetir Steps 3–5.

- [ ] **Step 8: Entregar sem integrar**

Relatar arquivos principais, testes executados, limitações de emulador/Android e passos externos necessários para habilitar/deployar Firebase Storage. Manter branch e worktree intactos; não fazer commit, merge, push ou deploy.
