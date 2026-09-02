# Completai Design System

<!-- impeccable:design-system 2 -->

## Direction

**Ágil e inteligente:** interface para comparação rápida no celular. Usuário escolhe o combustível uma vez; a lista inteira prioriza esse contexto, sem esconder os demais preços. Experiência deve ser legível ao sol, objetiva, confiável e reconhecível pela hierarquia azul/verde e pela faixa lateral do menor preço.

Personalidade aparece em conteúdo útil e hierarquia clara, não em ornamentação.

### Contexto de uso

- motorista consulta em trânsito ou pausa curta;
- leitura em ambiente externo exige alto contraste;
- ações principais na zona do polegar (52 dp, largura total);
- preço domina; avaliação e metadados ficam secundários.

Auditoria UX e backlog visual: [docs/DESIGN-E-INTERFACE.md](docs/DESIGN-E-INTERFACE.md).

## Platform

- Flutter com Material 3 customizado.
- Entrega principal Android.
- Light theme neutro puro como padrão.
- Tipografia: Manrope em toda a interface, inclusive preços.

## Color roles

Autoridade: `lib/core/theme/app_theme.dart`.

| Papel | Token | Valor |
|---|---|---|
| fundo | `AppTheme.background` | `#F6F7F9` |
| superfície | `AppTheme.card` | `#FFFFFF` |
| superfície tonal | `AppTheme.elevatedSurface` | `#F3F4F6` |
| ação principal | `AppTheme.primary` | `#315EFB` |
| interação/foco | `AppTheme.primaryInteractive` | `#315EFB` |
| preço comum | `AppTheme.price` | `#3559C7` |
| superfície de preço | `AppTheme.priceSurface` | `#F8FAFF` |
| economia/melhor valor | `AppTheme.savings` | `#079B68` |
| superfície economia | `AppTheme.savingsSurface` | `#E7F7F0` |
| avaliação | `AppTheme.rating` | `#D88710` |
| sucesso/aberto | `AppTheme.green` | `#237A47` |
| erro/fechado/destrutivo | `AppTheme.error` | `#C9362B` |
| texto principal | `AppTheme.textLight` | `#1B1D22` |
| texto secundário | `AppTheme.textMuted` | `#747A85` |
| contorno | `AppTheme.outline` | `#E7E9ED` |

**Semântica de acento:**

- **azul-cobalto** — marca, navegação, seleção e foco;
- **azul médio** — todos os valores monetários comuns;
- **verde-esmeralda** — somente melhor valor comprovado;
- **âmbar** — somente avaliações;
- **verde escuro** — aberto e sucesso, sempre com texto/ícone;
- **grafite** — preços comuns e conteúdo principal.

Distribuição alvo: 70% superfícies claras, 20% texto, ≤10% acentos.

## Typography

| Papel | Fonte | Uso |
|---|---|---|
| UI geral | Manrope via `TextTheme` | títulos, corpo, labels |
| Preços | Manrope tabular via `AppTheme.priceStyle` | `PriceDisplay` e `FuelPriceGrid` |

Papéis M3: `headlineMedium`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `labelLarge`, `labelSmall`. Views não criam escala paralela.

## Shape and spacing

- Inputs e botões: raio 12 dp.
- Cards: raio 16 dp, borda `outline`, elevação zero ou sombra mínima.
- Marca: raio 20 dp.
- Status: pill completa.
- Touch target: mínimo 48×48 dp; botão principal 52 dp.
- Espaçamento-base: múltiplos de 4 (8, 12, 16, 20, 24, 28).
- Faixa lateral 4 dp aparece apenas no posto com menor preço do combustível selecionado.

## Components

### `CustomButton`

Botão principal de largura total, 52 dp, loading integrado. Aparência via `ElevatedButtonTheme`.

### `CustomTextField`

Label visível, erro inline, autofill, toggle de senha, ações de teclado.

### `BrandHeader`

Marca em azul-cobalto sobre superfície clara. Sem glow, gradiente ou animação infinita.

### `StepProgressHeader`

“Etapa X de Y”, barra em azul-cobalto. Cadastro em duas etapas.

### `PriceDisplay`

Combustível + valor tabular em Manrope. Preço comum usa azul médio; melhor valor usa verde-esmeralda e rótulo textual.

