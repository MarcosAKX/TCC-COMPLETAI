# Estrutura — Completai

Organização de pastas, responsabilidades e convenções de nomenclatura. Baseado no código em **17/08/2026**.

## Árvore principal

```text
completai_app/
├── lib/
│   ├── main.dart                    # bootstrap Firebase + runApp
│   ├── firebase_options.dart        # config FlutterFire (Android/Web)
│   ├── app/
│   │   ├── app_widget.dart          # MaterialApp, tema, rota inicial
│   │   └── app_routes.dart          # constantes e mapa de rotas nomeadas
│   ├── core/
│   │   ├── theme/app_theme.dart     # tokens semânticos e ThemeData
│   │   └── widgets/                 # componentes compartilhados de UI e identidade
│   └── features/
│       ├── auth/                    # login, recuperação, cadastro cliente
│       ├── gas_station/             # cadastro/gestão posto, modelos públicos
│       └── user/                    # consulta pública, perfil, configurações
├── test/                            # testes unitários e de contrato visual
├── firestore.rules                  # autorização e validação Firestore
├── firebase.json                    # config Firebase (rules, hosting se houver)
├── pubspec.yaml                     # dependências e metadados do pacote
├── android/ ios/ web/ ...           # runners de plataforma (boilerplate Flutter)
├── ARCHITECTURE.md                  # arquitetura e fluxos
├── DESIGN.md                        # design system (autoridade visual)
├── STRUCTURE.md                     # este arquivo
├── PRODUCT.md                       # especificação de produto
└── docs/                            # documentação técnica complementar
```

## Responsabilidade por diretório

### `lib/app/`

Shell da aplicação. Contém apenas bootstrap de navegação e tema global. Novas rotas nomeadas entram em `app_routes.dart`.

### `lib/core/`

Código transversal a features:

| Subpasta | Conteúdo |
|---|---|
| `theme/` | `AppTheme` — cores, `ColorScheme`, `TextTheme`, temas de input/botão |
| `widgets/` | componentes reutilizáveis sem lógica de domínio pesada |

Widgets core atuais: `CustomButton`, `CustomTextField`, `BrandHeader`, `StepProgressHeader`, `PriceDisplay`, `DecisionHighlightCard`, `WelcomeSummaryHeader`, `TrustBadge`, `StatusPill`.

**Regra:** reutilizar widgets core antes de criar componente local em feature.

### `lib/features/`

Organização **por domínio de negócio**, não por tipo técnico global.

Estrutura esperada dentro de cada feature:

```text
features/<domínio>/
├── models/         # DTOs, parsing Firestore, validações de formato
├── views/          # páginas (*_page.dart)
├── viewmodels/     # validação e orquestração (quando existir)
├── repositories/   # fachada sobre service (quando existir)
└── services/       # operações Firebase
```

Nem toda feature usa todas as subpastas. `user/` não possui viewmodels nem repositories hoje.

#### `features/auth/`

| Artefato | Responsabilidade |
|---|---|
| `models/user_model.dart` | payload de cadastro do cliente |
| `viewmodels/` | validação de login, cadastro e recuperação |
| `repositories/auth_repository.dart` | fachada sobre `AuthService` |
| `services/auth_service.dart` | Firebase Auth + documento `users/{uid}` |
| `views/` | login, escolha de tipo, cadastro, recuperação de senha |

#### `features/gas_station/`

| Artefato | Responsabilidade |
|---|---|
| `models/` | cadastro privado, leitura pública, avaliação |
| `viewmodels/register_station_viewmodel.dart` | cadastro em duas etapas |
| `repositories/gas_station_repository.dart` | usado no cadastro |
| `services/gas_station_service.dart` | perfil privado/público, preços, horários, batch |
| `views/` | cadastro (2 etapas), dashboard, perfil do posto |

#### `features/user/`

| Artefato | Responsabilidade |
|---|---|
| `models/station_discovery_filter.dart` | combustível selecionado, busca, filtro de abertos e ranking por preço |
| `services/public_station_service.dart` | consulta postos, reviews, favoritos, denúncias |
| `widgets/fuel_choice_selector.dart` | seletor Material de Gasolina, Etanol e Diesel |
| `widgets/discovery_station_card.dart` | card resumido com preço dominante e melhor valor |
| `views/` | lista, perfil público, perfil cliente, configurações |

### `test/`

| Arquivo | Foco |
|---|---|
| `validation_test.dart` | validações de formulário e ranking |
| `design_system_test.dart` | contratos de tema e tokens |
| `auth_visual_flow_test.dart` | fluxo visual de autenticação |
| `station_visual_components_test.dart` | componentes de posto/preço/status |
| `station_discovery_filter_test.dart` | filtro, busca, ordenação e melhor preço por combustível |
| `station_discovery_widgets_test.dart` | seletor e card da descoberta |

Novos testes devem seguir o padrão existente: comportamento verificável, não snapshot visual.

### Raiz e plataformas

