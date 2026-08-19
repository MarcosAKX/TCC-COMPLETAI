# Redesign global “Ágil e inteligente” — Especificação

**Status:** implementado em 18/08/2026; validação automatizada concluída, inspeção Android pendente  
**Plataforma:** Flutter / Android prioritário  
**Escopo:** todas as telas existentes, componentes compartilhados e documentação visual

## 1. Objetivo

Aplicar em todo o Completai a direção aprovada nos mockups: clara, ágil, inteligente e orientada à comparação. A interface deve ganhar vida por hierarquia, respostas de interação e detalhes próprios do domínio, sem excesso de decoração.

O redesign preserva fluxos, dados, autenticação e regras Firestore. Mudanças funcionais fora do contrato visual — upload de logo, geolocalização, novas métricas e sincronização de preferências — não entram neste lote.

## 2. Princípios

1. Preço é informação principal, não decoração.
2. Azul-cobalto indica navegação, foco e seleção.
3. Azul médio indica valores monetários comuns.
4. Verde indica somente vantagem econômica comprovada ou sucesso, sempre acompanhado de texto.
5. A faixa lateral de 4dp é assinatura do resultado prioritário, não borda aplicada indiscriminadamente.
6. Uma tela possui uma ação dominante.
7. Movimento explica mudança de estado; nunca é ambiente ou infinito.
8. Componentes Material nativos e acessíveis têm preferência sobre controles simulados.

## 3. Tokens aprovados

### Cores

| Papel | Token proposto | Valor |
|---|---|---|
| fundo | `background` | `#F6F7F9` |
| superfície | `surface` | `#FFFFFF` |
| superfície secundária | `surfaceSubtle` | `#F3F4F6` |
| texto principal | `textPrimary` | `#1B1D22` |
| texto secundário | `textSecondary` | `#747A85` |
| contorno | `outline` | `#E7E9ED` |
| marca/seleção | `primary` | `#315EFB` |
| seleção suave | `primarySurface` | `#EDF1FF` |
| preço comum | `price` | `#3559C7` |
| superfície de preço | `priceSurface` | `#F8FAFF` |
| melhor valor | `savings` | `#079B68` |
| economia suave | `savingsSurface` | `#E7F7F0` |
| avaliação | `rating` | `#D88710` |
| erro/destrutivo | `error` | `#C9362B` |

`AppTheme.amber` e aliases temporários serão removidos depois da migração dos consumidores. Hexadecimal local é proibido quando houver token semântico.

### Tipografia

Uma única família: **Manrope**.

| Papel | Tamanho | Peso |
|---|---:|---:|
| título principal | 22sp | 700 |
| título de seção | 18sp | 700 |
| nome/item importante | 16sp | 700 |
| corpo | 15–16sp | 400–500 |
| ação/label | 13–14sp | 600–700 |
| metadado | 11–12sp | 500–600 |
| preço em lista | 18–20sp | 800 |
| preço em detalhe | 22–24sp | 800 |

Todos os valores monetários usam algarismos tabulares. Barlow Semi Condensed deixa de ser fonte de preço para evitar conflito visual com Manrope.

### Forma e espaço

- grade de espaçamento: 4dp;
- margem horizontal de tela: 16–20dp;
- cards: raio 18dp, borda de 1dp e sombra muito leve apenas quando necessária;
- inputs e botões: raio 12–14dp;
- blocos compactos de preço: raio 10dp;
- alvo de toque: mínimo 48×48dp;
- botão dominante: altura mínima 52dp.

## 4. Componentes compartilhados

### `AppUserAvatar`

Avatar no canto superior direito da área autenticada. Exibe foto quando disponível e iniciais como fallback. Toque abre o perfil do usuário logado. Deve possuir `Semantics(button: true, label: 'Abrir meu perfil')`.

### `StationLogo`

Reserva visual estável para a logo do posto. Ordem de fallback:

1. imagem confiável quando existir no modelo;
2. iniciais do posto;
3. ícone neutro de posto.

Este lote não cria upload nem novo campo Firestore. O componente deixa o contrato visual preparado para essa evolução.

### `FuelPriceGrid`

Mostra Gasolina, Etanol e Diesel em três células:

- todos os valores comuns em `price` sobre `priceSurface`;
- combustível selecionado usa contorno e fundo de seleção;
- somente o menor valor válido no contexto usa `savings` e “Melhor valor”;
- preço ausente mostra “Não informado”;
- cor nunca é o único indicador.

### `DiscoveryStationCard`

Contém logo, nome, localização textual disponível, favorito, três preços, status e frescor. O card inteiro abre o perfil público; controles internos mantêm alvos independentes. A faixa azul lateral aparece apenas no resultado recomendado/melhor ranqueado.

### `ProfileHeader`

Cabeçalho compartilhado entre perfil do cliente e perfil administrativo: avatar/logo, nome, identificador secundário e ação “Editar perfil”. Conteúdo específico permanece abaixo.

### `SectionCard` e `SettingsTile`

Substituem containers locais repetidos. `SectionCard` agrupa informação relacionada; `SettingsTile` usa ícone, título, descrição opcional e chevron nativo.

## 5. Migração por tela

### Autenticação

Arquivos: login, esqueci a senha, escolha de tipo e cadastro do cliente.

- Manrope e escala global;
- marca limpa em cobalto, sem verde decorativo;
- formulários com erro inline, ações de teclado e autofill já existentes preservados;
- um CTA dominante por tela;
- ícones em superfície azul suave, não verde de economia;
- links via `TextButton`.

### Cadastro de posto — etapas 1 e 2