### `FuelPriceGrid`

Grade compacta de Gasolina, Etanol e Diesel. Todos os valores permanecem visíveis; seleção usa superfície/contorno e melhor valor usa verde + texto.

### `AppUserAvatar` e `StationLogo`

Avatar abre o perfil do usuário logado. Logo do posto reserva área estável e usa iniciais/ícone como fallback até existir imagem confiável; não inventa URL ou upload.

### `StationRatingOverview`

Resumo compartilhado de reputação para o perfil público e o dashboard. Mostra nota, quantidade de avaliações e, quando a lista completa está disponível, distribuição de 5 a 1 estrelas. A distribuição possui descrição semântica e reflui para coluna com fonte ampliada.

### `StationVisualCover`

Capa compartilhada do posto. Quando há foto persistida, ela ocupa a capa com scrim escuro de pelo menos 60% e superfície escura para o selo, preservando a leitura de texto branco sobre imagens arbitrárias; sem foto ou se a leitura falhar, usa a ilustração local. Não inventa fotografia, coordenadas ou distância; nome, localização textual e estado aberto/fechado permanecem acessíveis por semântica.

### Apresentação do posto

- “Editar exibição” abre a rota `/station-presentation` para o dono escolher/remover a capa e definir a bandeira.
- A seleção aceita JPG, PNG e WebP até 5 MiB; a aplicação gera JPEG de até 500 KiB e 1280 px, e a prévia local mostra os bytes normalizados antes de salvar.
- O selo de bandeira usa texto: Shell, Ipiranga, Petrobras, ALE, RodOil, Bandeira branca ou um nome informado em “Outra”. Não usar logos oficiais.
- A foto persistida é resolvida apenas no perfil público detalhado; a lista não busca URLs de Storage.

### `DecisionHighlightCard`

Componente legado mantido para compatibilidade. Não usar em novas listas; descoberta “Meu combustível” substitui destaques duplicados pelo ranking contextual.

### `WelcomeSummaryHeader`

Cabeçalho neutro da descoberta. Pergunta “Onde completar hoje?”, cidade e quantidade real de postos; sem distância ou economia inventada.

### `FuelChoiceSelector`

Controle segmentado Material para Gasolina, Etanol e Diesel. Seleção ativa em azul-cobalto e alvo mínimo de 48dp.

### `DiscoveryStationCard`

Card da lista com logo/fallback, três preços, frescor, nota e status. Faixa azul aparece apenas no menor preço do combustível selecionado; melhor valor recebe verde-esmeralda e rótulo textual.

### `TrustBadge`

Metadado curto (frescor/origem). Cor nunca sozinha.

### `StatusPill`

Aberto/fechado com ícone + texto + cor.

## Screen rules

### Autenticação

- uma marca, um formulário, uma ação principal;
- sem backdrop decorativo;
- links via `TextButton`.

### Descoberta (lista)

- busca no topo;
- seletor “Meu combustível”: Gasolina, Etanol e Diesel;
- filtro compacto “Só abertos”;
- lista e ranking respondem ao combustível selecionado;
- card fechado mostra Gasolina, Etanol e Diesel;
- preços comuns usam azul médio; seleção usa fundo e contorno;
- faixa azul-cobalto de 4dp aparece somente no posto com menor preço do combustível selecionado;
- menor preço válido recebe verde-esmeralda e rótulo “Melhor valor”;
- cabeçalho usa “Menor preço de [combustível]”; diferença usa “R$ X/L abaixo do próximo preço”;
- dica inline sobre troca de combustível pode ser dispensada e não reaparece após dispensa ou primeira troca;
- toque no card abre o perfil com todos os preços e informações;
- não mostrar distância ou economia sem dado real.

### Perfil público

- capa/identidade → ações → rota por endereço → combustíveis → serviços/horários → avaliações;
- identidade usa card claro com acento azul, logo confiável, cidade, endereço, status e metadados de confiança;
- “Como chegar”, “Avaliar” e “Favoritar” permanecem próximos da identidade do posto;
- a rota usa uma ilustração cartográfica local e abre o provedor externo pelo endereço; não sugere posição ou distância inexistente;
- combustíveis e horários ficam visíveis em cards próprios, sem expansão obrigatória;
- características e serviços são apresentados separadamente;
- “Como chegar” abre a rota em aplicativo externo usando a localização atual gerenciada pelo serviço de mapas;
- botões secundários com contorno visível sobre fundo claro;
- denúncia em papel de erro.

