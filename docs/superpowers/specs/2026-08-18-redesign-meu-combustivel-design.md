# Redesign “Meu combustível” — Design aprovado

**Status:** implementado em 18/08/2026 na lista de postos e nos tokens compartilhados.

## Objetivo

Transformar a descoberta de postos em uma comparação rápida por combustível. O usuário escolhe o combustível uma vez e a lista inteira responde à seleção, reduzindo densidade e esforço de leitura.

## Direção visual

A interface usa base neutra pura, azul-cobalto para marca e interação e verde-esmeralda para vantagem econômica. Impacto visual vem da hierarquia, da faixa lateral dos cards e do preço dominante, não de decoração.

## Paleta

- fundo: `#F7F7F7`;
- superfície: `#FFFFFF`;
- texto principal: `#171717`;
- texto secundário: `#666666`;
- contorno: `#D4D4D4`;
- marca e interação: `#315EFB`;
- melhor valor: `#00A86B`;
- superfície de economia: `#E8F8F1`;
- aberto/sucesso: `#237A47`;
- erro/fechado: `#C9362B`.

Azul-cobalto não representa economia. Verde-esmeralda não representa navegação. O estado “Aberto” usa verde mais escuro, acompanhado de ícone e texto.

## Tipografia

- interface: Manrope ou equivalente aprovado na implementação;
- preços: Barlow Condensed ou Barlow Semi Condensed;
- título de tela: 24sp, peso 700;
- nome do posto: 17–18sp, peso 600–700;
- preço dominante: 28–32sp, peso 700;
- corpo: 15–16sp;
- metadados: 12–13sp;
- números com algarismos tabulares.

Preços não devem ultrapassar 32sp na lista. Destaque depende de posição, contraste e espaço, não de escala exagerada.

## Descoberta

### Seletor “Meu combustível”

- opções iniciais: Gasolina, Etanol e Diesel;
- seleção única;
- opção ativa em azul-cobalto, com texto e estado semântico;
- seleção permanece visível durante a rolagem quando tecnicamente adequada;
- lista e ranking são recalculados ao trocar combustível;
- última seleção pode ser lembrada localmente, sem alterar Firestore;
- transição entre estados dura de 180 a 220 ms e respeita redução de movimento.

### Filtro “Só abertos”

- controle compacto próximo ao seletor;
- desativado por padrão;
- estado expresso por texto e controle Material, nunca apenas por cor.

### Cards de posto

- fundo branco, contorno neutro, raio de 14–16dp e elevação mínima;
- faixa azul-cobalto de 4dp na lateral esquerda como assinatura visual;
- um preço dominante referente ao combustível selecionado;
- somente o menor preço válido recebe verde-esmeralda e rótulo “Melhor valor”;
- nome, bairro, nota, frescor e aberto/fechado permanecem visíveis;
- “Ver todos os preços” revela os demais combustíveis;
- “Ver posto” abre o perfil público;
- não mostrar distância sem geolocalização real.

## Estados

- preço ausente: “Preço não informado”, sem valor fictício;
- nenhum posto aberto: explicar filtro ativo e oferecer “Mostrar todos”;
- nenhum preço para combustível: manter postos encontrados e explicar ausência;
- carregamento: preservar estrutura sem inventar valores;
- erro: mensagem humana, ação para tentar novamente e nenhum detalhe de Firestore.

## Acessibilidade

- WCAG AA;
- alvos de toque mínimos de 48×48dp;
- seletor implementado com semântica de seleção;
- preço anunciado com combustível, posto e condição de melhor valor;
- faixa lateral nunca comunica estado sozinha;
- suporte a fonte ampliada e redução de movimento.

## Padrões proibidos

- painel preto ou superfície escura dominante;
- gradiente, glow, glassmorphism e sombra pesada;
- verde neon;
- todos os preços em verde;
- tabelas densas de quatro combustíveis em cada card fechado;
- valor de economia ou distância sem dado real;
- hex local quando existir token semântico.

## Escopo de implementação

O primeiro lote altera tema, componentes compartilhados e lista de postos. Perfil público e dashboard devem herdar os novos tokens, mas mudanças estruturais nessas telas exigem lote próprio.

Modelo Firestore, autorização e regras de segurança não mudam. A preferência de combustível deve permanecer local enquanto não houver requisito explícito de sincronização.

## Verificação

- testes do ranking para cada combustível;
- testes do filtro “Só abertos”;
- testes de preço ausente;
- testes widget do seletor, faixa lateral e melhor valor;
- `flutter analyze`;
- `flutter test`;
- build Android debug;
- inspeção em Android com fonte padrão e ampliada.
