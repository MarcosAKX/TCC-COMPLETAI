# Adaptatividade Android — design aprovado

## Objetivo

Garantir que os fluxos existentes do Completai permaneçam completos, legíveis e operáveis em celulares Android compactos, em retrato ou paisagem, com fonte ampliada e teclado aberto. A etapa preserva a identidade visual atual e corrige estrutura e comportamento, sem promover um redesign.

## Escopo

Esta etapa atende:

- celulares Android entre 320 e 600 dp de largura;
- orientação retrato e paisagem;
- escala de texto do sistema até 2,0×;
- teclado virtual, barras do sistema e recortes de tela;
- telas existentes de autenticação, descoberta, configurações, perfis e dashboard;
- componentes compartilhados usados por esses fluxos.

Tablets, foldables em estado expandido e uma refatoração tipográfica integral ficam fora desta etapa. Nenhuma orientação será bloqueada para contornar problemas de layout.

## Estratégia

Será criada uma base adaptativa pequena e reutilizável, seguida da migração das telas críticas. Breakpoints serão definidos pelo espaço necessário ao conteúdo, não por modelo de aparelho.

### `ResponsiveContent`

Responsável por:

- respeitar `SafeArea` e insets aplicáveis;
- aplicar margem horizontal fluida;
- limitar largura máxima em janelas maiores;
- manter conteúdo rolável quando usado em páginas de formulário.

O componente não define estilos visuais nem substitui `Scaffold`.

### `AdaptiveLayout`

Recebe composições compacta e larga e seleciona a adequada pelo `maxWidth` real do `LayoutBuilder`. O ponto de troca pertence ao conteúdo consumidor e deve ser explícito.

### `AdaptiveActionRow`

Organiza ações horizontalmente apenas quando texto e controles couberem. Em espaço insuficiente ou escala ampliada, reorganiza em coluna, preservando ordem semântica, largura útil e alvos de toque.

## Regras de layout

- Páginas com conteúdo potencialmente maior que a janela usam `ListView`, `CustomScrollView` ou `SingleChildScrollView` com constraints corretas.
- Blocos que contêm texto variável não recebem altura fixa.
- Texto pode quebrar linha e aumentar verticalmente; não será reduzido, cortado ou ocultado para caber.
- `Row` rígido que combina texto com status, preço, filtro ou ação passa a usar `Expanded`, `Flexible`, `Wrap` ou composição em coluna conforme a prioridade do conteúdo.
- Cabeçalhos preservam título e ação principal. Status e ações secundárias podem ocupar outra linha em largura reduzida.
- Cards preservam a mesma ordem de leitura e de foco ao mudar de composição.
- Botões, ícones e controles interativos mantêm área mínima de 48×48 dp e espaçamento suficiente entre alvos.
- O teclado não pode cobrir o campo ativo nem a ação necessária para concluir a tarefa.
- Scroll deve alcançar o último conteúdo e considerar o inset inferior da navegação e do teclado.

## Tipografia

- Telas migradas usam os papéis definidos no `TextTheme` do aplicativo.
- Tamanhos locais são removidos quando duplicam um papel tipográfico existente.
- Valores monetários preservam numerais tabulares e hierarquia atual.
- Escala do sistema nunca será limitada com `textScaler` fixo.
- Labels essenciais não usam uma única linha com ellipsis como solução de acessibilidade.

Esta etapa não converte obrigatoriamente todos os estilos locais do repositório; apenas os que participam dos layouts migrados ou causam comportamento incorreto.

## Ordem de migração

1. **Configurações** — trocar a `Column` não rolável por estrutura rolável e validar acesso à zona de perigo.
2. **Autenticação** — login, tipo de cadastro, cadastros e recuperação de senha com teclado e fonte ampliada.
3. **Descoberta** — cabeçalho, busca, seletor, dica, filtros e cards com reflow previsível.
4. **Perfis** — perfil público, usuário e posto, incluindo diálogos e bottom sheets.
5. **Dashboard** — cabeçalho, navegação, cards administrativos, horários e avaliações.
6. **Componentes compartilhados** — consolidar correções encontradas em `Row`, tamanhos fixos e alvos de toque.

## Cenários mínimos de teste

Cada superfície migrada deve ser coberta, conforme sua estrutura permitir, pelos seguintes cenários:

| Janela | Escala de texto | Objetivo |
|---|---:|---|
| 320×568 dp | 1,0× | menor celular suportado |
| 360×800 dp | 2,0× | fonte ampliada máxima desta etapa |
| 640×360 dp | 1,3× | paisagem compacta |

Testes de widget devem capturar exceções de layout e falhar diante de `RenderFlex overflow`. Telas roláveis devem demonstrar que o último conteúdo ou CTA pode ser alcançado. Formulários relevantes devem ser testados com inset de teclado simulado.

## Critérios de aceite

- Nenhum cenário mínimo produz overflow de layout.
- Todo conteúdo e ação essencial permanece acessível por scroll.
- A tela de Configurações alcança a zona de perigo em qualquer cenário mínimo.
- Formulários mantêm o campo focado e a ação de conclusão acessíveis com teclado aberto.
- Textos essenciais podem ocupar múltiplas linhas sem colisão ou corte.
- Todos os alvos interativos avaliados têm pelo menos 48×48 dp.
- Ordem visual, semântica e de foco continua coerente após reflow.
- `dart analyze lib test` não apresenta achados.
- A suíte completa de testes Flutter permanece verde.
- O detector de qualidade visual não apresenta novos achados bloqueantes.

## Validação Android

A aprovação visual final requer captura em Android real ou emulador para, no mínimo, retrato, paisagem e escala de fonte 1,3×. Quando nenhum dispositivo estiver conectado, a implementação pode ser concluída com evidência automatizada, mas a ausência de validação Android deve ser informada explicitamente e permanecer como verificação pendente.
