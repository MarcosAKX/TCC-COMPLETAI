# Redesign Claro e Acolhedor — Design aprovado

## Objetivo

Substituir o visual escuro atual por experiência Android clara, acolhedora e profissional. Usuário deve sentir “economia encontrada com confiança”. Informação continua dominante; personalidade aparece em momentos úteis.

## Escopo

- tema Material 3 claro global;
- lista de postos;
- perfil público do posto;
- atualização administrativa de preços;
- componentes compartilhados e documentação de padrão.

Fluxos, modelo Firestore, autenticação e regras de autorização permanecem inalterados.

## Paleta

- fundo quente: `#F7F3EA`;
- superfície: `#FFFEFB`;
- superfície tonal azul: `#EAF4F6`;
- azul-petróleo: `#174A5B`;
- azul interativo: `#21738A`;
- âmbar: `#EAA62B`, somente preço/melhor oportunidade;
- verde: `#2E8B62`, somente aberto/sucesso;
- erro: `#B84A4F`;
- texto: `#253238`;
- texto secundário: `#66716F`;
- contorno: `#D7DFDC`.

## Tipografia

Uma família sans do sistema Android. Escala fixa e calma:

- título de tela: 24sp/700;
- preço protagonista: 34sp/700;
- nome do posto: 19sp/600–700;
- preço secundário: 18sp/600;
- corpo: 15sp/400;
- rótulo: 14sp/600;
- metadado: 12–13sp/500.

`R$` é menor que valor. Números usam tabular figures. Um único preço recebe âmbar dominante por superfície.

## Lista

- cabeçalho petrol com saudação neutra e quantidade real derivada da lista carregada;
- busca e ordenação permanecem acessíveis;
- resumo “Melhor preço encontrado” calculado dos dados exibidos;
- primeiro resultado do ranking recebe destaque tonal e selo “Melhor preço”; demais ficam compactos;
- posição, filtros e estados assíncronos preservados.

Não mostrar distância: geolocalização está fora do escopo.

## Perfil público

- nome/status → preços → origem/frescor → horários/serviços → avaliações;
- “Informado pelo posto” somente como descrição da origem administrativa já existente;
- sem gráfico semanal até existir histórico real adequado;
- fundos tonais quebram monotonia sem card dentro de card;
- denúncia permanece secundária e destrutiva.

## Atualização de preços

- área de preços continua primeira tarefa do dashboard;
- campos atuais preenchidos e alterações detectadas localmente;
- contador “N preços alterados”;
- aviso de alterações antes de sair;
- ação de publicar fica visualmente persistente dentro da seção de preços;
- confirmação descreve impacto: clientes verão preços atualizados.

Rascunho persistente e autosave não entram neste lote porque mudariam comportamento/dados.

## Movimento e feedback

- 150–250 ms para mudança de seleção, foco e confirmação;
- sem loops, confete, glow ou animação ornamental;
- loading dentro da ação; erros junto do contexto quando suportado;
- estados nunca dependem apenas de cor.

## Imagens

Foto ou logo real do posto seria superior ao ícone na lista e no perfil. Não será inventado asset. Até existir fonte confiável ou upload administrado, usar ícone vetorial consistente. Ilustração pode ser usada em estado vazio futuro, após criação/aprovação de asset próprio.

## Acessibilidade

- contraste WCAG AA;
- alvo mínimo 48×48dp;
- escala de fonte Android respeitada;
- Semantics para preço, status, frescor, destaques e progresso;
- confirmação textual acompanha cor/ícone.

## Documentação e segurança

- atualizar `DESIGN.md`, `docs/DESIGN-E-INTERFACE.md`, `docs/ARQUITETURA.md`, `docs/VISAO-GERAL-E-ESTRUTURA.md` e índice;
- registrar regras duráveis de tela;
- revisar `firestore.rules`; sem edição esperada porque UI não muda dados ou autorização.

## Verificação

- testes widget dos tokens e componentes;
- testes das três superfícies críticas;
- `flutter analyze`;
- `flutter test`;
- build Android debug;
- inspeção em Android quando dispositivo/emulador estiver disponível.
