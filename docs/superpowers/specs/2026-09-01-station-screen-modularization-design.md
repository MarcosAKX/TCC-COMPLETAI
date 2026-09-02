# Modularização das telas do posto

**Data:** 01/09/2026
**Branch:** `feature/redesign-telas-posto`
**Status:** adiado; mantido como proposta para refatoração futura

## Objetivo

Reduzir o tamanho e a quantidade de responsabilidades de
`station_dashboard_page.dart` e `public_station_profile_page.dart` sem alterar
o visual, as fontes, os textos, a navegação ou o comportamento já aprovado.
Antes da extração, corrigir a exibição pública de bandeiras personalizadas e
eliminar a contradição deixada pelos documentos históricos da solução com
Firebase Storage.

## Escopo

Incluído:

- aceitar no perfil público qualquer bandeira persistida com 2 a 60 caracteres,
  incluindo o nome informado em “Outra”;
- manter “Bandeira branca” como fallback para valor ausente, curto ou acima de
  60 caracteres;
- marcar os documentos antigos de Firebase Storage como substituídos pela
  especificação de capa no Firestore;
- extrair seções visuais e diálogos das duas telas grandes para arquivos com
  responsabilidade clara;
- preservar as APIs públicas usadas por rotas e testes sempre que possível;
- manter a branch e o worktree isolados;
- executar testes focados depois de cada extração e a suíte completa ao final.

Fora do escopo:

- redesenhar componentes, trocar fontes, cores, textos ou espaçamentos;
- alterar o modelo de dados, as regras já publicadas ou a persistência da capa;
- criar novas funcionalidades;
- alterar cadastro, autenticação, preços, horários, avaliações ou denúncias;
- commit, push ou merge sem autorização separada.

## Correção da bandeira personalizada

`StationPresentationPage` já persiste o texto personalizado normalizado. As
regras Firestore também aceitam qualquer texto entre 2 e 60 caracteres. O
parsing de `PublicGasStation` deve seguir o mesmo contrato: aceitar o texto
nesse intervalo e usar “Bandeira branca” somente quando o valor for inválido.

A alteração será conduzida por TDD. Primeiro, um teste público com “Rede
Regional” deve falhar contra o filtro atual. Depois, o parsing será ajustado e
os casos inválidos continuarão cobertos.

## Estratégia de modularização

A página continua responsável por estado, carregamento e coordenação. Widgets
de apresentação e diálogos são movidos para módulos irmãos. O objetivo é
reduzir acoplamento sem introduzir uma nova camada de gerenciamento de estado.

### Dashboard administrativo

Estrutura proposta em `lib/features/gas_station/views/dashboard/`:

- `station_dashboard_shell.dart`: navegação adaptativa e cabeçalho;
- `station_dashboard_preview.dart`: prévia pública e métricas operacionais;
- `station_dashboard_prices.dart`: painel e campos de preços;
- `station_dashboard_information.dart`: informações e serviços;
- `station_dashboard_hours.dart`: horários e controles de tempo;
- `station_dashboard_reviews.dart`: avaliações e denúncia de avaliação.

`station_dashboard_page.dart` permanece como coordenador dos dados, controllers,
salvamento e seleção de seção. Widgets públicos já consumidos por testes podem
ser reexportados pelo arquivo original para evitar mudanças desnecessárias nos
consumidores.

### Perfil público

Estrutura proposta em `lib/features/user/views/station_profile/`:

- `public_station_profile_content.dart`: composição da página carregada;
- `public_station_profile_header.dart`: capa, identidade e ações;
- `public_station_profile_details.dart`: preços, horários e informações;
- `public_station_profile_reviews.dart`: resumo, lista e estado vazio;
- `public_station_profile_dialogs.dart`: avaliação e denúncias;
- `public_station_route_preview.dart`: cartão e painter da rota ilustrativa.

`public_station_profile_page.dart` permanece responsável pelo carregamento,
favoritos, chamadas do serviço e abertura dos fluxos. A extração não move regras
de negócio para widgets.

## Regras para as extrações

- Cada módulo deve representar uma seção ou fluxo reconhecível da interface.
- Não criar arquivos para widgets triviais usados uma única vez quando isso não
  melhorar a leitura.
- Evitar dependência circular: módulos não importam a página coordenadora.
- Callbacks e dados necessários serão recebidos por construtor.
- Nenhum widget extraído acessará Firebase diretamente.
- Os nomes e chaves usados pelos testes serão preservados.
- O alvo é deixar os coordenadores próximos de 400–700 linhas quando isso for
  possível sem forçar abstrações artificiais.

## Compatibilidade e documentação

As especificações antigas
`2026-08-31-station-presentation-photo-brand-design.md` e
`2026-08-31-station-photo-brand-logout.md` serão mantidas como histórico, mas
receberão um aviso visível de que a parte de Firebase Storage foi substituída
por `2026-08-31-station-cover-firestore-design.md` e pelo plano correspondente.
Isso preserva as decisões anteriores sem apresentar Storage como arquitetura
ativa.

## Testes e validação

1. Teste RED/GREEN para bandeira personalizada no `PublicGasStation`.
2. Testes focados do dashboard depois de extrair cada grupo de widgets.
3. Testes focados do perfil público e seus diálogos depois das extrações.
4. `dart format --output=none --set-exit-if-changed lib test`.
5. `flutter analyze --no-pub`.
6. `flutter test --no-pub` com todos os testes.
7. `git diff --check` e busca por referências ativas a Firebase Storage.

## Critérios de conclusão

- bandeira personalizada aparece igual na administração e no perfil público;
- os 172 testes existentes continuam passando e o novo teste também passa;
- não há mudança intencional de aparência ou comportamento;
- as duas páginas coordenadoras ficam materialmente menores;
- responsabilidades extraídas têm nomes e dependências claras;
- documentação ativa descreve somente a solução Firestore;
- alterações continuam apenas na branch isolada até decisão de integração.