- mesmo cabeçalho de progresso nas duas telas;
- conteúdo agrupado em blocos curtos;
- resumo dos dados da etapa anterior antes da confirmação final;
- CTA persistente no final visível do fluxo;
- nenhuma alteração no payload Firestore.

### Lista de postos

- cabeçalho “Meu combustível” com `AppUserAvatar`;
- busca, seletor de combustível e filtro “Só abertos”;
- todos os cards mostram Gasolina, Etanol e Diesel;
- valores comuns em azul médio; melhor valor em verde;
- logo/fallback em todos os cards;
- toque no card abre detalhes;
- seleção altera ranking e tratamento visual em 180–220ms, respeitando redução de movimento;
- distância continua proibida sem fonte real.

### Perfil público do posto

- `StationLogo` em destaque no cabeçalho;
- endereço, aberto/fechado, horário e avaliação próximos da identidade;
- seção “Todos os preços” usando `FuelPriceGrid` em versão detalhada;
- ações “Como chegar” e “Ver avaliações” somente quando os dados/fluxos existirem;
- serviços, horários, avaliações e denúncia preservados;
- favorito continua acessível na AppBar.

### Perfil do usuário

- acesso pelo avatar da lista;
- `ProfileHeader` com foto/iniciais, nome e e-mail;
- atalhos para favoritos, avaliações e configurações apenas quando houver rota/ação real;
- edição atual preservada;
- nenhum contador fictício. Métricas só aparecem com dados reais.

### Configurações

- `SettingsTile` compartilhado;
- seções “Conta”, “Privacidade” e “Suporte” quando houver ações correspondentes;
- zona destrutiva isolada em vermelho sem competir com ações comuns;
- progresso visível durante exclusão de conta.

### Perfil administrativo do posto

- `ProfileHeader` adaptado para identidade do posto;
- logo usa mesmo fallback do perfil público;
- campos de edição seguem tokens e validação global;
- dados sensíveis e mudança de senha continuam separados.

### Dashboard do posto

- cabeçalho com avatar/logo do posto;
- preço é a primeira tarefa e usa o sistema cromático aprovado;
- blocos de tags, serviços e horários tornam-se seções progressivas com resumo;
- preservar a detecção de alterações já existente e manter a ação de salvar visível na tarefa de preços; autosave e persistência de rascunho ficam fora deste lote;
- avaliações usam estrelas em cor própria de avaliação, não alias de economia;
- feedback de sucesso descreve impacto: “Preços atualizados para os clientes”.

## 6. Navegação e comportamento

- avatar do usuário na lista abre `ProfilePage`;
- card do posto abre `PublicStationProfilePage`;
- voltar restaura busca, combustível, filtro e posição da lista;
- controles aninhados não disparam navegação do card;
- estados loading, vazio, erro e sucesso usam estrutura visual coerente;
- `SnackBar` não substitui erro inline de formulário.

## 7. Dados e segurança

O redesign não autoriza mudanças em autenticação ou persistência.

- `firestore.rules` deve ser revisado e documentado, mas não alterado se o contrato de dados permanecer igual;
- logo será apenas espaço/fallback até existir requisito aprovado de armazenamento e URL confiável;
- nenhuma distância, economia, estatística ou contador será inventado;
- preferência de combustível permanece local.

Se upload de logo for solicitado futuramente, será um lote separado envolvendo Storage, validação de tipo/tamanho, autorização, limpeza e documentação de segurança.

## 8. Acessibilidade e adaptação

- contraste WCAG AA;
- texto ampliado sem corte nos nomes e valores;
- `Semantics` em avatar, logo, preço, melhor valor, status e favorito;
- estado nunca comunicado somente por cor;
- `MediaQuery.disableAnimations`/redução de movimento respeitada;
- verificação em Android compacto e Pixel 6, retrato, com fonte padrão e ampliada;
- Web/Chrome continua útil para desenvolvimento, mas não substitui inspeção Android.

## 9. Testes e verificação

- testes unitários do ranking para cada combustível;
- widget tests de `AppUserAvatar`, `StationLogo` e `FuelPriceGrid`;
- navegação avatar → perfil e card → perfil público;
- preço ausente, logo ausente e textos longos;
- testes das telas críticas com escala de texto ampliada;
- `flutter analyze --no-pub`;
- `flutter test --no-pub`;
- build APK debug;
- inspeção visual Android em duas passagens no máximo.

## 10. Documentação a atualizar na implementação

- `DESIGN.md`: autoridade dos tokens, tipografia, componentes e regras por tela;
- `docs/DESIGN-E-INTERFACE.md`: decisão e resultado do lote;
- `STRUCTURE.md`: novos componentes e responsabilidades;
- `ARCHITECTURE.md`: somente se navegação ou limites de componentes mudarem;
- `docs/TAP-E-RASTREABILIDADE.md`: rastreabilidade da experiência quando aplicável;
- `firestore.rules`: revisão obrigatória; alteração somente se houver mudança real de dados/autorização.

Documentos históricos permanecem, mas devem receber indicação clara de substituição quando contradisserem o padrão atual.

## 11. Fora do escopo

- upload/armazenamento de logo;
- geolocalização e distância;
- novos contadores, gamificação ou métricas;
- dark theme;
- mudanças de autorização Firestore;
- refatoração completa de serviços/repositórios;
- funcionalidades ainda inexistentes apenas para reproduzir o mockup.

## 12. Critério de aceite

O lote estará concluído quando todas as 12 telas existentes usarem os tokens e a tipografia aprovados, os fluxos críticos de lista/perfil reproduzirem a hierarquia validada, não houver alias visual ambíguo, testes/análise passarem, o APK for gerado, a inspeção Android for concluída e a documentação canônica estiver sincronizada.
