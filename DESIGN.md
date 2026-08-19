# Completai Design System

<!-- impeccable:design-system 2 -->

## Direction

**Ágil e inteligente:** interface para comparação rápida no celular. Usuário escolhe o combustível uma vez; a lista inteira prioriza esse contexto, sem esconder os demais preços. Experiência deve ser legível ao sol, objetiva, confiável e reconhecível pela hierarquia azul/verde e pela faixa lateral do resultado recomendado.

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
- Faixa lateral 4 dp aparece apenas no resultado recomendado/melhor ranqueado.

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

### `DecisionHighlightCard`

Componente legado mantido para compatibilidade. Não usar em novas listas; descoberta “Meu combustível” substitui destaques duplicados pelo ranking contextual.

### `WelcomeSummaryHeader`

Cabeçalho neutro da descoberta. Pergunta “Onde completar hoje?”, cidade e quantidade real de postos; sem distância ou economia inventada.

### `FuelChoiceSelector`

Controle segmentado Material para Gasolina, Etanol e Diesel. Seleção ativa em azul-cobalto e alvo mínimo de 48dp.

### `DiscoveryStationCard`

Card da lista com logo/fallback, três preços, frescor, nota e status. Faixa azul aparece apenas no recomendado; melhor valor recebe verde-esmeralda e rótulo textual.

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
- faixa azul-cobalto de 4dp aparece somente no resultado recomendado;
- menor preço válido recebe verde-esmeralda e rótulo “Melhor valor”;
- toque no card abre o perfil com todos os preços e informações;
- não mostrar distância ou economia sem dado real.

### Perfil público

- nome/status → preços (menor destacado) → frescor → serviços → avaliações;
- botões secundários com contorno visível sobre fundo claro;
- denúncia em papel de erro.

### Dashboard

- seção de preços com fundo neutro; melhor valor usa `savingsSurface` e verde-esmeralda;
- “Atualizar preços” antes do resumo;
- contador de alterações dentro da tarefa de preços.

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