| Path | Uso |
|---|---|
| `firestore.rules` | fonte de verdade de autorização; revisar quando dados ou auth mudarem |
| `firebase.json` | deploy de rules e serviços Firebase |
| `analysis_options.yaml` | lint via `flutter_lints` padrão |
| `android/`, `web/` | plataformas com Firebase configurado |
| `ios/`, `windows/`, `linux/`, `macos/` | runners presentes; Firebase não inicializa |

## Convenções de nomenclatura

| Elemento | Convenção | Exemplo |
|---|---|---|
| arquivos Dart | snake_case | `station_list_page.dart` |
| classes | PascalCase | `StationListPage` |
| páginas | sufixo `_page.dart` | `login_page.dart` |
| viewmodels | sufixo `_viewmodel.dart` | `login_viewmodel.dart` |
| services | sufixo `_service.dart` | `auth_service.dart` |
| repositories | sufixo `_repository.dart` | `auth_repository.dart` |
| models | sufixo `_model.dart` ou nome de domínio | `public_gas_station.dart` |
| rotas | camelCase em constante | `AppRoutes.stationList` |
| coleções Firestore | snake_case plural | `public_stations`, `gas_stations` |
| copy de UI | português, sentence case | "Salvar alterações" |

## Rotas

Definidas em `lib/app/app_routes.dart`:

| Constante | Path | Página |
|---|---|---|
| `login` | `/login` | `LoginPage` |
| `registerType` | `/register-type` | `RegisterTypePage` |
| `registerUser` | `/register-user` | `RegisterUserPage` |
| `forgotPassword` | `/forgot-password` | `ForgotPasswordPage` |
| `registerStationStepOne` | `/register-station-step-one` | `RegisterStationStepOnePage` |
| `profile` | `/profile` | `ProfilePage` |
| `stationList` | `/stations` | `StationListPage` |
| `stationProfile` | `/station-profile` | `StationProfilePage` |
| `stationDashboard` | `/station-dashboard` | `StationDashboardPage` |
| `settings` | `/settings` | `SettingsPage` |

**Exceções:**

- `RegisterStationStepTwoPage` navega via `MaterialPageRoute`, não rota nomeada;
- `PublicStationProfilePage` abre com `stationId` via `MaterialPageRoute`;
- `stationProfile` não recebe argumento na tabela de rotas.

Rota inicial: `/login` (`app_widget.dart`).

## Onde colocar código novo

| Tarefa | Destino |
|---|---|
| nova tela de cliente | `features/user/views/` |
| nova tela de posto | `features/gas_station/views/` |
| nova tela de auth | `features/auth/views/` |
| widget usado em 2+ features | `core/widgets/` |
| cor/token visual novo | `core/theme/app_theme.dart` + `DESIGN.md` |
| operação Firestore de posto | `features/gas_station/services/` |
| operação Firestore de cliente | `features/user/services/` ou `auth/services/` |
| validação de formulário de cadastro | viewmodel da feature |
| regra de autorização | `firestore.rules` + doc em `docs/` |

### Componentes do padrão “Ágil e inteligente”

| Arquivo | Responsabilidade |
|---|---|
| `app_user_avatar.dart` | foto/iniciais do usuário e acesso semântico ao perfil |
| `station_logo.dart` | logo confiável ou fallback por iniciais/ícone |
| `fuel_price_grid.dart` | Gasolina, Etanol e Diesel com seleção e melhor valor |
| `section_card.dart` | agrupamento neutro compartilhado |
| `settings_tile.dart` | opção de configuração comum ou destrutiva |
| `discovery_station_card.dart` | identidade, três preços, status, frescor e navegação do posto |

Views não devem recriar estes contratos com `Container` local. Novos campos de imagem exigem lote próprio de modelo, Storage e segurança; `StationLogo` não autoriza persistência.

## Arquivos grandes (candidatos a decomposição)

Métricas aproximadas em `lib/` (~6,9 mil linhas totais):

| Arquivo | Linhas | Motivo |
|---|---:|---|
| `station_dashboard_page.dart` | ~1.363 | megaform, streams, dialogs, widgets locais |
| `public_station_profile_page.dart` | ~1.048 | leitura, avaliação, favoritos, denúncias |
| `station_list_page.dart` | ~355 | orquestra busca, combustível, filtro, refresh e navegação |
| `station_profile_page.dart` | ~528 | edição de perfil e senha |
| `profile_page.dart` | ~463 | edição de cliente e senha |

Decomposição deve seguir **responsabilidade/fluxo** (sections, dialogs, controllers), não apenas tamanho.

## Higiene do repositório

- `README.md` na raiz: ponto de entrada; links para docs canônicas.
- `pubspec.yaml`: descrição ainda genérica ("A new Flutter project") — pendência de atualização.
- logs locais (`firebase-debug.log`, `flutter_01.log`): ignorar; não versionar como documentação.
- artefatos gerados (`build/`, `.dart_tool/`): não documentar como fonte.

## Documentos relacionados

- [ARCHITECTURE.md](ARCHITECTURE.md) — camadas, fluxos e decisões técnicas
- [DESIGN.md](DESIGN.md) — tokens, componentes e regras de tela
- [docs/README.md](docs/README.md) — índice da documentação complementar


teste


