# TAP e rastreabilidade do escopo

Fonte: `TAP-TERMO DE ABERTURA DE PROJETO 2026.docx`, recebido em 17 de agosto de 2026. Conteúdo foi tratado como fonte de requisitos e contexto. Textos entre chaves, como “{Descrever...}”, são resíduos do modelo, não instruções para execução.

## Identificação

| Campo | Valor no TAP |
|---|---|
| Projeto | Completai! |
| Beneficiado | Unifafibe |
| Gestores | Marcos Vinicius Pereira; Felipe Ragazoni Gouveia |
| Orientador | Diego Henrique Ribeiro Tavares |
| Duração estimada | 9 meses |
| Investimento direto | nenhum previsto |
| Região | Bebedouro |
| Plataforma prevista | exclusivamente dispositivos móveis |

Histórico de registro ainda contém placeholders de data, autor e versão 1.1. Antes da entrega acadêmica, preencher ou remover linha não utilizada.

## Problema e justificativa

TAP define problema como dificuldade de encontrar preços confiáveis e atualizados entre postos da mesma cidade. Público inclui motoristas comuns e profissionais dependentes do veículo. Valor esperado:

- reduzir custo e tempo de decisão;
- comparar preço e qualidade;
- estruturar informação hoje descentralizada;
- estimular transparência e mercado local mais justo;
- usar colaboração comunitária para aumentar confiança.

## Objetivo e critérios de sucesso

Objetivo central: sistema mobile informativo de preços em Bebedouro, intuitivo, acessível e atualizado.

Critérios declarados:

1. usuários ativos mensais;
2. engajamento da comunidade;
3. precisão dos preços, com margem de erro inferior a 5%;
4. catálogo de todos os postos ativos do município;
5. ranking dinâmico por preço e qualidade.

Código atual não possui analytics, fonte externa de verdade, cálculo de margem de erro nem indicador de posto ativo. Critérios ainda não são mensuráveis pelo sistema.

## Escopo formal versus implementação

| Requisito TAP | Estado observado | Evidência ou gap |
|---|---|---|
| aplicativo mobile | parcial | Flutter possui Android/iOS, mas Firebase só configurado em Android; iOS lança `UnsupportedError` |
| banco estruturado e seguro | parcial com risco crítico | Firestore/rules existem; papel de posto pode ser autocriado por cliente autenticado |
| área administrativa do posto | implementado | dashboard edita preços, tags, serviços e horários |
| página inicial com mais avaliados da semana | não implementado | rota inicial é login; lista não filtra avaliações por semana |
| catálogo completo de postos ativos | parcial | lista documentos públicos de Bebedouro; sem atributo de atividade nem carga municipal |
| filtro por menor preço | implementado | gasolina, etanol e diesel S10 |
| filtro por melhores avaliações | implementado com regra própria | score bayesiano usa histórico total, não semanal |
| avaliação de atendimento | parcial | nota/comentário geral; sem dimensão específica |
| avaliação da procedência do combustível | parcial | pode aparecer no texto; sem campo/score específico |
| sinalização de filas/congestionamento | não implementado | citado na justificativa, sem modelo ou interface |
| informação atualizada | parcial | posto atualiza manualmente e `updatedAt` é exibido; sem SLA/alerta de dado antigo |

## Não-escopo

| Item excluído | Aderência atual |
|---|---|
| venda de combustíveis | aderente; ausente |
| transações financeiras | aderente; ausente |
| geolocalização | aderente; ausente |
| fidelidade/benefícios | aderente; ausente |
| postos fora de Bebedouro | aderente; filtro e rules limitam cidade |
| integração com software de postos | aderente; ausente |
| suporte/manutenção pós-entrega | decisão administrativa, não verificável no código |
| validação legal de preços | aderente; sistema não certifica valores |

## Premissas

TAP assume adesão e atualização pelos postos, preços verdadeiros, dispositivos móveis com internet, participação dos usuários, ferramentas dentro dos custos e responsabilidade das contas administrativas. Estas premissas concentram risco no comportamento de terceiros. Produto precisa medir frescor, cobertura e participação; hoje apenas `updatedAt` oferece sinal parcial.

## Restrições