### Dashboard

- abre em **Preços**, a tarefa diária prioritária;
- navegação usa barra inferior em largura compacta e rail em largura ampliada;
- destinos: Preços, Informações, Horários e Avaliações;
- cabeçalho identifica o posto e a área administrativa; resumo operacional informa combustíveis configurados, serviços e dias ativos;
- cada seção relevante pode exibir uma prévia visual do que o cliente verá, sem criar uma segunda fonte de dados;
- o acesso “Editar exibição” é uma tarefa própria e não mistura upload de capa com os demais campos administrativos;
- seção de preços com fundo neutro e contador de alterações dentro da tarefa;
- um único CTA por seção: publicar preços, salvar informações ou salvar horários;
- cada CTA persiste somente os dados da própria seção;
- saída com mudanças pendentes oferece continuar editando ou descartá-las.

### Perfil e configurações

- o logout da conta de posto fica no perfil do posto;
- Configurações não mostra logout para esse papel;
- o usuário comum continua encontrando logout em Configurações.

## Copy and UX writing

- verbo consistente no fluxo;
- erros humanos, sem jargão técnico;
- estados vazios com direção;
- português brasileiro, sentence case.

## Accessibility

- contraste WCAG AA;
- estado não só por cor;
- alvo mínimo 48×48 dp;
- Semantics em preço, status, progresso e destaques de decisão;
- revisão em fonte ampliada e Android real.

## Adaptive layout contract

- Escopo validado: celulares Android compactos entre 320 e 600 dp de largura, em retrato e paisagem, com escala de texto do sistema até 2,0× e teclado virtual.
- Cenários automatizados mínimos: 320×568 dp a 1,0×; 360×800 dp a 2,0×; e 640×360 dp a 1,3× para paisagem compacta.
- `ResponsiveContent` centraliza `SafeArea`, margens fluidas, largura máxima e, quando solicitado, rolagem com insets de sistema e teclado.
- `AdaptiveLayout` escolhe a composição pelo espaço real do conteúdo. O breakpoint pertence ao componente consumidor, não ao modelo do aparelho.
- `AdaptiveActionRow` mantém ações lado a lado somente quando elas cabem; caso contrário, preserva ordem semântica e as reorganiza verticalmente.
- Reflow é orientado pelo conteúdo: texto variável pode crescer, e cabeçalhos, status, horários, filtros e ações usam `Flexible`, `Wrap` ou coluna antes de comprimir ou ocultar informação essencial.
- O dashboard usa navegação inferior abaixo de 840 dp e `NavigationRail` a partir de 840 dp. Esse breakpoint organiza a navegação administrativa; não amplia o escopo para tablets e foldables.
- Conteúdo e ações essenciais permanecem alcançáveis por scroll, inclusive com IME aberto, e controles avaliados mantêm alvo mínimo de 48×48 dp.
- A escala máxima coberta pela suíte automatizada é 2,0×. A aplicação não limita o `textScaler` do sistema.
- A homologação por captura em Android real ou emulador requer retrato, paisagem e fonte 1,3×. Enquanto nenhum dispositivo estiver conectado, essa inspeção visual permanece pendente e a evidência automatizada não equivale à aprovação visual Android.

## Forbidden patterns

- painel preto dominante, verde neon, ciano decorativo, glow, glassmorphism;
- gradiente decorativo;
- verde em todos os preços de uma superfície;
- mais de três combustíveis ou tabela textual densa em card fechado;
- distância ou economia sem dado real;
- hex local quando token semântico existe;
- animação infinita na marca.

## Change protocol

1. reutilizar token/componente existente;
2. atualizar teste quando contrato mudar;
3. atualizar este arquivo;
4. `flutter analyze` + `flutter test`;
5. inspeção Android antes de aprovação visual final.

## Image protocol

- Foto/logo real só com origem confiável;
- sem fotografia fictícia de posto;
- estado vazio não esconde ação de recuperação.