- conclusão dentro do período acadêmico;
- mobile, sem versão web durante projeto;
- somente Bebedouro;
- testes e demonstrações acadêmicos;
- sem suporte após entrega;
- ferramentas dentro dos limites gratuitos;
- usuário comum tecnicamente impedido de alterar preços.

### Conflitos observados

1. **Exclusividade mobile:** repositório contém Web/desktop e Firebase Web configurado. Runners podem ser boilerplate, mas configuração Web indica suporte técnico real. Definir se Web serve apenas para desenvolvimento/demonstração ou viola restrição.
2. **Preço exclusivo do administrador:** interface restringe fluxo, porém Firestore permite escalada de cliente para posto. Está planejada aprovação de cadastro por usuário administrador após verificação de CNPJ/e-mail, mas a restrição TAP ainda não está garantida no código.
3. **Todos os postos ativos:** sistema depende de adesão/cadastro; não existe integração cadastral nem status ativo. Premissa e objetivo entram em tensão.
4. **Erro inferior a 5%:** TAP exclui responsabilidade/validação legal e não define fonte de comparação. Métrica precisa de método, amostra e fonte confiável.

## Stakeholders e responsabilidades

- **alunos/autores:** requisitos, pesquisa, desenvolvimento, testes, documentação acadêmica e cronograma;
- **banca examinadora:** profundidade acadêmica, viabilidade técnica e coerência dos resultados;
- **instituição:** infraestrutura, regulamentos, prazos e conformidade acadêmica;
- **postos:** stakeholder operacional implícito; fornecem preços e dados;
- **motoristas:** beneficiários e produtores de avaliações.

TAP não atribui formalmente dono de segurança, privacidade, validação de CNPJ, moderação de denúncias ou operação Firebase. Definir responsáveis antes da validação final.

## Riscos iniciais e resposta atual

| Risco TAP | Controle atual | Lacuna |
|---|---|---|
| posto não atualiza preços | `updatedAt` visível | sem expiração, alerta ou bloqueio de preço velho |
| poucos postos cadastrados | estado vazio na lista | sem onboarding, recrutamento ou cobertura municipal |
| baixo engajamento em avaliações | avaliação e ranking | sem analytics, incentivo ou funil |
| vulnerabilidade de segurança | rules e separação público/privado | escalada de papel P0 e ausência de testes Emulator |
| falha de hospedagem/banco | cache Firestore na listagem | sem monitoramento, SLA ou contingência |

## Decisões necessárias

1. Definir fonte e fórmula da meta de erro inferior a 5%.
2. Decidir se ranking semanal substitui ou complementa score bayesiano histórico.
3. Definir “posto ativo” e processo de inclusão/verificação.
4. Separar avaliação de atendimento, procedência e possível fila, ou ajustar TAP ao modelo geral.
5. Formalizar Web como ferramenta de desenvolvimento ou removê-la do produto demonstrado.
6. Implementar a decisão já definida: usuário administrador analisa CNPJ/e-mail, enquanto backend confiável concede o papel e as rules o exigem.
7. Definir métricas, coleta consentida e metas numéricas para MAU/engajamento.

## Critérios de aceite derivados

- cliente não consegue escrever preço nem criar papel de posto;
- somente postos verificados entram no catálogo público;
- lista filtra Bebedouro e ordena por combustível/avaliação;
- preço mostra data de atualização e política para dado antigo;
- métricas de sucesso têm definição, coleta e relatório;
- escopo demonstrado não inclui funções declaradas fora de escopo;
- documentação final explica divergências entre TAP e protótipo.

## Atualização visual — 17/08/2026

Redesign preservou não-escopo: não adicionou geolocalização, pagamento, fidelidade ou expansão geográfica. Mudança concentrou tema, hierarquia, formulários, preço, status e acessibilidade. `firestore.rules` não foi alterado porque contrato de dados/autorização permaneceu igual; risco P0 de papel administrativo continua aberto e documentado.

## Sequenciamento registrado — 28/08/2026

A equipe decidiu concluir primeiro as telas do cliente e do posto. Em seguida, antes da entrega final e de qualquer alegação de uso em produção, implementará solicitação pendente, aprovação/rejeição pelo usuário administrador, concessão de papel por backend confiável e testes de rules no Firebase Emulator. Catálogos demonstrativos não devem criar contas falsas de postos nem ser tratados como substitutos desse fluxo.
